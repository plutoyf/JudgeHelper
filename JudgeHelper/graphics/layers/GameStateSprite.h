//
//  GameStateSprite.h
//  JudgeHelper
//
//  Created by fyang on 8/2/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "CCEngin.h"
#import "CCPlayer.h"

@interface GameStateSprite : CCSprite
{
    CCEngin* engin;
    CCMenuItem* showGameStateMenuItem;
    CCMenuItem* hideGameStateMenuItem;
    NSMutableDictionary* playerLines;
    NSMutableDictionary* playerVisibleObjects;
    NSMutableDictionary* playerLifeBoxes;
    NSMutableArray* pIds;
    CCMenuItemImage *realPositionHandModeOffItem;
    CCMenuItemImage *realPositionHandModeOnItem;
    CCLabelTTF *realPositionHandModeLabel;
}

-(void) addNewStatusWithActorRole: (Role) role andReceiver: (Player*) receiver andResult: (BOOL) result;
-(void) revertStatus;
@end
