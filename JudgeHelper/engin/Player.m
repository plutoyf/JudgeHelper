//
//  Player.m
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import "Player.h"
#import "Engin.h"

@implementation Player

-(id) init: (NSString*) id andName: (NSString*) name {
    return [self init:id andName:name withRole:Citizen];
}

-(id) init: (NSString*) id andName: (NSString*) name withRole: (Role) role {
    if(self = [super init]) {
        _id = id;
        _name = name;
        _role = role;
        _life = 1;
        _status = IN_GAME;
        
        _distances = [NSMutableDictionary new];
        _actionReceivers = [NSMutableDictionary new];
        _actionResults = [NSMutableDictionary new];
        _applicatedRules = [NSMutableDictionary new];
    }
    
    return self;
}

-(double) getDistanceWith: (NSString*) playerId {
    return [_distances valueForKey:playerId] == nil ? 1 : [(NSNumber*)[_distances valueForKey:playerId] doubleValue];
}

-(void) setDistance: (double) distance withPlayer: (NSString*) playerId {
    [_distances setValue: [NSNumber numberWithDouble:distance] forKey: playerId];
}

-(void) addActionAtNight:(long) i to: (NSString*) receiverId forResult: (NSNumber*) result withMatchedRules: (NSArray*) matchedRules {
    NSNumber* key = [NSNumber numberWithLong: i];
    [_actionReceivers setObject: receiverId forKey: key];
    [_applicatedRules setObject: matchedRules forKey: key];
    [_actionResults setObject: result forKey: key];
}

-(NSString*) getActionReceiverAtNight: (long) i {
    NSNumber* key = [NSNumber numberWithLong: i];
    return [_actionReceivers objectForKey: key] != nil ? [_actionReceivers objectForKey: key] : @"";
}

-(BOOL) isEffectiveActionAtNight: (long) i {
    NSNumber* key = [NSNumber numberWithLong: i];
    return [_actionResults objectForKey: key] != nil ? [[_actionResults objectForKey: key] boolValue] : NO;
}

-(NSArray *) getApplicatedRulesAtNight: (long) i {
    NSNumber* key = [NSNumber numberWithLong: i];
    return [_applicatedRules objectForKey: key] != nil ? [_applicatedRules objectForKey: key] : [NSArray array];
}

-(NSNumber *) getActionResultAtNight: (long) i {
    NSNumber* key = [NSNumber numberWithLong: i];
    return [_actionResults objectForKey: key] != nil ? [_actionResults objectForKey: key] : [NSNumber numberWithBool:NO];
}

-(void) resetDistance {
    for (NSString* key in [_distances allKeys]) {
        [_distances setValue: [NSNumber numberWithDouble: 1] forKey: key];
    }
}


-(void) recordStatus {
    if(_lifeStack == nil) {
        _lifeStack = [NSMutableArray new];
    }
    [_lifeStack addObject: [NSNumber numberWithDouble: _life]];
    
    if(_distanceStack == nil) {
        _distanceStack = [NSMutableArray new];
    }
    [_distanceStack addObject: [self cloneDistances: _distances]];
    
    if(_statusStack == nil) {
        _statusStack = [NSMutableArray new];
    }
    [_statusStack addObject: [NSNumber numberWithInt: _status]];
}

-(void) rollbackStatus {
    if(_lifeStack != nil && _lifeStack.count > 1) {
        [_lifeStack removeLastObject];
        _life = [[_lifeStack lastObject] doubleValue];
    }
    if(_distanceStack != nil && _distanceStack.count > 1) {
        [_distanceStack removeLastObject];
        _distances = [self cloneDistances: [_distanceStack lastObject]];
    }
    if(_statusStack != nil && _statusStack.count > 1) {
        [_statusStack removeLastObject];
        _status = [((NSNumber *)[_statusStack lastObject]) intValue];
    }
}

-(NSMutableDictionary*) cloneDistances : (NSMutableDictionary*) distances {
    NSMutableDictionary* clone = [NSMutableDictionary new];
    for(id key in [distances allKeys]) {
        [clone setObject: [NSNumber numberWithDouble:((NSNumber*)[distances objectForKey:key]).doubleValue] forKey:key];
    }
    return clone;
}

-(int) getStackDepth {
    return _lifeStack == nil ? 0 : _lifeStack.count;
}

-(BOOL) isInGame {
    return _status == IN_GAME;
}

-(NSString*) toString {
    NSString* receivers = @"";
    NSNumber* i = [NSNumber numberWithLong:1];
    while ([_actionReceivers objectForKey:i] != nil) {
        receivers = [NSString stringWithFormat:@"%@ , %d %@", receivers, [i intValue], [_actionReceivers objectForKey:i]];
        i = [NSNumber numberWithLong:[i longValue]+1];
    }
    
    NSString* lifes = @"";
    for(NSNumber* l in _lifeStack) {
        lifes = [NSString stringWithFormat:@"%@, %.1f", lifes, [l doubleValue]];
    }
    NSString* dis = @"";
    double dj, dg;
    BOOL isFirst = YES;
    for(NSMutableDictionary* d in _distanceStack) {
        double newDj = [self getDistanceWith:@"法官" from:d];
        double newDg = [self getDistanceWith:@"花蝴蝶" from:d];
        if(isFirst || dj != newDj || dg != newDg) {
            dis = [NSString stringWithFormat:@"%@, dj=%.1f dg=%.1f", dis, newDj, newDg];
            dj = newDj;
            dg = newDg;
            isFirst = NO;
        }
    }
    return [NSString stringWithFormat:@"%@ %@ : %@ : dj=%.1f dg=%.1f  \n    life (%d) : %@  \n    dis (%d) : %@", _name, [Engin getStatusName:_status], receivers, [self getDistanceWith:@"法官"], [self getDistanceWith:@"花蝴蝶"], _lifeStack.count, lifes, _distanceStack.count, dis];
}

-(double) getDistanceWith:(NSString *)playerId from:(NSMutableDictionary*) d {
    return [d objectForKey:playerId]==nil ? 1 : ((NSNumber*)[d objectForKey:playerId]).doubleValue;
}

@end
