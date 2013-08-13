//
//  SelectPlayerLayer.h
//  JudgeHelper
//
//  Created by YANG FAN on 28/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//


#import <GameKit/GameKit.h>

#import "cocos2d.h"
#import "CCEngin.h"
#import "MySprite.h"
#import "GlobalSettings.h"
#import "SelectRoleLayer.h"
#import "CreatePlayerLayer.h"
#import "CCDoubleHandPlayer.h"
#import "GameLayer.h"
#import "GameStateSprite.h"

@interface SelectPlayerLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, CreatePlayerDelegate>
{
    CCEngin* engin;
    CCSprite* nextIcon;
    CCSprite* playersPool;
    CCSprite* playersPool2;
    MySprite* playerToRemove;
    MySprite* playerToRemove2;
    NSMutableArray* personIcons;
    NSMutableArray* personIcons2;
    NSMutableDictionary* personIconsMap;
    NSMutableDictionary* personIconsMap2;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end