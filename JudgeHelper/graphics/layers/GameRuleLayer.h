//
//  GameRuleLayer.h
//  JudgeHelper
//
//  Created by YANG FAN on 16/08/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "DeviceSettings.h"
#import "CCLayer.h"
#import "CCEngin.h"

@interface GameRuleLayer : CCSprite
{
    CCEngin* engin;
    UITextView *rulesTextView;
    UITextView *resultRulesTextView;
    UIButton *saveButton;
    UIButton *cancelButton;
    UIButton *restoreButton;
}
@end
