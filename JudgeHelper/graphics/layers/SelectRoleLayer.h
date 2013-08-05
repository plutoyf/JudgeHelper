//
//  SelectRoleLayer.h
//  JudgeHelper
//
//  Created by YANG FAN on 28/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "cocos2d.h"

@interface SelectRoleLayer : CCLayer <UIGestureRecognizerDelegate>
{
    CCMenuItem* doubleHandModeOffItem;
    CCMenuItem* doubleHandModeOnItem;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;


@end
