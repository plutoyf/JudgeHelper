//
//  GameRuleLayer.m
//  JudgeHelper
//
//  Created by YANG FAN on 16/08/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "GameRuleLayer.h"
#import "CCNode+SFGestureRecognizers.h"
#import "RuleResolver.h"

@implementation GameRuleLayer

NSString *const ELIGIBILITE_RULES_HEADER = @"==ELIGIBILITY RULES==";
NSString *const ACTION_RULES_HEADER = @"==ACTION RULES==";
NSString *const CLEARENCE_RULES_HEADER = @"==CLEARENCE RULES==";
NSString *const RESULT_RULES_HEADER = @"==RESULT RULES==";

-(id) init {
    if(self = [super init]) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        self.contentSize = size;
        
        engin = [CCEngin getEngin];
        
        _position = ccp(size.width/2, size.height/2);
        
        //init
        rulesTextView = [[UITextView alloc] initWithFrame: CGRectMake(0,0, size.width, REVERSE_Y(300))];
        rulesTextView.textAlignment = NSTextAlignmentLeft;
        [rulesTextView setDelegate:self];
        [self restore:nil];
        [[[CCDirector sharedDirector] openGLView] addSubview:rulesTextView];
        
        saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [saveButton setFrame: CGRectMake(0, REVERSE_Y(310), VALUE(100, 60), REVERSE_Y(30))];
        [saveButton setTitle: @"Save" forState: UIControlStateNormal];
        [saveButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
        [[[CCDirector sharedDirector] openGLView] addSubview:saveButton];
        
        cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cancelButton setFrame: CGRectMake(VALUE(110, 65), REVERSE_Y(310), VALUE(100, 60), REVERSE_Y(30))];
        [cancelButton setTitle: @"Cancel" forState: UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [[[CCDirector sharedDirector] openGLView] addSubview:cancelButton];
        
        restoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [restoreButton setFrame: CGRectMake(VALUE(220, 130), REVERSE_Y(310), VALUE(100, 60), REVERSE_Y(30))];
        [restoreButton setTitle: @"Restore" forState: UIControlStateNormal];
        [restoreButton addTarget:self action:@selector(restore:) forControlEvents:UIControlEventTouchUpInside];
        [[[CCDirector sharedDirector] openGLView] addSubview:restoreButton];

    }
    
    return self;
}

-(void) save:(id) sender {
    NSCharacterSet* charsToTrim = [NSCharacterSet characterSetWithCharactersInString:@" \n"];
    
    NSString* rulesString = rulesTextView.text;
    long i0 = [rulesString rangeOfString: ELIGIBILITE_RULES_HEADER].location;
    long i1 = [rulesString rangeOfString: ACTION_RULES_HEADER].location;
    long i2 = [rulesString rangeOfString: CLEARENCE_RULES_HEADER].location;
    long i3 = [rulesString rangeOfString: RESULT_RULES_HEADER].location;
    NSString* eligibilityRulesString = [[rulesString substringWithRange: NSMakeRange(i0+ELIGIBILITE_RULES_HEADER.length, i1-i0-ELIGIBILITE_RULES_HEADER.length)] stringByTrimmingCharactersInSet:charsToTrim];
    NSString* actionRulesString = [[rulesString substringWithRange: NSMakeRange(i1+ACTION_RULES_HEADER.length, i2-i1-ACTION_RULES_HEADER.length)] stringByTrimmingCharactersInSet:charsToTrim];
    NSString* clearenceRulesString = [[rulesString substringWithRange: NSMakeRange(i2+CLEARENCE_RULES_HEADER.length, i3-i2-CLEARENCE_RULES_HEADER.length)] stringByTrimmingCharactersInSet:charsToTrim];
    NSString* resultRulesString = [[rulesString substringFromIndex: i3+RESULT_RULES_HEADER.length] stringByTrimmingCharactersInSet:charsToTrim];
    engin.eligibilityRulesString = eligibilityRulesString;
    engin.actionRulesString = actionRulesString;
    engin.clearenceRulesString = clearenceRulesString;
    engin.resultRulesString = resultRulesString;
    [engin setEligibilityRules: [RuleResolver resolveRules: eligibilityRulesString]];
    [engin setActionRules: [RuleResolver resolveRules: actionRulesString]];
    [engin setClearenceRules: [RuleResolver resolveRules: clearenceRulesString]];
    [engin setResultRules: [RuleResolver resolveRules: resultRulesString]];
    [self cancel:nil];
}

-(void) cancel:(id) sender {
    [rulesTextView removeFromSuperview];
    [saveButton removeFromSuperview];
    [cancelButton removeFromSuperview];
    [restoreButton removeFromSuperview];
}

-(void) restore:(id) sender {
    NSString* rulesString= @"";
    
    rulesString = [[rulesString stringByAppendingString: ELIGIBILITE_RULES_HEADER] stringByAppendingString: @"\n"];
    NSString* eligibilityRulesString = engin.eligibilityRulesString;
    if(!eligibilityRulesString) {
        eligibilityRulesString = @"";
        for(NSString* r in [CCEngin getEligibilityRulesArray]) {
            eligibilityRulesString = [[eligibilityRulesString stringByAppendingString: r] stringByAppendingString: @"\n"];
        }
    }
    rulesString = [[rulesString stringByAppendingString: eligibilityRulesString] stringByAppendingString: @"\n"];
    
    rulesString = [[rulesString stringByAppendingString: ACTION_RULES_HEADER] stringByAppendingString: @"\n" ];
    NSString* actionRulesString = engin.actionRulesString;
    if(!actionRulesString) {
        actionRulesString = @"";
        for(NSString* r in [CCEngin getActionRulesArray]) {
            actionRulesString = [[actionRulesString stringByAppendingString: r] stringByAppendingString: @"\n"];
        }
    }
    rulesString = [[rulesString stringByAppendingString: actionRulesString] stringByAppendingString: @"\n"];
    
    rulesString = [[rulesString stringByAppendingString: CLEARENCE_RULES_HEADER] stringByAppendingString: @"\n" ];
    NSString* clearenceRulesString = engin.clearenceRulesString;
    if(!clearenceRulesString) {
        clearenceRulesString = @"";
        for(NSString* r in [CCEngin getClearenceRulesArray]) {
            clearenceRulesString = [[clearenceRulesString stringByAppendingString: r] stringByAppendingString: @"\n"];
        }
    }
    rulesString = [[rulesString stringByAppendingString: clearenceRulesString] stringByAppendingString: @"\n"];
    
    rulesString = [[rulesString stringByAppendingString: RESULT_RULES_HEADER] stringByAppendingString: @"\n"];
    NSString* resultRulesString = engin.resultRulesString;
    if(!resultRulesString) {
        resultRulesString = @"";
        for(NSString* r in [CCEngin getResultRulesArray]) {
            resultRulesString = [[resultRulesString stringByAppendingString: r] stringByAppendingString: @"\n"];
        }
    }
    rulesString = [[rulesString stringByAppendingString: resultRulesString] stringByAppendingString: @"\n"];
    
    rulesTextView.text = rulesString;
}

@end
