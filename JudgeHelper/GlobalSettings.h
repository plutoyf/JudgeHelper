//
//  GlobalSettings.h
//  JudgeHelper
//
//  Created by fyang on 7/31/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NORMAL = 0, DOUBLE_HAND = 1
} GameMode;

@interface GlobalSettings : NSObject

+(GlobalSettings *)globalSettings;
-(void) setGameMode: (GameMode) gameMode;
-(GameMode) getGameMode;
-(void) setPlayerIds: (NSArray*) ids;
-(NSArray*) getPlayerIds;
-(void) setRoles: (NSArray*) rs;
-(NSArray*) getRoles;
-(void) setRoleNumbers: (NSDictionary*) rNums;
-(NSDictionary*) getRoleNumbers;

@end
