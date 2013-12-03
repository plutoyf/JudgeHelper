//
//  GameRuleViewController.m
//  JudgeHelper
//
//  Created by YANG FAN on 03/12/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "GameRuleViewController.h"
#import "RuleResolver.h"
#import "AppDelegate.h"
#import "GlobalSettings.h"

@interface GameRuleViewController ()

@end

@implementation GameRuleViewController

NSString *const CONST_ELIGIBILITE_RULES_HEADER = @"==ELIGIBILITY RULES==";
NSString *const CONST_ACTION_RULES_HEADER = @"==ACTION RULES==";
NSString *const CONST_CLEARENCE_RULES_HEADER = @"==CLEARENCE RULES==";
NSString *const CONST_RESULT_RULES_HEADER = @"==RESULT RULES==";

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
    
    engin = [CCEngin getEngin];
    
    [self restoreButtonTapped:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillAppear:(BOOL)flag {
    [super viewWillAppear:flag];
    [self.ruleEditView becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    UIInterfaceOrientation  orientation = [UIDevice currentDevice].orientation;
    BOOL isPortraitMode = (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown);
    float keyboardHeight = isPortraitMode ? keyboardFrame.size.height : keyboardFrame.size.width;
    
    [self.view removeConstraint:self.ruleEditBottomSpaceConstraint];
    self.ruleEditBottomSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.ruleEditView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.f constant:-keyboardHeight];
    [self.view addConstraint:self.ruleEditBottomSpaceConstraint];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)saveButtonTapped:(id)sender {
    NSCharacterSet* charsToTrim = [NSCharacterSet characterSetWithCharactersInString:@" \n"];
    
    NSString* rulesString = self.ruleEditView.text;
    long i0 = [rulesString rangeOfString: CONST_ELIGIBILITE_RULES_HEADER].location;
    long i1 = [rulesString rangeOfString: CONST_ACTION_RULES_HEADER].location;
    long i2 = [rulesString rangeOfString: CONST_CLEARENCE_RULES_HEADER].location;
    long i3 = [rulesString rangeOfString: CONST_RESULT_RULES_HEADER].location;
    NSString* eligibilityRulesString = [[rulesString substringWithRange: NSMakeRange(i0+CONST_ELIGIBILITE_RULES_HEADER.length, i1-i0-CONST_ELIGIBILITE_RULES_HEADER.length)] stringByTrimmingCharactersInSet:charsToTrim];
    NSString* actionRulesString = [[rulesString substringWithRange: NSMakeRange(i1+CONST_ACTION_RULES_HEADER.length, i2-i1-CONST_ACTION_RULES_HEADER.length)] stringByTrimmingCharactersInSet:charsToTrim];
    NSString* clearenceRulesString = [[rulesString substringWithRange: NSMakeRange(i2+CONST_CLEARENCE_RULES_HEADER.length, i3-i2-CONST_CLEARENCE_RULES_HEADER.length)] stringByTrimmingCharactersInSet:charsToTrim];
    NSString* resultRulesString = [[rulesString substringFromIndex: i3+CONST_RESULT_RULES_HEADER.length] stringByTrimmingCharactersInSet:charsToTrim];
    engin.eligibilityRulesString = eligibilityRulesString;
    engin.actionRulesString = actionRulesString;
    engin.clearenceRulesString = clearenceRulesString;
    engin.resultRulesString = resultRulesString;
    [engin setEligibilityRules: [RuleResolver resolveRules: eligibilityRulesString]];
    [engin setActionRules: [RuleResolver resolveRules: actionRulesString]];
    [engin setClearenceRules: [RuleResolver resolveRules: clearenceRulesString]];
    [engin setResultRules: [RuleResolver resolveRules: resultRulesString]];
    [self cancelButtonTapped:nil];
}

- (IBAction)cancelButtonTapped:(id)sender {
    [((AppController*)[[UIApplication sharedApplication] delegate]).navigationController popViewControllerAnimated:YES];
}

- (IBAction)restoreButtonTapped:(id)sender {
    NSString* rulesString= @"";
    
    rulesString = [[rulesString stringByAppendingString: CONST_ELIGIBILITE_RULES_HEADER] stringByAppendingString: @"\n"];
    NSString* eligibilityRulesString = engin.eligibilityRulesString;
    if(!eligibilityRulesString) {
        eligibilityRulesString = @"";
        for(NSString* r in [CCEngin getEligibilityRulesArray]) {
            eligibilityRulesString = [[eligibilityRulesString stringByAppendingString: r] stringByAppendingString: @"\n"];
        }
    }
    rulesString = [[rulesString stringByAppendingString: eligibilityRulesString] stringByAppendingString: @"\n"];
    
    rulesString = [[rulesString stringByAppendingString: CONST_ACTION_RULES_HEADER] stringByAppendingString: @"\n" ];
    NSString* actionRulesString = engin.actionRulesString;
    if(!actionRulesString) {
        actionRulesString = @"";
        for(NSString* r in [CCEngin getActionRulesArray]) {
            actionRulesString = [[actionRulesString stringByAppendingString: r] stringByAppendingString: @"\n"];
        }
    }
    rulesString = [[rulesString stringByAppendingString: actionRulesString] stringByAppendingString: @"\n"];
    
    rulesString = [[rulesString stringByAppendingString: CONST_CLEARENCE_RULES_HEADER] stringByAppendingString: @"\n" ];
    NSString* clearenceRulesString = engin.clearenceRulesString;
    if(!clearenceRulesString) {
        clearenceRulesString = @"";
        for(NSString* r in [CCEngin getClearenceRulesArray]) {
            clearenceRulesString = [[clearenceRulesString stringByAppendingString: r] stringByAppendingString: @"\n"];
        }
    }
    rulesString = [[rulesString stringByAppendingString: clearenceRulesString] stringByAppendingString: @"\n"];
    
    rulesString = [[rulesString stringByAppendingString: CONST_RESULT_RULES_HEADER] stringByAppendingString: @"\n"];
    NSString* resultRulesString = engin.resultRulesString;
    if(!resultRulesString) {
        resultRulesString = @"";
        for(NSString* r in [CCEngin getResultRulesArray]) {
            resultRulesString = [[resultRulesString stringByAppendingString: r] stringByAppendingString: @"\n"];
        }
    }
    rulesString = [[rulesString stringByAppendingString: resultRulesString] stringByAppendingString: @"\n"];
    
    self.ruleEditView.text = rulesString;
}

- (IBAction)cocos2dModeSwitchChanged:(id)sender {
    GlobalSettings *globalSettings = [GlobalSettings globalSettings];
    [globalSettings setDisplayMode: self.cocos2dModeSwitch.on ? COCOS2D : UIKIT];
}

@end
