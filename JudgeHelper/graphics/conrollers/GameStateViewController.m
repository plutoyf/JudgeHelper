//
//  GameStateViewController.m
//  JudgeHelper
//
//  Created by YANG FAN on 01/12/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "GameStateViewController.h"
#import "DeviceSettings.h"
#import "AppDelegate.h"
#import "CCEngin.h"

@implementation GameStateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.hideStateButton addConstraint:[NSLayoutConstraint constraintWithItem:self.hideStateButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(40)]];
    [self.hideStateButton addConstraint:[NSLayoutConstraint constraintWithItem:self.hideStateButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(50)]];

    
    UIButton *undoButton = [UIButton new];
    [undoButton addTarget:self
                   action:@selector(undoButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [undoButton setImage:[UIImage imageNamed:@"undo.png"] forState:UIControlStateNormal];
    [undoButton setImage:[UIImage imageNamed:@"undo-sel.png"] forState:UIControlStateSelected];
    
    [undoButton addConstraint:[NSLayoutConstraint constraintWithItem:undoButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(40)]];
    [undoButton addConstraint:[NSLayoutConstraint constraintWithItem:undoButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(40)]];
    
    undoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:undoButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:undoButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:undoButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
    
    
    UIButton *redoButton = [UIButton new];
    [redoButton addTarget:self
                   action:@selector(redoButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [redoButton setImage:[UIImage imageNamed:@"redo.png"] forState:UIControlStateNormal];
    [redoButton setImage:[UIImage imageNamed:@"redo-sel.png"] forState:UIControlStateSelected];
    
    [redoButton addConstraint:[NSLayoutConstraint constraintWithItem:redoButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(40)]];
    [redoButton addConstraint:[NSLayoutConstraint constraintWithItem:redoButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(40)]];
    
    redoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:redoButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:redoButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:redoButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:undoButton attribute:NSLayoutAttributeTrailing multiplier:1.f constant:REVERSE(20)]];
    
    
    UIButton *quitButton = [UIButton new];
    [quitButton addTarget:self
                   action:@selector(quitButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [quitButton setImage:[UIImage imageNamed:@"quit.png"] forState:UIControlStateNormal];
    [quitButton setImage:[UIImage imageNamed:@"quit-sel.png"] forState:UIControlStateSelected];
    
    [quitButton addConstraint:[NSLayoutConstraint constraintWithItem:quitButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(40)]];
    [quitButton addConstraint:[NSLayoutConstraint constraintWithItem:quitButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(40)]];
    
    quitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:quitButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:quitButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:quitButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:redoButton attribute:NSLayoutAttributeTrailing multiplier:1.f constant:REVERSE(20)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)undoButtonTapped:(id)sender {
    [[CCEngin getEngin] action: @"UNDO_ACTION"];
}

- (IBAction)redoButtonTapped:(id)sender {
    [[CCEngin getEngin] action: @"REDO_ACTION"];
}

- (IBAction)quitButtonTapped:(id)sender {
    [((AppController*)[[UIApplication sharedApplication] delegate]).navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)hideStateButtonTapped:(id)sender {
    [((AppController*)[[UIApplication sharedApplication] delegate]).navigationController popViewControllerAnimated:YES];
}
@end
