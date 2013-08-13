//
//  GameLayer.h
//  JudgeHelper
//
//  Created by YANG FAN on 23/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "cocos2d.h"
#import "CCEngin.h"
#import "CCHandPlayer.h"
#import "CCDoubleHandPlayer.h"
#import "SelectPlayerLayer.h"
#import "GameStateSprite.h"
#import "TableZone.h"

@interface GameLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, CCEnginDisplayDelegate>
{
    CCLabelTTF* debugLabel;
    CCLabelTTF* nightLabel;
    CCLabelTTF* messageLabel;
    CCMenu* restarMenu;
    CCPlayer* selPlayer;
    BOOL selPlayerInMove;
    NSMutableDictionary* playersMap;
    NSMutableArray* players;
    Role rolePlayerToDefine;
    BOOL defineRolePlayerBegin;
    GameStateSprite* gameStateSprite;
    TableZone* tableZone;
    
    CCEngin* engin;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
