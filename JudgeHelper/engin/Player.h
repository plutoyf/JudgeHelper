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
    NSString* _name;
    Role _role;
    double _life;
    double _note;
    Status _status;
    NSMutableDictionary* _distances;
    NSMutableDictionary* _actionReceivers;
    NSMutableDictionary* _actionResults;
    NSMutableDictionary* _applicatedRules;
    
    NSMutableArray* lifeStack;
    NSMutableArray* distanceStack;
    NSMutableArray* statusStack;
}

@property (nonatomic, strong) NSString* name;
@property (nonatomic) Role role;
@property (atomic) double life;
@property (atomic) double note;
@property (nonatomic) Status status;
@property (nonatomic, strong) NSMutableDictionary* distances;
@property (nonatomic, strong) NSMutableDictionary* actionReceivers;
@property (nonatomic, strong) NSMutableDictionary* actionResults;
@property (nonatomic, strong) NSMutableDictionary* applicatedRules;

-(id) init: (NSString*) name withRole: (Role) role;
-(id) init: (NSString*) name;

-(NSString*) toString;

-(BOOL) isInGame;

-(double) getDistanceWith: (NSString*) playerName;

-(void) setDistance: (double) distance withPlayer: (NSString*) playerName;

-(void) addActionAtNight:(long) i to: (NSString*) receiverName forResult: (NSNumber*) result withMatchedRules: (NSArray*) matchedRules;

-(NSString*) getActionReceiverAtNight: (long) i;

-(BOOL) isEffectiveActionAtNight: (long) i;

-(NSArray *) getApplicatedRulesAtNight: (long) i;

-(void) resetDistance;

-(void) rollbackStatus;
-(void) recordStatus;
-(int) getStackDepth;

@end

