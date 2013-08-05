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

-(id) init: (NSString*) name {
    return [self init: name withRole: Citizen];
}

-(id) init: (NSString*) name withRole: (Role) role {
    if(self = [super init]) {
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

-(double) getDistanceWith: (NSString*) playerName {
    return [_distances valueForKey:playerName] == nil ? 1 : [(NSNumber*)[_distances valueForKey:playerName] doubleValue];
}

-(void) setDistance: (double) distance withPlayer: (NSString*) playerName {
    [_distances setValue: [NSNumber numberWithDouble:distance] forKey: playerName];
}

-(void) addActionAtNight:(long) i to: (NSString*) receiverName forResult: (NSNumber*) result withMatchedRules: (NSArray*) matchedRules {
    NSNumber* key = [NSNumber numberWithLong: i];
    [_actionReceivers setObject: receiverName forKey: key];
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

-(NSArray *) getApplicatedRulesAtNight {
    return [self getApplicatedRulesAtNight: [_applicatedRules count]];
}

-(void) resetDistance {
    for (NSString* key in [_distances allKeys]) {
        [_distances setValue: [NSNumber numberWithDouble: 1] forKey: key];
    }
}


-(void) recordStatus {
    if(lifeStack == nil) {
        lifeStack = [NSMutableArray new];
    }
    [lifeStack addObject: [NSNumber numberWithDouble: _life]];
    
    if(distanceStack == nil) {
        distanceStack = [NSMutableArray new];
    }
    [distanceStack addObject: [NSMutableDictionary dictionaryWithDictionary: _distances]];
    
    if(statusStack == nil) {
        statusStack = [NSMutableArray new];
    }
    [statusStack addObject: [NSNumber numberWithInt: _status]];
}

-(void) rollbackStatus {
    if(lifeStack != nil && lifeStack.count > 0) {
        _life = [[lifeStack lastObject] doubleValue];
        [lifeStack removeLastObject];
    }
    if(distanceStack != nil && distanceStack.count > 0) {
        _distances = (NSMutableDictionary*)[distanceStack lastObject];
        [distanceStack removeLastObject];
    }
    if(statusStack != nil && statusStack.count > 0) {
        _status = [((NSNumber *)[statusStack lastObject]) intValue];
        [statusStack removeLastObject];
    }
}

-(int) getStackDepth {
    return lifeStack == nil ? 0 : lifeStack.count;
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
    for(NSNumber* l in lifeStack) {
        lifes = [NSString stringWithFormat:@"%@, %.1f", lifes, [l doubleValue]];
    }
    NSString* dis = @"";
    double dj, dg;
    BOOL isFirst = YES;
    for(NSMutableDictionary* d in distanceStack) {
        double newDj = [self getDistanceWith:@"法官" from:d];
        double newDg = [self getDistanceWith:@"花蝴蝶" from:d];
        if(isFirst || dj != newDj || dg != newDg) {
            dis = [NSString stringWithFormat:@"%@, dj=%.1f dg=%.1f", dis, newDj, newDg];
            dj = newDj;
            dg = newDg;
            isFirst = NO;
        }
    }
    return [NSString stringWithFormat:@"%@ %@ : %@ : dj=%.1f dg=%.1f  \n    life (%d) : %@  \n    dis (%d) : %@", _name, [Engin getStatusName:_status], receivers, [self getDistanceWith:@"法官"], [self getDistanceWith:@"花蝴蝶"], lifeStack.count, lifes, distanceStack.count, dis];
}

-(double) getDistanceWith:(NSString *)playerName from:(NSMutableDictionary*) d {
    return [d objectForKey:playerName]==nil ? 1 : ((NSNumber*)[d objectForKey:playerName]).doubleValue;
}

@end
