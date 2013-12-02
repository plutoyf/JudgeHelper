//
//  MainMenuViewController.m
//  JudgeHelper
//
//  Created by fyang on 14/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "MainViewController.h"
#import "GameLayer.h"
#import "AppDelegate.h"
#import "GlobalSettings.h"
#import "PlayerTableViewCell.h"
#import "PlayerCollectionViewCell.h"
#import "RoleCollectionViewCell.h"
#import "PlayerCreationView.h"
#import "CCEngin.h"
#import "Role.h"
#import "GameViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

// Add new method
- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ((AppController*)[[UIApplication sharedApplication] delegate]).navigationController = self.navigationController;
    
    selectedPIds = [NSMutableArray new];
    [self initPlayerIds];
    
    //bouchon
    for(int i = 0; i<6; i++) {
        [selectedPIds addObject:[pids objectAtIndex:i]];
    }
    
    [self initRoles];
    [self selectRole:Judge];
    
    GlobalSettings *globals = [GlobalSettings globalSettings];
    self.doubleHandModeSwitch.on = [globals getGameMode] == DOUBLE_HAND;
    
    [self initLayoutConstraints];
    
    [self.playerCollectionView registerNib:[UINib nibWithNibName:@"PlayerCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"playerCollectionViewCell"];
    [self.roleCollectionView registerNib:[UINib nibWithNibName:@"RoleCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"roleCollectionViewCell"];
}

- (void) initLayoutConstraints {
    if(IS_IPAD()) {
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRoleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.5f constant:0.f]];
         [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRoleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:0.5f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftPlayerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.5f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftPlayerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:0.5f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightPlayerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.5f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightPlayerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:0.5f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRoleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.5f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRoleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:0.5f constant:0.f]];
        
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRoleView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftPlayerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightPlayerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRoleView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
          
        NSLayoutConstraint *contraint = [self findConstraintWithItem:self.doubleHandModeLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeLeading from:self.topBarView.constraints];
        contraint.constant += self.createPlayerButton.frame.size.width + 20;
        
        self.doubleHandModeLabel.alpha = 1.f;
        self.doubleHandModeSwitch.alpha = 1.f;
        
        self.view.tag = 3;
        [self.nextButton setTitle:@"开始" forState:UIControlStateNormal];
    } else {
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRoleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.4f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRoleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftPlayerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.4f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftPlayerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightPlayerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.6f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightPlayerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRoleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.6f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRoleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
        
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRoleView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftPlayerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightPlayerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRoleView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];

    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if(!IS_IPAD()) {
        UIInterfaceOrientation  orientation = [UIDevice currentDevice].orientation;
        BOOL isPortraitMode = (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown);
        float percentage = isPortraitMode ? 0.5 : 0.4;
        
        [self.bodyView removeConstraint: [self findConstraintWithItem:self.leftRoleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth from:self.bodyView.constraints]];
        [self.bodyView removeConstraint: [self findConstraintWithItem:self.leftPlayerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth from:self.bodyView.constraints]];
        [self.bodyView removeConstraint: [self findConstraintWithItem:self.rightPlayerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth from:self.bodyView.constraints]];
        [self.bodyView removeConstraint: [self findConstraintWithItem:self.rightRoleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth from:self.bodyView.constraints]];
        
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRoleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:percentage constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftPlayerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:percentage constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightPlayerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:1-percentage constant:0.f]];
        [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRoleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:1-percentage constant:0.f]];
        
        
        [self.bodyView layoutIfNeeded];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Replace this method
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)nextButtonTapped:(id)sender {
    GlobalSettings* global = [GlobalSettings globalSettings];
    [global setPlayerIds: selectedPIds];

    BOOL isReadyToStart = NO;
    switch (self.view.tag) {
        case 0:
            if (selectedPIds.count < 3) {
                self.statusLabel.text = @"请至少选择3名玩家";
            } else {
                isReadyToStart = [self isRedyToStart];
                self.view.tag = isReadyToStart ? 2 : 1;
                [self.nextButton setTitle:isReadyToStart ? @"开始" : @"下一步" forState:UIControlStateNormal];
                self.createPlayerButton.alpha = 0.0f;
                self.doubleHandModeLabel.alpha = 1.0f;
                self.doubleHandModeSwitch.alpha = 1.0f;
                [self matchPlayerNumber];
                [self animateViewWithLeftPart:!isReadyToStart andRightPart:YES];
            }
            break;
        case 1:
            self.view.tag = 2;
            [self.nextButton setTitle:@"开始" forState:UIControlStateNormal];
            [self matchPlayerNumber];
            [self animateViewWithLeftPart:YES andRightPart:NO];
            break;
        case 3:
            if (selectedPIds.count < 3) {
                self.statusLabel.text = @"请至少选择3名玩家";
                break;
            } else {
                [self matchPlayerNumber];
            }
        case 2:
            if ([self isRedyToStart]) {
                CCDirector *director = [CCDirector sharedDirector];
                if(director.runningScene != nil) {
                    [director replaceScene:[GameLayer scene]];
                }
                
                UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
                if( interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
                    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
                    rotationTransform = CGAffineTransformRotate(rotationTransform, (-90*M_PI)/180.0);
                    director.view.transform = rotationTransform;
                } else {
                    director.view.transform = CGAffineTransformIdentity;
                }
                
                [engin initRoles: roleNumbers];
                //[self.navigationController pushViewController:director animated:YES];
                [self.navigationController pushViewController:[GameViewController new] animated:YES];
            }
            break;
        default:
            break;
    }
}

- (IBAction)createPlayerButtonTapped:(id)sender {
    // Declaring the popover layer
    PlayerCreationView *playerCreationView = [[[NSBundle mainBundle] loadNibNamed:@"PlayerCreationView" owner:self options:nil] objectAtIndex:0];
    
    playerCreationView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bodyView addSubview:playerCreationView];
    
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:playerCreationView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:playerCreationView.frame.size.height]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:playerCreationView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:playerCreationView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.f]];
    __block NSLayoutConstraint *playerCreationViewYConstraint = [NSLayoutConstraint constraintWithItem:playerCreationView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f];
    [self.bodyView addConstraint:playerCreationViewYConstraint];
    [self.bodyView layoutIfNeeded];
    
    
    //playerCreationView.layer.borderWidth = 1.0f;
    //playerCreationView.layer.borderColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f] CGColor];
    playerCreationView.playerImage.layer.borderWidth = 1.0f;
    playerCreationView.playerImage.layer.borderColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f] CGColor];
    
    playerCreationView.playerImage.layer.cornerRadius = 0.6f;
    playerCreationView.playerImage.clipsToBounds = YES;
    
    playerCreationView.shieldView = [[UIView alloc] initWithFrame:self.view.bounds];
    playerCreationView.shieldView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    playerCreationView.shieldView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.bodyView insertSubview:playerCreationView.shieldView belowSubview:playerCreationView];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:playerCreationView.shieldView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:playerCreationView.shieldView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:1.f constant:self.topBarView.frame.size.height+self.bottomBarView.frame.size.height]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:playerCreationView.shieldView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.f]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:playerCreationView.shieldView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.f]];
    [self.bodyView layoutIfNeeded];
    
    self.createPlayerButton.alpha = 0.0f;
    self.nextButton.alpha = 0.0f;
    [UIView animateWithDuration:.5 animations:^(void) {
        [self.bodyView removeConstraint:playerCreationViewYConstraint];
        playerCreationViewYConstraint = [NSLayoutConstraint constraintWithItem:playerCreationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f];
        [self.bodyView addConstraint:playerCreationViewYConstraint];
        [self.bodyView layoutIfNeeded];
    } completion:^(BOOL Finished) {
    }];
}

- (IBAction)doubleHandModeSwitchChanged:(id)sender {
    GlobalSettings *globals = [GlobalSettings globalSettings];
    if(self.doubleHandModeSwitch.on) {
        [globals setGameMode:DOUBLE_HAND];
    } else {
        [globals setGameMode:NORMAL];
    }
    [self matchPlayerNumber];
}

- (NSLayoutConstraint*)findConstraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 from:(NSArray*)contraints {
    for(NSLayoutConstraint *c in contraints) {
        if(c.firstItem == view1 && c.firstAttribute == attr1 && c.relation == relation && c.secondItem == view2 && c.secondAttribute == attr2) {
            return c;
        }
    }
    return nil;
}

- (void) animateViewWithLeftPart:(BOOL) animateLeftPartView andRightPart:(BOOL) animateRightPartView {
    NSLayoutConstraint *leftPartConstraintToDelete, *leftPartConstraintToAdd, *rightPartConstraintToDelete, *rightPartConstraintToAdd;
    UIView *leftPartView, *rightPartView;
    
    if (animateLeftPartView) {
        leftPartView = self.leftPlayerView.tag == 1 ? self.leftPlayerView : self.leftRoleView;
        leftPartConstraintToDelete = [self findConstraintWithItem:leftPartView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeLeading from:self.bodyView.constraints];
        leftPartConstraintToAdd = [NSLayoutConstraint constraintWithItem:leftPartView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f];
        leftPartView.tag = 0;
    }
    
    if (animateRightPartView) {
        rightPartView = self.rightPlayerView.tag == 1 ? self.rightPlayerView : self.rightRoleView;
        rightPartConstraintToDelete = [self findConstraintWithItem:rightPartView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeTrailing from:self.bodyView.constraints];
        rightPartConstraintToAdd = [NSLayoutConstraint constraintWithItem:rightPartView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f];
        rightPartView.tag = 0;
    }
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:0.5 animations:^{
        if (animateLeftPartView) {
            [self.bodyView removeConstraint:leftPartConstraintToDelete];
            [self.bodyView addConstraint:leftPartConstraintToAdd];
            [self.view layoutIfNeeded];
        }
        
        if (animateRightPartView) {
            [self.bodyView removeConstraint:rightPartConstraintToDelete];
            [self.bodyView addConstraint:rightPartConstraintToAdd];
            [self.view layoutIfNeeded];
        }
    }];
     
    if (animateLeftPartView) {
        leftPartView = leftPartView == self.leftPlayerView ? self.leftRoleView : self.leftPlayerView;
        leftPartConstraintToDelete = [self findConstraintWithItem:leftPartView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeLeading from:self.bodyView.constraints];
        leftPartConstraintToAdd = [NSLayoutConstraint constraintWithItem:leftPartView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f];
        leftPartView.tag = 1;
    }
    
    if (animateRightPartView) {
        rightPartView = rightPartView == self.rightPlayerView ? self.rightRoleView : self.rightPlayerView;
        rightPartConstraintToDelete = [self findConstraintWithItem:rightPartView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeTrailing from:self.bodyView.constraints];
        rightPartConstraintToAdd = [NSLayoutConstraint constraintWithItem:rightPartView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f];
        rightPartView.tag = 1;
    }
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView animateWithDuration:0.5 delay:0.5 options:nil animations:^{
        if (animateLeftPartView) {
            [self.bodyView removeConstraint:leftPartConstraintToDelete];
            [self.bodyView addConstraint:leftPartConstraintToAdd];
            [self.view layoutIfNeeded];
        }
        
        if (animateRightPartView) {
            [self.bodyView removeConstraint:rightPartConstraintToDelete];
            [self.bodyView addConstraint:rightPartConstraintToAdd];
            [self.view layoutIfNeeded];
        }
    } completion:nil];
}


-(void) initPlayerIds {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    id obj = [userDefaults objectForKey:@"pids"];
    pids = obj==nil ? [NSMutableArray new] : [NSMutableArray arrayWithArray:obj];
}

- (void) initRoles {
    GlobalSettings *global = [GlobalSettings globalSettings];
    
    engin = [CCEngin getEngin];
    roles = [global getRoles] ? [global getRoles] : engin.roles;
    roleNumbers = [NSMutableDictionary dictionaryWithDictionary: [global getRoleNumbers] ? [global getRoleNumbers] : engin.roleNumbers];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return pids.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"playerTableViewCell";
    
    PlayerTableViewCell *cell = [self.playerTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PlayerTableViewCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects) {
            if([currentObject isKindOfClass:[PlayerTableViewCell class]]) {
                cell = (PlayerTableViewCell *)currentObject;
                break;
            }
        }
    }
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* pid = [pids objectAtIndex:indexPath.row];
    NSString* name = [userDefaults stringForKey:[pid stringByAppendingString:@"-name"]];
    NSData* imgData = [userDefaults dataForKey:[pid stringByAppendingString:@"-img"]];
    UIImage* image = [UIImage imageWithData:imgData];
    
    cell.userId = pid;
    cell.userImage.image = image;
    cell.userName.text = name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerTableViewCell *cell = (PlayerTableViewCell *)[self.playerTableView cellForRowAtIndexPath:indexPath];
    if(![selectedPIds containsObject:cell.userId]) {
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexPaths addObject:[NSIndexPath indexPathForRow:selectedPIds.count inSection:0]];
        [selectedPIds addObject:cell.userId];
        [self.playerCollectionView performBatchUpdates:^{
            [self.playerCollectionView insertItemsAtIndexPaths:indexPaths];
        }
        completion: ^(BOOL finished){
            int numberOfItems = [self.playerCollectionView numberOfItemsInSection:0];
            if(numberOfItems > 0) {
                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:numberOfItems-1 inSection:0];
                [self.playerCollectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerTableViewCell *cell = (PlayerTableViewCell *)[self.playerTableView cellForRowAtIndexPath:indexPath];
    [self deselectPlayer:cell.userId];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PlayerTableViewCell *cell = (PlayerTableViewCell *)[self.playerTableView cellForRowAtIndexPath:indexPath];
        NSString *pid = cell.userId;
        [self deselectPlayer:pid];
        [pids removeObject:pid];

        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:pids forKey:@"pids"];
        [userDefaults removeObjectForKey:[pid stringByAppendingString:@"-name"]];
        [userDefaults removeObjectForKey:[pid stringByAppendingString:@"-img"]];
        [userDefaults synchronize];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self reselectPlayersInTableView:tableView];
     NSLog(@"didEndEditingRowAtIndexPath : %d",indexPath.row);
}

- (void) didFinishedCreatingPlayerWithId:(NSString *)pid {
    self.createPlayerButton.alpha = 1.0f;
    self.nextButton.alpha = 1.0f;
    if(pid && ![pids containsObject:pid]) {
        [pids addObject:pid];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pids.count-1 inSection:0];
        [self.playerTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.playerTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    [self reselectPlayersInTableView:self.playerTableView];
}

- (void) reselectPlayersInTableView:(UITableView*)tableView {
    for (NSString *pid in selectedPIds) {
        int i = [pids indexOfObject:pid];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)deselectPlayer: (NSString *) pid {
    if([selectedPIds containsObject:pid]) {
        int i = [selectedPIds indexOfObject:pid];
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        [selectedPIds removeObjectAtIndex:i];
        [self.playerCollectionView deleteItemsAtIndexPaths:indexPaths];
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.playerCollectionView) {
        return selectedPIds.count;
    } else {
        return roles.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.playerCollectionView) {
        PlayerCollectionViewCell *cell = (PlayerCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"playerCollectionViewCell" forIndexPath:indexPath];
        
        if (cell.gestureRecognizers.count == 0) {
            [cell addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(playerCellTapped:)]];
        }
        
        NSString *pid = [selectedPIds objectAtIndex:indexPath.row];
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        NSString* name = [userDefaults stringForKey:[pid stringByAppendingString:@"-name"]];
        NSData* imgData = [userDefaults dataForKey:[pid stringByAppendingString:@"-img"]];
        UIImage* image = [UIImage imageWithData:imgData];
        
        cell.userName.text = name;
        cell.userImage.image = image;
        
        return cell;
    } else {
        RoleCollectionViewCell *cell = (RoleCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"roleCollectionViewCell" forIndexPath:indexPath];
        
        if (cell.gestureRecognizers.count == 0) {
            [cell addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(roleCellTapped:)]];
        }
        
        Role r = [Engin getRoleFromString:[roles objectAtIndex:indexPath.row]];
        UIImage *image = [UIImage imageNamed: [[@"Icon-72-" stringByAppendingString: [CCEngin getRoleCode:r ]] stringByAppendingString: @".png"]];
        
        cell.role = r;
        cell.roleImage.image = image;
        cell.roleLabel.text = [CCEngin getRoleLabel:r];
        cell.roleNumber.text = [NSString stringWithFormat:@"%d", ((NSNumber*)[roleNumbers objectForKey:[CCEngin getRoleName:r]]).intValue];
        
        return cell;
    }
    
}

- (void)playerCellTapped:(UITapGestureRecognizer *)inGestureRecognizer {
    if (self.view.tag == 2) {
        self.view.tag = 0;
        [self.nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        self.createPlayerButton.alpha = 1.0f;
        self.doubleHandModeLabel.alpha = 0.0f;
        self.doubleHandModeSwitch.alpha = 0.0f;
        [self animateViewWithLeftPart:self.leftPlayerView.tag!=1 andRightPart:self.rightPlayerView.tag!=1];
    } else {
        NSIndexPath *indexPath = [self.playerCollectionView indexPathForCell:(UICollectionViewCell *)inGestureRecognizer.view];
        
        NSString *pid = [selectedPIds objectAtIndex:indexPath.row];
        
        NSIndexPath *tableViewCellIndexPath = [NSIndexPath indexPathForRow:[pids indexOfObject:pid] inSection:0];
        [self.playerTableView deselectRowAtIndexPath:tableViewCellIndexPath animated:YES];
        [self deselectPlayer:pid];
    }
}

- (void)roleCellTapped:(UITapGestureRecognizer *)inGestureRecognizer {
    NSIndexPath *indexPath = [self.roleCollectionView indexPathForCell:(UICollectionViewCell *)inGestureRecognizer.view];
    
    RoleCollectionViewCell *cell = (RoleCollectionViewCell *)[self.roleCollectionView cellForItemAtIndexPath:indexPath];
    
    int row = [roles indexOfObject:[Engin getRoleName:cell.role]];
    [self.roleNumberPicker selectRow:row inComponent:0 animated:YES];
    [self selectRole:cell.role];
    
    if (self.view.tag == 2) {
        self.view.tag = 1;
        [self.nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        [self animateViewWithLeftPart:self.leftRoleView.tag!=1 andRightPart:self.rightRoleView.tag!=1];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
    return component == 0 ? roles.count : maxRoleNumber;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        Role r = [Engin getRoleFromString:[roles objectAtIndex:row]];
        return [CCEngin getRoleLabel:r];
    } else {
        return [NSString stringWithFormat:@"%d", maxRoleNumber==1 ? staticRoleNumber : row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    Role r = [Engin getRoleFromString:[roles objectAtIndex:[pickerView selectedRowInComponent:0]]];
    if (component == 0) {
        [self selectRole:r];
    } else {
        [self setNumber:(maxRoleNumber==1 ? staticRoleNumber : row) forRole:r];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    switch (component){
        case 0:
            return 100.0f;
        case 1:
            return 50.0f;
    }
    return 0;
}

- (void) selectRole:(Role) r {
    if (r == Judge) {
        maxRoleNumber = 1;
        staticRoleNumber = ((NSNumber*)[roleNumbers objectForKey:[CCEngin getRoleName:r]]).intValue;
    } else {
        maxRoleNumber = 100;
    }
    [self.roleNumberPicker reloadComponent:1];
    
    UIImage *image = [UIImage imageNamed: [[@"Icon-72-" stringByAppendingString: [CCEngin getRoleCode:r]] stringByAppendingString: @".png"]];
    self.roleImageView.image = image;
    
    for (int i = 0; i<roles.count; i++) {
        RoleCollectionViewCell *cell = (RoleCollectionViewCell *)[self.roleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        cell.roleLabel.textColor = cell.role==r ? [UIColor redColor] : [UIColor blackColor];
    }
    
    [self.roleNumberPicker selectRow:((NSNumber*)[roleNumbers objectForKey:[CCEngin getRoleName:r]]).intValue inComponent:1 animated:YES];
}

- (void) setNumber:(int) num forRole:(Role) r {
    [roleNumbers setObject: [NSNumber numberWithInt:num] forKey:[CCEngin getRoleName:r]];
    
    RoleCollectionViewCell *cell = (RoleCollectionViewCell *)[self.roleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[roles indexOfObject:[Engin getRoleName:r]] inSection:0]];
    cell.roleNumber.text = [NSString stringWithFormat:@"%d", num];
    
    [self matchPlayerNumber];
}

-(int) getPlayerNumberDelta {
    NSArray* ids = [[GlobalSettings globalSettings] getPlayerIds];
    
    int rNum = 0;
    for(NSNumber* n in roleNumbers.allValues) {
        rNum += n.intValue;
    }
    
    GlobalSettings* global = [GlobalSettings globalSettings];
    int pNum = [global getGameMode] == NORMAL ? ids.count : ids.count*2-1;
    
    return rNum - pNum;
}

-(void) matchPlayerNumber {
    int delta = [self getPlayerNumberDelta];
    
    if(delta < 0) {
        self.statusLabel.text = [NSString stringWithFormat:@"角色数目过少, 请再添加%d个角色", -delta];
    } else if (delta > 0) {
        self.statusLabel.text = [NSString stringWithFormat:@"角色数目过多, 请再减少%d个角色", delta];
    } else {
        self.statusLabel.text = @"可以开始游戏";
    }
}

-(BOOL) isRedyToStart {
    return [self getPlayerNumberDelta]==0;
}


@end
