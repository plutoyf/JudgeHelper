//
//  Player.h
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Role.h"
#import "Status.h"

@interface Player : NSObject
{
    NSString* _id;
    NSString* _name;
    
    Role _role;
    double _life;
    double _note;
    Status _status;
    NSMutableDictionary* _distances;
    NSMutableDictionary* _defaultDistances;
    
    NSMutableArray* _lifeStack;
    NSMutableArray* _roleStack;
    NSMutableArray* _noteStack;
    NSMutableArray* _statusStack;
    NSMutableArray* _distanceStack;
    NSMutableArray* _defaultDistanceStack;
    
    NSMutableDictionary* _lifeByNight;
    NSMutableDictionary* _roleByNight;
    NSMutableDictionary* _noteByNight;
    NSMutableDictionary* _statusByNight;
    NSMutableDictionary* _distancesByNight;
    NSMutableDictionary* _defaultDistancesByNight;
    
    NSMutableDictionary* _actionReceivers;
    NSMutableDictionary* _actionResults;
    NSMutableDictionary* _applicatedRules;
}

@property (nonatomic, strong) NSString* id;
@property (nonatomic, strong) NSString* name;

@property (nonatomic) Role role;
@property (atomic) double life;
@property (atomic) double note;
@property (nonatomic) Status status;
@property (nonatomic, strong) NSMutableDictionary* distances;
@property (nonatomic, strong) NSMutableDictionary* defaultDistances;

@property (nonatomic, strong) NSMutableArray* roleStack;
@property (nonatomic, strong) NSMutableArray* lifeStack;
@property (nonatomic, strong) NSMutableArray* noteStack;
@property (nonatomic, strong) NSMutableArray* statusStack;
@property (nonatomic, strong) NSMutableArray* distanceStack;
@property (nonatomic, strong) NSMutableArray* defaultDistanceStack;

@property (nonatomic, strong) NSMutableDictionary* roleByNight;
@property (nonatomic, strong) NSMutableDictionary* lifeByNight;
@property (nonatomic, strong) NSMutableDictionary* noteByNight;
@property (nonatomic, strong) NSMutableDictionary* statusByNight;
@property (nonatomic, strong) NSMutableDictionary* distancesByNight;
@property (nonatomic, strong) NSMutableDictionary* defaultDistancesByNight;

@property (nonatomic, strong) NSMutableDictionary* actionReceivers;
@property (nonatomic, strong) NSMutableDictionary* actionResults;
@property (nonatomic, strong) NSMutableDictionary* applicatedRules;

-(id) init: (NSString*) id andName: (NSString*) name withRole: (Role) role;
-(id) init: (NSString*) id andName: (NSString*) name;

-(NSString*) toString;

-(BOOL) isInGame;

-(double) getDefaultDistanceWith: (NSString*) playerId;

-(double) getDefaultDistanceAtNight:(long) i with: (NSString*) playerId;

-(void) setDefaultDistance: (double) distance withPlayer: (NSString*) playerId;

-(double) getDistanceWith: (NSString*) playerId;

-(double) getDistanceAtNight:(long) i with: (NSString*) playerId;

-(void) setDistance: (double) distance withPlayer: (NSString*) playerId;

-(void) addActionAtNight:(long) i to: (NSString*) receiverId forResult: (NSNumber*) result withMatchedRules: (NSArray*) matchedRules;

-(double) getLifeAtNight:(long) i;

-(double) getRoleAtNight:(long) i;

-(double) getNoteAtNight:(long) i;

-(double) getStatusAtNight:(long) i;

-(NSString*) getActionReceiverAtNight: (long) i;

-(NSArray *) getApplicatedRulesAtNight: (long) i;

-(NSNumber *) getActionResultAtNight: (long) i;

-(BOOL) isEffectiveActionAtNight: (long) i;

-(void) resetDistance;
-(void) recordNightStatus: (long) i;
-(void) rollbackStatus;
-(void) recordStatus;
-(int) getStackDepth;

@end

