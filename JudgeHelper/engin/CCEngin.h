//
//  CCEngin.h
//  JudgeHelper
//
//  Created by YANG FAN on 23/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "cocos2d.h"
#import "Engin.h"


@protocol CCEnginDisplayDelegate;

@interface CCEngin : Engin
{
    BOOL inGame;
    long night;
    int state;
    int oIndex;
    Role roleInAction;
    NSString* selectedPlayerId;
    Player* selectedPlayer;
    NSMutableArray* initialPlayers;
    NSMutableArray* currentPlayers;
    NSMutableArray* deadPlayers;
}

@property (nonatomic, assign) id<CCEnginDisplayDelegate> displayDelegate;

+(CCEngin*) getEngin;
+(NSString*) getRoleCode: (Role) r;

-(void) action: (NSString*) id;
-(void) setPlayerNumberForRole: (int) i;
-(NSString*) getRoleLabel: (Role) r;
-(NSString*) getRoleActionLabel: (Role) r;
-(Role) getCurrentRole;
-(int) getCurrentNight;

@end


@protocol CCEnginDisplayDelegate
@required
-(void) recordPlayersStatusWithActorRole: (Role) role andReceiver: (Player*) receiver andResult: (BOOL) result;
-(void) rollbackPlayersStatus;
-(void) backupActionIcon;
-(void) restoreBackupActionIcon;
-(void) addActionIcon: (Role) role to: (Player*) player withResult: (BOOL) result;
-(void) removeActionIconFrom: (Player*) player;
-(void) updatePlayerLabels;
-(void) resetPlayerIcons: (NSArray*) players;
-(void) updatePlayerIcons;
-(void) showDebugMessage: (NSString*) message inIncrement: (BOOL) increment;
-(void) showPlayerDebugMessage: (Player *) player inIncrement: (BOOL) increment;
-(void) showMessage: (NSString *) message;
-(void) showNightMessage: (long) i;
-(void) definePlayerForRole: (Role) r;
-(void) gameFinished;

@end
