//
//  GameStateViewController.m
//  JudgeHelper
//
//  Created by YANG FAN on 01/12/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "GameStateViewController.h"
#import "DeviceSettings.h"
#import "GlobalSettings.h"
#import "AppDelegate.h"
#import "CCEngin.h"
#import "UIPlayer.h"
#import "TableView.h"


@implementation GameStateViewController

@synthesize bodyView=bodyView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        engin = [CCEngin getEngin];
        isInitFinished = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTopBarView];
    [self initScrollView];
}

- (void)initScrollView {
    // Create the scroll view and the image view.
    scrollView  = [[UIScrollView alloc] init];
    scrollView.showsVerticalScrollIndicator = YES;
    
    bodyView = [[UIView alloc] init];
    CGSize bodyViewSize = [self initPlayersLines];
    
    // Add the scroll view to our view.
    [self.stateView addSubview:scrollView];
    
    // Add the body view to the scroll view.
    [scrollView addSubview:bodyView];
    
    // Set the translatesAutoresizingMaskIntoConstraints to NO so that the views autoresizing mask is not translated into auto layout constraints.
    scrollView.translatesAutoresizingMaskIntoConstraints  = NO;
    bodyView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Set the constraints for the scroll view and the image view.
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(scrollView, bodyView);
    
    [self.stateView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    
    [self.stateView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    
    bodyViewWidthContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[bodyView(width)]|" options:0 metrics:@{@"width":@(bodyViewSize.width)} views:viewsDictionary];
    bodyViewHeightContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bodyView(height)]|" options:0 metrics:@{@"height":@(bodyViewSize.height)} views:viewsDictionary];
    
    [scrollView addConstraints:bodyViewWidthContraints];
    [scrollView addConstraints:bodyViewHeightContraints];

}

- (CGSize)initPlayersLines {
    GlobalSettings* global = [GlobalSettings globalSettings];
    
    pIds = [NSMutableArray new];
    playerLines = [NSMutableDictionary new];
    playerVisibleObjects = [NSMutableDictionary new];
    playerLifeBoxes = [NSMutableDictionary new];
    int i = 0;
    for(UIPlayer* p in engin.players) {
        if(p.role == Judge) continue;
        [pIds addObject:p.id];
        [playerVisibleObjects setObject:[NSMutableArray new] forKey:p.id];
        [playerLifeBoxes setObject:[NSMutableArray new] forKey:p.id];
        
        UIView* playerLine = [UIView new];
        playerLine.translatesAutoresizingMaskIntoConstraints = NO;
        [playerLines setObject:playerLine forKey:p.id];
        [self.bodyView addSubview:playerLine];
        
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:playerLine attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0]];
        [playerLine addConstraint:[NSLayoutConstraint constraintWithItem:playerLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(40)]];
        
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:playerLine attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeLeading multiplier:1.f constant:0]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:playerLine attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeTop multiplier:1.f constant:REVERSE(10+40*i)]];
        
        
        UILabel *label = [[UILabel alloc] init];
        label.text = p.name;
        label.font = [UIFont fontWithName:@"Verdana" size:VALUE(16, 12)];
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [playerLine addSubview:label];
        
        [playerLine addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:playerLine attribute:NSLayoutAttributeLeading multiplier:1.f constant:10.f]];
        [playerLine addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:playerLine attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
        
        i++;
    }
    
    return CGSizeMake(0, REVERSE(10+40*i));
}

- (void) initTopBarView {
    [self.hideStateButton addConstraint:[NSLayoutConstraint constraintWithItem:self.hideStateButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(40)]];
    [self.hideStateButton addConstraint:[NSLayoutConstraint constraintWithItem:self.hideStateButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(50)]];
    
    UIButton *quitButton = [UIButton new];
    [quitButton addTarget:self
                   action:@selector(quitButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [quitButton setImage:[UIImage imageNamed:@"quit.png"] forState:UIControlStateNormal];
    [quitButton setImage:[UIImage imageNamed:@"quit-sel.png"] forState:UIControlStateSelected];
    
    [quitButton addConstraint:[NSLayoutConstraint constraintWithItem:quitButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(50)]];
    [quitButton addConstraint:[NSLayoutConstraint constraintWithItem:quitButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(50)]];
    
    quitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topBarView addSubview:quitButton];
    
    [self.topBarView addConstraint:[NSLayoutConstraint constraintWithItem:quitButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self.topBarView addConstraint:[NSLayoutConstraint constraintWithItem:quitButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeLeading multiplier:1.f constant:10.f]];
    
    
    UIButton *redoButton = [UIButton new];
    [redoButton addTarget:self
                   action:@selector(redoButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [redoButton setImage:[UIImage imageNamed:@"redo.png"] forState:UIControlStateNormal];
    [redoButton setImage:[UIImage imageNamed:@"redo-sel.png"] forState:UIControlStateSelected];
    
    [redoButton addConstraint:[NSLayoutConstraint constraintWithItem:redoButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(50)]];
    [redoButton addConstraint:[NSLayoutConstraint constraintWithItem:redoButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(50)]];
    
    redoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topBarView addSubview:redoButton];
    
    [self.topBarView addConstraint:[NSLayoutConstraint constraintWithItem:redoButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self.topBarView addConstraint:[NSLayoutConstraint constraintWithItem:redoButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:-10.f]];
    
    UIButton *undoButton = [UIButton new];
    [undoButton addTarget:self
                   action:@selector(undoButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [undoButton setImage:[UIImage imageNamed:@"undo.png"] forState:UIControlStateNormal];
    [undoButton setImage:[UIImage imageNamed:@"undo-sel.png"] forState:UIControlStateSelected];
    
    [undoButton addConstraint:[NSLayoutConstraint constraintWithItem:undoButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(50)]];
    [undoButton addConstraint:[NSLayoutConstraint constraintWithItem:undoButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(50)]];
    
    undoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topBarView addSubview:undoButton];
    
    [self.topBarView addConstraint:[NSLayoutConstraint constraintWithItem:undoButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self.topBarView addConstraint:[NSLayoutConstraint constraintWithItem:undoButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:redoButton attribute:NSLayoutAttributeLeading multiplier:1.f constant:REVERSE(-20)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addNewStatusWithActorRole: (Role) role andReceiver: (Player*) receiver andResult: (BOOL) result {
    if(!isInitFinished) {
        [self.view layoutIfNeeded];
        isInitFinished = YES;
    }
    
    for(NSMutableArray* visibleObjects in [playerVisibleObjects allValues]) {
        [visibleObjects addObject:[NSMutableArray new]];
    }
    
    int iconSize = 30;
    int marginLeft = 140;
    int lifeBoxHeight = 6;
    
    if(receiver) {
        UIView *playerLine = [playerLines objectForKey:receiver.id];
        NSMutableArray* visibleNodes  = [[playerVisibleObjects objectForKey:receiver.id] lastObject];
        NSMutableArray* lifeBoxes = [playerLifeBoxes objectForKey:receiver.id];
        
        UIImage *iconImage = [UIImage imageNamed: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:role]]];
        UIImageView *icon = [[UIImageView alloc] initWithImage:iconImage];
        
        if(!result) icon.alpha = .3f;
        icon.translatesAutoresizingMaskIntoConstraints = NO;
        [visibleNodes addObject:icon];
        [playerLine addSubview:icon];
        
        [playerLine addConstraint:[NSLayoutConstraint constraintWithItem:icon attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:playerLine attribute:NSLayoutAttributeLeading multiplier:1.f constant:REVERSE(marginLeft+iconSize*lifeBoxes.count)]];
        [playerLine addConstraint:[NSLayoutConstraint constraintWithItem:icon attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:playerLine attribute:NSLayoutAttributeTop multiplier:1.f constant:0]];
        
        
        UIView *lifeBox = [[UIView alloc] init];
        UIColor *color = (receiver.life >= 1) ? [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1] : (receiver.life <= 0) ? [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1] : [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:0.0/255.0 alpha:1];
        
        lifeBox.backgroundColor = color;
        lifeBox.translatesAutoresizingMaskIntoConstraints = NO;
        lifeBox.alpha = (receiver.status == IN_GAME) ? 1.f : .3f;
        
        [visibleNodes addObject:lifeBox];
        [lifeBoxes addObject:lifeBox];
        [playerLine addSubview:lifeBox];
        
        [lifeBox addConstraint:[NSLayoutConstraint constraintWithItem:lifeBox attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(iconSize)]];
        [lifeBox addConstraint:[NSLayoutConstraint constraintWithItem:lifeBox attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(lifeBoxHeight)]];
        
        [playerLine addConstraint:[NSLayoutConstraint constraintWithItem:lifeBox attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:playerLine attribute:NSLayoutAttributeLeading multiplier:1.f constant:REVERSE(marginLeft+iconSize*lifeBoxes.count-iconSize)]];
        [playerLine addConstraint:[NSLayoutConstraint constraintWithItem:lifeBox attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:playerLine attribute:NSLayoutAttributeBottom multiplier:1.f constant:0]];
        
        
        [self updateScrollViewWidth];
    }
    
    if(!receiver || role == Judge) {
        int maxLifeBoxesNumber = 0;
        for(NSString* id in pIds) {
            NSMutableArray* lifeBoxes = [playerLifeBoxes objectForKey:id];
            maxLifeBoxesNumber = (lifeBoxes.count > maxLifeBoxesNumber) ? lifeBoxes.count : maxLifeBoxesNumber;
        }
        int maxCount = 0;
        for(NSString* id in pIds) {
            UIView *playerLine = [playerLines objectForKey:id];
            NSMutableArray* visibleNodes  = [[playerVisibleObjects objectForKey:id] lastObject];
            Player* player = [engin getPlayerById:id];
            NSMutableArray* lifeBoxes = [playerLifeBoxes objectForKey:id];
            maxCount = maxCount < lifeBoxes.count ? lifeBoxes.count : maxCount;
            UIColor *color = lifeBoxes.count > 0 ? ((UIView*)[lifeBoxes lastObject]).backgroundColor : [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1];
            
            if(player.status == IN_GAME) {
                for(;lifeBoxes.count < maxLifeBoxesNumber;) {
                    UIView *lifeBox = [[UIView alloc] init];
                    lifeBox.backgroundColor = color;
                    lifeBox.translatesAutoresizingMaskIntoConstraints = NO;
                    
                    [visibleNodes addObject:lifeBox];
                    [lifeBoxes addObject:lifeBox];
                    [playerLine addSubview:lifeBox];

                    [lifeBox addConstraint:[NSLayoutConstraint constraintWithItem:lifeBox attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(iconSize)]];
                    [lifeBox addConstraint:[NSLayoutConstraint constraintWithItem:lifeBox attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(lifeBoxHeight)]];
                    
                    [playerLine addConstraint:[NSLayoutConstraint constraintWithItem:lifeBox attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:playerLine attribute:NSLayoutAttributeLeading multiplier:1.f constant:REVERSE(marginLeft+iconSize*lifeBoxes.count-iconSize)]];
                    [playerLine addConstraint:[NSLayoutConstraint constraintWithItem:lifeBox attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:playerLine attribute:NSLayoutAttributeBottom multiplier:1.f constant:0]];
                }
            }
            
            for(UIView *lifeBox in lifeBoxes) lifeBox.alpha = (player.status == IN_GAME) ? 1.f : .3f;
        }
        
        if(role == Judge) {
            for(NSString* id in pIds) {
                UIView *playerLine = [playerLines objectForKey:id];
                NSMutableArray* visibleNodes  = [[playerVisibleObjects objectForKey:receiver.id] lastObject];
                UIView *separatorBox = [[UIView alloc] init];
                separatorBox.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1];
                
                separatorBox.translatesAutoresizingMaskIntoConstraints = NO;
                [visibleNodes addObject:separatorBox];
                [playerLine addSubview:separatorBox];
                
                [separatorBox addConstraint:[NSLayoutConstraint constraintWithItem:separatorBox attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:1]];
                [playerLine addConstraint:[NSLayoutConstraint constraintWithItem:separatorBox attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:playerLine attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
                
                [playerLine addConstraint:[NSLayoutConstraint constraintWithItem:separatorBox attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:playerLine attribute:NSLayoutAttributeLeading multiplier:1.f constant:REVERSE(marginLeft+iconSize*maxCount-iconSize)]];
                [playerLine addConstraint:[NSLayoutConstraint constraintWithItem:separatorBox attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:playerLine attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
            }
        }
    }
    
    [self.view layoutIfNeeded];
    
}

-(void) revertStatus {
    for(NSString *id in pIds) {
        UIView *playerLine = [playerLines objectForKey:id];
        NSMutableArray* visibleNodes  = [[playerVisibleObjects objectForKey:id] lastObject];
        NSMutableArray* lifeBoxes = [playerLifeBoxes objectForKey:id];
        Player* player = [engin getPlayerById:id];
        
        [lifeBoxes removeObjectsInArray:visibleNodes];
        
        for(UIView *node in visibleNodes) {
            [node removeFromSuperview];
        }
        
        [[playerVisibleObjects objectForKey:id] removeLastObject];
        
        for(UIView *lifeBox in lifeBoxes) lifeBox.alpha = (player.status == IN_GAME) ? 1.f : .3f;
    }
    
    [self updateScrollViewWidth];
    
    [self.view layoutIfNeeded];
}

- (void)updateScrollViewWidth {
    float iconSize = 30;
    float marginLeft = 140;
    float width = 0;
    
    for(NSString *id in pIds) {
        NSMutableArray* lifeBoxes = [playerLifeBoxes objectForKey:id];
        width = REVERSE(marginLeft+iconSize*lifeBoxes.count) > width ? REVERSE(marginLeft+iconSize*lifeBoxes.count) : width;
    }
    
    [scrollView removeConstraints:bodyViewWidthContraints];
    bodyViewWidthContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[bodyView(width)]|" options:0 metrics:@{@"width":@(width+20)} views:NSDictionaryOfVariableBindings(bodyView)];
    [scrollView addConstraints:bodyViewWidthContraints];
    
    CGPoint offset = scrollView.contentOffset;
    offset.x = width+20;
    [scrollView setContentOffset:offset];
}

- (IBAction)undoButtonTapped:(id)sender {
    [engin action: @"UNDO_ACTION"];
}

- (IBAction)redoButtonTapped:(id)sender {
    [engin action: @"REDO_ACTION"];
}

- (IBAction)quitButtonTapped:(id)sender {
    [((AppController*)[[UIApplication sharedApplication] delegate]).navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)hideStateButtonTapped:(id)sender {
    [((AppController*)[[UIApplication sharedApplication] delegate]).navigationController popViewControllerAnimated:YES];
}
@end
