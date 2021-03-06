//
//  Engin.h
//  JudgeHelper
//
//  Created by fyang on 7/17/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Role.h"
#import "Property.h"
#import "Player.h"


@interface Engin : NSObject
{
    NSDictionary* _playersMap;
    NSArray* _players;
    NSMutableArray* _roles;
    NSMutableDictionary* _roleNumbers;
    NSArray* _eligibilityRules;
    NSArray* _actionRules;
    NSArray* _clearenceRules;
    NSArray* _resultRules;
    NSMutableArray* _originalOrders;
    NSMutableArray* _orders;
}

@property (nonatomic, strong, readonly) NSArray* orders;
@property (nonatomic, strong, readonly) NSArray* players;
@property (nonatomic, strong, readonly) NSArray* roles;
@property (nonatomic, strong, readonly) NSDictionary* roleNumbers;
@property (nonatomic, strong, readonly) NSArray* eligibilityRules;
@property (nonatomic, strong, readonly) NSArray* actionRules;
@property (nonatomic, strong, readonly) NSArray* clearenceRules;
@property (nonatomic, strong, readonly) NSArray* resultRules;

+(Status) getStatusFromString: (NSString*) str;
+(NSString*) getStatusName: (Status) status;
+(Role) getRoleFromString: (NSString*) str;
+(NSString*) getRoleName: (Role) role;
+(Property) getPropertyFromString: (NSString*) str;
+(NSString*) getPropertyName: (Property) property;

-(id) initWithRules: (NSArray*) eligibilityRules : (NSArray*) actionRules : (NSArray*) clearenceRules : (NSArray*) resultRules andRoles: (NSArray*) roles andOrders: (NSArray*) orders;
-(void) initRoles: (NSDictionary*) roleNumbers;
-(void) setPlayers: (NSArray*) players;
-(void) setRules: (NSArray*) eligibilityRules : (NSArray*) actionRules : (NSArray*) clearenceRules : (NSArray*) resultRules ;
-(void) setEligibilityRules: (NSArray*) eligibilityRules;
-(void) setActionRules: (NSArray*) actionRules;
-(void) setClearenceRules: (NSArray*) clearenceRules;
-(void) setResultRules: (NSArray*) resultRules;

-(BOOL) isEligibleActionAtNight: (long) i withPlayer: (Player*) player;
-(BOOL) isEligibleActionAtNight: (long) i withActor: (Player*) actor andReceiver: (Player*) receiver;
-(BOOL) isEligibleActionAtNight: (long) i withActors: (NSArray*) actors andReceiver: (Player*) receiver;
-(NSNumber*) doActionAtNight: (long) i withPlayer: (Player*) player;
-(NSNumber*) doActionAtNight: (long) i withActor: (Player*) actor andReceiver: (Player*) receiver;
-(NSNumber*) doActionAtNight: (long) i withActors: (NSArray*) actors andReceiver: (Player*) receiver;
-(NSNumber*) doClearenceAtNight: (long) i withPlayer: (Player*) player;
-(NSNumber*) doClearenceAtNight: (long) i withActor: (Player*) actor andReceiver: (Player*) receiver;
-(NSNumber*) doClearenceAtNight: (long) i withActors: (NSArray*) actors andReceiver: (Player*) receiver;

-(int) getRoleNumber : (Role) r;
-(NSArray*) getPlayersByRole: (Role) role;
-(NSArray*) getPlayersByRole: (Role) role withIn: (NSArray*) players;
-(Player*) getPlayerById: (NSString*) id;
-(Player*) getReceiverForActor: (Player*) actor atNight: (long) i;
-(BOOL) isEffectiveActionForActor: (Player*) actor atNight: (long) i;
-(NSArray*) getApplicatedRulesForActor: (Player*) actor atNight: (long) i;
-(Player*) getPlayerFrom: (Player*) p1 and: (Player*) p2 withRole: (Role) r;

-(int) calculateFinalResultAtNight: (long) i ;
-(void) resetDistance;
-(void) rollbackPlayersStatus;
-(void) recordPlayersStatus;
-(void) recordNightStatus: (long) i;

-(void) run;

@end
