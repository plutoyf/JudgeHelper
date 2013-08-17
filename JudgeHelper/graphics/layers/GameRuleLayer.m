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

-(id) init {
    if(self = [super init]) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        self.contentSize = size;
        
        engin = [CCEngin getEngin];
        
        _position = ccp(size.width/2, size.height/2);
        
        //init
        rulesTextView = [[UITextView alloc] initWithFrame: CGRectMake(0,0, size.width, 200)];
        rulesTextView.textAlignment = NSTextAlignmentLeft;
        NSString* rulesString = engin.rulesString;
        if(!rulesString) {
            rulesString = @"";
            for(NSString* r in [CCEngin getRulesArray]) {
                rulesString = [[rulesString stringByAppendingString: r] stringByAppendingString: @"\n"];
            }
        }
        rulesTextView.text = rulesString;
        [rulesTextView setDelegate:self];
        [[[CCDirector sharedDirector] openGLView] addSubview:rulesTextView];
        
        resultRulesTextView = [[UITextView alloc] initWithFrame: CGRectMake(0,200, size.width, 100)];
        resultRulesTextView.textAlignment = NSTextAlignmentLeft;
        NSString* resultRulesString = engin.resultRulesString;
        if(!resultRulesString) {
            resultRulesString = @"";
            for(NSString* r in [CCEngin getResultRulesArray]) {
                resultRulesString = [[resultRulesString stringByAppendingString: r] stringByAppendingString: @"\n"];
            }
        }
        resultRulesTextView.text = resultRulesString;
        [resultRulesTextView setDelegate:self];
        [[[CCDirector sharedDirector] openGLView] addSubview:resultRulesTextView];
        
        saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [saveButton setFrame: CGRectMake(0,310, 100, 30)];
        [saveButton setTitle: @"Save" forState: UIControlStateNormal];
        [saveButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
        [[[CCDirector sharedDirector] openGLView] addSubview:saveButton];
        
        cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cancelButton setFrame: CGRectMake(110,310, 100, 30)];
        [cancelButton setTitle: @"Cancel" forState: UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [[[CCDirector sharedDirector] openGLView] addSubview:cancelButton];
        
        restoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [restoreButton setFrame: CGRectMake(220,310, 100, 30)];
        [restoreButton setTitle: @"Restore" forState: UIControlStateNormal];
        [restoreButton addTarget:self action:@selector(restore:) forControlEvents:UIControlEventTouchUpInside];
        [[[CCDirector sharedDirector] openGLView] addSubview:restoreButton];

    }
    
    return self;
}

-(void) save:(id) sender {
    engin.rulesString = rulesTextView.text;
    engin.resultRulesString = resultRulesTextView.text;
    [engin setRules: [RuleResolver resolveRules: rulesTextView.text]];
    [engin setResultRules: [RuleResolver resolveRules: resultRulesTextView.text]];
    [self cancel:nil];
}

-(void) cancel:(id) sender {
    [rulesTextView removeFromSuperview];
    [resultRulesTextView removeFromSuperview];
    [saveButton removeFromSuperview];
    [cancelButton removeFromSuperview];
    [restoreButton removeFromSuperview];
}

-(void) restore:(id) sender {
    NSString* rulesString = @"";
    for(NSString* r in [CCEngin getRulesArray]) {
        rulesString = [[rulesString stringByAppendingString: r] stringByAppendingString: @"\n"];
    }
    rulesTextView.text = rulesString;
    
    NSString* resultRulesString = @"";
    for(NSString* r in [CCEngin getResultRulesArray]) {
        resultRulesString = [[resultRulesString stringByAppendingString: r] stringByAppendingString: @"\n"];
    }
    resultRulesTextView.text = resultRulesString;
}

@end
