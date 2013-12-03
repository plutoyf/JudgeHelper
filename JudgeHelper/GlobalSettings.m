//
//  GlobalSettings.m
//  JudgeHelper
//
//  Created by fyang on 7/31/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "GlobalSettings.h"

@implementation GlobalSettings

+(GlobalSettings *)globalSettings {
    static GlobalSettings *globalSettings;
    
    @synchronized(self)
    {
        if (!globalSettings) globalSettings = [[GlobalSettings alloc] init];
        return globalSettings;
    }
}

DisplayMode displayMode = UIKIT;
-(void) setDisplayMode: (DisplayMode) mode {
    if(mode == UIKIT || mode == COCOS2D) {
        displayMode = mode;
    }
}

-(DisplayMode) getDisplayMode {
    return displayMode;
}

GameMode gameMode = DOUBLE_HAND;
-(void) setGameMode: (GameMode) mode {
    if(mode == NORMAL || mode == DOUBLE_HAND) {
        gameMode = mode;
    }
}

-(GameMode) getGameMode {
    return gameMode;
}

NSArray* playerIds;
-(void) setPlayerIds: (NSArray*) ids {
    playerIds = ids;
}

-(NSArray*) getPlayerIds {
    return playerIds;
}

NSArray* roles;
-(void) setRoles: (NSArray*) rs {
    roles = rs;
}

-(NSArray*) getRoles {
    return roles;
}

NSDictionary* roleNumbers;
-(void) setRoleNumbers: (NSDictionary*) rNums {
    roleNumbers = rNums;
}

-(NSDictionary*) getRoleNumbers {
    return roleNumbers;
}

BOOL realPositionHandModeEnable;
-(BOOL) isRealPositionHandModeEnable {
    return realPositionHandModeEnable;
}

-(void) setRealPositionHandMode:(BOOL)enable {
    realPositionHandModeEnable = enable;
}

@end
