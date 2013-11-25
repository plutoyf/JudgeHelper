//
//  MainViewControllerIPadViewController.m
//  JudgeHelper
//
//  Created by fyang on 22/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "MainViewController~ipad.h"

@interface MainViewController (ipad)

@end

@implementation MainViewController (ipad)

- (void) initLayoutConstraints {
    
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRoleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.5f constant:0.f]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRoleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:0.5f constant:0.f]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftPlayerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.5f constant:0.f]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftPlayerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:0.5f constant:0.f]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightPlayerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.5f constant:0.f]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightPlayerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:0.5f constant:0.f]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRoleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeWidth multiplier:0.5f constant:0.f]];
    [self.bodyView addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRoleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.bodyView attribute:NSLayoutAttributeHeight multiplier:0.5f constant:0.f]];
    
    NSLayoutConstraint *contraint = [self findConstraintWithItem:self.doubleHandModeLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeLeading from:self.topBarView.constraints];
    contraint.constant += self.createPlayerButton.frame.size.width + 20;
    self.doubleHandModeLabel.alpha = 1.f;
    self.doubleHandModeSwitch.alpha = 1.f;
    
    self.view.tag = 3;
    [self.nextButton setTitle:@"开始" forState:UIControlStateNormal];
}
@end
