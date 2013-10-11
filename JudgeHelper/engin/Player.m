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
        _note = 0;
        _status = IN_GAME;
        _defaultDistances = [NSMutableDictionary new];
        _distances = [NSMutableDictionary new];
        
        _lifeByNight = [NSMutableDictionary new];
        _roleByNight = [NSMutableDictionary new];
        _noteByNight = [NSMutableDictionary new];
        _statusByNight = [NSMutableDictionary new];
        _distancesByNight = [NSMutableDictionary new];
        _defaultDistancesByNight = [NSMutableDictionary new];
        
        _actionReceivers = [NSMutableDictionary new];
        _actionResults = [NSMutableDictionary new];
        _applicatedRules = [NSMutableDictionary new];
    }
    
    return self;
}

-(double) getDistanceWith: (NSString*) playerId {
    return [_distances valueForKey:playerId] == nil ? 1 : [(NSNumber*)[_distances valueForKey:playerId] doubleValue];
}

-(double) getDistanceAtNight:(long) i with: (NSString*) playerId {
    NSNumber* key = [NSNumber numberWithLong: i];
    NSDictionary* distances =  [_distancesByNight objectForKey: key] != nil ? [_distancesByNight objectForKey: key] : nil;
    return (distances == nil || [distances valueForKey:playerId] == nil) ? 1 : [(NSNumber*)[distances valueForKey:playerId] doubleValue];
}

-(void) setDistance: (double) distance withPlayer: (NSString*) playerId {
    [_distances setValue: [NSNumber numberWithDouble:distance] forKey: playerId];
}

-(double) getDefaultDistanceWith: (NSString*) playerId {
    return [_defaultDistances valueForKey:playerId] == nil ? 1 : [(NSNumber*)[_defaultDistances valueForKey:playerId] doubleValue];
}

-(double) getDefaultDistanceAtNight:(long) i with: (NSString*) playerId {
    NSNumber* key = [NSNumber numberWithLong: i];
    NSDictionary* distances =  [_defaultDistancesByNight objectForKey: key] != nil ? [_defaultDistancesByNight objectForKey: key] : nil;
    return (distances == nil || [distances valueForKey:playerId] == nil) ? 1 : [(NSNumber*)[distances valueForKey:playerId] doubleValue];
}

-(void) setDefaultDistance: (double) distance withPlayer: (NSString*) playerId {
    [_defaultDistances setValue: [NSNumber numberWithDouble:distance] forKey: playerId];
}

-(double) getLifeAtNight:(long) i {
    NSNumber* key = [NSNumber numberWithLong: i];
    return [_lifeByNight objectForKey: key] != nil ? [[_lifeByNight objectForKey: key] doubleValue] : 1;
}

-(double) getRoleAtNight:(long) i {
    NSNumber* key = [NSNumber numberWithLong: i];
    return [_roleByNight objectForKey: key] != nil ? [[_roleByNight objectForKey: key] doubleValue] : 0;
}

-(double) getNoteAtNight:(long) i {
    NSNumber* key = [NSNumber numberWithLong: i];
    return [_noteByNight objectForKey: key] != nil ? [[_noteByNight objectForKey: key] doubleValue] : 0;
}

-(double) getStatusAtNight:(long) i {
    NSNumber* key = [NSNumber numberWithLong: i];
    return [_statusByNight objectForKey: key] != nil ? [[_statusByNight objectForKey: key] doubleValue] : 0;
}

-(void) setObject: (id) obj forNight: (long) i andRole: (Role) r to: (NSMutableDictionary*) dictonary {
    NSNumber* night = [NSNumber numberWithLong: i];
    NSNumber* role = [NSNumber numberWithInt: r];
    if([dictonary objectForKey: night] == nil) {
        [dictonary setObject: [NSMutableDictionary new] forKey: night];
    }
    [[dictonary objectForKey: night] setObject: obj forKey: role];
}

-(id) getObjectForNight: (long) i andRole: (Role) r from: (NSMutableDictionary*) dictonary {
    NSNumber* night = [NSNumber numberWithLong: i];
    NSNumber* role = [NSNumber numberWithInt: r];
    NSMutableDictionary* values = [dictonary objectForKey: night];
    id obj = [values objectForKey:role];
    return obj;
}

-(void) addActionAtNight:(long) i forRole: (Role) r to: (NSString*) receiverId forResult: (NSNumber*) result withMatchedRules: (NSArray*) matchedRules {
    [self setObject: receiverId forNight: i andRole: r to: _actionReceivers];
    [self setObject: matchedRules forNight: i andRole: r to: _applicatedRules];
    [self setObject: result forNight: i andRole: r to: _actionResults];
}

-(NSString*) getActionReceiverAtNight: (long) i forRole: (Role) r {
    id value = [self getObjectForNight: i andRole: r from: _actionReceivers];
    return value != nil ? value : @"";
}

-(NSArray *) getApplicatedRulesAtNight: (long) i forRole: (Role) r {
    id value = [self getObjectForNight: i andRole: r from: _applicatedRules];
    return value != nil ? value : [NSArray array];
}

-(NSNumber *) getActionResultAtNight: (long) i forRole: (Role) r {
    id value = [self getObjectForNight: i andRole: r from: _actionResults];
    return value != nil ? value : [NSNumber numberWithBool:NO];
}

-(BOOL) isEffectiveActionAtNight: (long) i forRole: (Role) r {
    id value = [self getObjectForNight: i andRole: r from: _actionResults];
    return value != nil ? [value boolValue] : NO;
}

-(void) recordNightStatus: (long) i {
    NSNumber* key = [NSNumber numberWithLong: i];
    [_lifeByNight setObject: [NSNumber numberWithDouble: _life] forKey: key];
    [_roleByNight setObject: [NSNumber numberWithDouble: _role] forKey: key];
    [_noteByNight setObject: [NSNumber numberWithDouble: _note] forKey: key];
    [_statusByNight setObject: [NSNumber numberWithDouble: _status] forKey: key];
    [_distancesByNight setObject: [self cloneDistances: _distances] forKey: key];
    [_defaultDistancesByNight setObject: [self cloneDistances: _defaultDistances] forKey: key];
}

-(void) resetDistance {
    for (NSString* key in [_distances allKeys]) {
        [_distances setValue: [NSNumber numberWithDouble: [self getDefaultDistanceWith:key]] forKey: key];
    }
}

-(void) recordStatus {
    if(_lifeStack == nil) {
        _lifeStack = [NSMutableArray new];
    }
    [_lifeStack addObject: [NSNumber numberWithDouble: _life]];
    
    if(_roleStack == nil) {
        _roleStack = [NSMutableArray new];
    }
    [_roleStack addObject: [NSNumber numberWithDouble: _role]];
    
    if(_noteStack == nil) {
        _noteStack = [NSMutableArray new];
    }
    [_noteStack addObject: [NSNumber numberWithDouble: _note]];
    
    if(_statusStack == nil) {
        _statusStack = [NSMutableArray new];
    }
    [_statusStack addObject: [NSNumber numberWithInt: _status]];
    
    if(_distanceStack == nil) {
        _distanceStack = [NSMutableArray new];
    }
    [_distanceStack addObject: [self cloneDistances: _distances]];
    
    if(_defaultDistanceStack == nil) {
        _defaultDistanceStack = [NSMutableArray new];
    }
    [_defaultDistanceStack addObject: [self cloneDistances: _defaultDistances]];
}

-(void) rollbackStatus {
    if(_lifeStack != nil && _lifeStack.count > 0) {
        self.life = [[_lifeStack lastObject] doubleValue];
        [_lifeStack removeLastObject];
    }
    if(_roleStack != nil && _roleStack.count > 0) {
        self.role = [[_roleStack lastObject] doubleValue];
        [_roleStack removeLastObject];
    }
    if(_noteStack != nil && _noteStack.count > 0) {
        self.note = [[_noteStack lastObject] doubleValue];
        [_noteStack removeLastObject];
    }
    if(_statusStack != nil && _statusStack.count > 0) {
        self.status = [((NSNumber *)[_statusStack lastObject]) intValue];
        [_statusStack removeLastObject];
    }
    if(_distanceStack != nil && _distanceStack.count > 0) {
        self.distances = [_distanceStack lastObject];
        [_distanceStack removeLastObject];
    }
    if(_defaultDistanceStack != nil && _defaultDistanceStack.count > 0) {
        _defaultDistances = [_defaultDistanceStack lastObject];
        [_defaultDistanceStack removeLastObject];
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
