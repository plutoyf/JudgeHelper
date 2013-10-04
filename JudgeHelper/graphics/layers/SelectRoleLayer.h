//
//  SelectRoleLayer.h
//  JudgeHelper
//
//  Created by YANG FAN on 28/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "DeviceSettings.h"

#import "cocos2d.h"
#import "CCEngin.h"
#import "MySprite.h"
#import "SelectPlayerLayer.h"
#import "GameLayer.h"

@interface SelectRoleLayer : CCLayer <UIGestureRecognizerDelegate>
{
    CCEngin* engin;
    CCMenu* previousMenu;
    CCMenu* startMenu;
    CCMenuItem* doubleHandModeOffItem;
    CCMenuItem* doubleHandModeOnItem;
    CCLabelTTF* messageLabel;
    CCLabelTTF* doubleHandModeLabel;
    NSArray * roles;
    NSMutableDictionary * roleNumbers;
    NSMutableDictionary * roleIconsMap;
    NSMutableDictionary* roleLabels;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;


@end
