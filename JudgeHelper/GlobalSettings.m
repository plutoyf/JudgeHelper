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

GameMode gameMode = NORMAL;
-(void) setGameMode: (GameMode) mode {
    if(mode == NORMAL || mode == DOUBLE_HAND) {
        gameMode = mode;
    }
}

-(GameMode) getGameMode {
    return gameMode;
}

int totalRoleNumber;
-(void) setTotalRoleNumber: (int) i {
    totalRoleNumber = i;
}

-(int) getTotalRoleNumber {
    return totalRoleNumber;
}

NSArray* playerIds;
-(void) setPlayerIds: (NSArray*) ids {
    playerIds = ids;
}

-(NSArray*) getPlayerIds {
    return playerIds;
}

@end
