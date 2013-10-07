//
//  SelectPlayerLayer.h
//  JudgeHelper
//
//  Created by YANG FAN on 28/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//


#import <GameKit/GameKit.h>

#import "DeviceSettings.h"
#import "cocos2d.h"
#import "CCEngin.h"
#import "MySprite.h"
#import "GlobalSettings.h"
#import "SelectRoleLayer.h"
#import "CreatePlayerLayer.h"
#import "CCDoubleHandPlayer.h"
#import "GameLayer.h"
#import "GameStateSprite.h"

@interface SelectPlayerLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, UIGestureRecognizerDelegate, CreatePlayerDelegate>
{
    CCEngin* engin;
    CCMenu* nextMenu;
    CCMenu* addPlayerMenu;
    CCSprite* playersPool;
    CCSprite* playersPool2;
    MySprite* playerToRemove;
    MySprite* playerToRemove2;
    CCSprite* playersPoolCadre;
    NSMutableArray* personIcons;
    NSMutableArray* personIcons2;
    NSMutableDictionary* personIconsMap;
    NSMutableDictionary* personIconsMap2;
    int selPersonNumber;
    NSMutableDictionary* selPersonIconsMap;
    BOOL isIgnorePresse;
    CreatePlayerLayer* createPlayerLayer;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end