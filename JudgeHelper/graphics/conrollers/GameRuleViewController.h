//
//  GameRuleViewController.h
//  JudgeHelper
//
//  Created by YANG FAN on 03/12/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCEngin.h"

@interface GameRuleViewController : UIViewController {
    CCEngin* engin;
}

@property (weak, nonatomic) IBOutlet UITextView *ruleEditView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ruleEditBottomSpaceConstraint;
@property (weak, nonatomic) IBOutlet UISwitch *cocos2dModeSwitch;

- (IBAction)saveButtonTapped:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)restoreButtonTapped:(id)sender;
- (IBAction)cocos2dModeSwitchChanged:(id)sender;

@end
