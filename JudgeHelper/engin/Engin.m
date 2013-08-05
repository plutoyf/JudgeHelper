//
//  KKPlayer.m
//  JudgeHelper
//
//  Created by fyang on 7/17/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import "Engin.h"
#import "RuleResolver.h"

@implementation Engin

+(Status) getStatusFromString: (NSString*) str {
    if ([@"IN_GAME" isEqualToString: str]) return IN_GAME;
    if ([@"OUT_GAME" isEqualToString: str]) return OUT_GAME;
    
    return 0;
}

+(NSString*) getStatusName: (Status) status {
    NSString* name = nil;
    
    switch (status) {
        case IN_GAME:
            name = @"IN_GAME";
            break;
        case OUT_GAME:
            name = @"OUT_GAME";
            break;
        default:
            name = @"";
            break;
    }

    return name;
}

+(Role) getRoleFromString: (NSString*) str {
    if ([@"Game" isEqualToString: str]) return Game;
    if ([@"Guard" isEqualToString: str]) return Guard;
    if ([@"Killer" isEqualToString: str]) return Killer;
    if ([@"Police" isEqualToString: str]) return Police;
    if ([@"Doctor" isEqualToString: str]) return Doctor;
    if ([@"Spy" isEqualToString: str]) return Spy;
    if ([@"Citizen" isEqualToString: str]) return Citizen;
    if ([@"Anybody" isEqualToString: str]) return Anybody;
    if ([@"Receiver" isEqualToString: str]) return Receiver;
    if ([@"Judge" isEqualToString: str]) return Judge;
    
    return 0;
}

+(NSString*) getRoleName: (Role) role {
    NSString* name = nil;
    
    switch (role) {
        case Game:
            name = @"Game";
            break;
        case Guard:
            name = @"Guard";
            break;
        case Killer:
            name = @"Killer";
            break;
        case Police:
            name = @"Police";
            break;
        case Doctor:
            name = @"Doctor";
            break;
        case Spy:
            name = @"Spy";
            break;
        case Citizen:
            name = @"Citizen";
            break;
        case Anybody:
            name = @"Anybody";
            break;
        case Judge:
            name = @"Judge";
            break;
        case Receiver:
            name = @"Receiver";
            break;
        default:
            name = @"";
            break;
    }
    
    return name;
}

+(Property) getPropertyFromString: (NSString*) str {
    if ([@"life" isEqualToString: str]) return life;
    if ([@"distance" isEqualToString: str]) return distance;
    if ([@"role" isEqualToString: str]) return role;
    if ([@"note" isEqualToString: str]) return note;
    if ([@"status" isEqualToString: str]) return status;
    
    return 0;
}

+(NSString*) getPropertyName: (Property) property {
    NSString* name = nil;
    
    switch (property) {
        case life:
            name = @"life";
            break;
        case distance:
            name = @"distance";
            break;
        case role:
            name = @"role";
            break;
        case note:
            name = @"note";
            break;
        case status:
            name = @"status";
            break;
        default:
            name = @"";
            break;
    }
    
    return name;
}

-(void) run {
}

-(id) initWithRules: (NSArray*) rules andResultRules: (NSArray*) resultRules andRoles: (NSArray*) roles andOrders: (NSArray*) orders {
    if(self = [super init]) {
        _rules = [NSMutableArray arrayWithArray:rules];
        _resultRules = [NSMutableArray arrayWithArray:resultRules];
        _roles = [NSMutableArray arrayWithArray:roles];
        _originalOrders = [NSMutableArray arrayWithArray:orders];
        _orders = [NSMutableArray arrayWithArray:orders];
    }
    
    return self;
}

-(void) initRoles: (NSDictionary*) roleNumbers {
    _roleNumbers = [NSMutableDictionary dictionaryWithDictionary:roleNumbers];
    [_orders removeAllObjects];
    [_orders addObjectsFromArray:_originalOrders];
    
    NSMutableArray* toRemove = [NSMutableArray new];
    for(NSString* r in _orders) {
        if ([self getRoleNumber: [Engin getRoleFromString:r]] <= 0) {
            [toRemove addObject:r];
        }
    }
    [_orders removeObjectsInArray:toRemove];
}

-(void) setPlayers: (NSArray*) players {
    _players = [NSMutableArray arrayWithArray:players];
    _playersMap = [NSMutableDictionary new];
    for(Player* p in players) {
        [_playersMap setValue: p forKey: p.id];
    }
}

-(void) recordPlayersStatus {
    for(Player* p in _players) {
        [p recordStatus];
    }
    NSLog(@"== Record Players Status, stack depth = %d", [((Player*)[_players objectAtIndex:0]) getStackDepth]);
}

-(void) rollbackPlayersStatus {
    for (Player* p in _players) {
        [p rollbackStatus];
    }
    NSLog(@"== Rollback Players Status, stack depth = %d", [((Player*)[_players objectAtIndex:0]) getStackDepth]);
}

-(NSNumber*) doActionAtNight: (long) i withPlayer: (Player*) player {
    return [self doActionAtNight: i withActor: player andReceiver: nil];
}

-(NSNumber*) doActionAtNight: (long) i withActor: (Player*) actor andReceiver: (Player*) receiver {
    return [self doActionAtNight: i withActors: [NSArray arrayWithObject: actor] andReceiver: nil];
}

-(BOOL) isEligibleActionAtNight: (long) i withActors: (NSArray*) actors andReceiver: (Player*) receiver {
    if(receiver.status == IN_GAME) {
        return YES;
    }
    
    for(Rule* r in self.rules) {
        if([self isRule: r matchedWithActors: actors andReceiver: receiver atNight: i]) {
            return YES;
        }
    }
    
    return NO;
}

-(NSNumber*) doActionAtNight: (long) i withActors: (NSArray*) actors andReceiver: (Player*) receiver {
    NSNumber* result = nil;
    BOOL isProcessed = NO;
    
    // find rules to execute
    NSMutableArray* matchedRules = [NSMutableArray new];
    for(Rule* r in self.rules) {
        if([self isRule: r matchedWithActors: actors andReceiver: receiver atNight: i]) {
            [matchedRules addObject: r];
        }
    }
    for(Rule* r in matchedRules) {
        isProcessed = YES;
        for(Operation* o in r.operations) {
            result = [self executeOperation: o withRule: r andActors: actors andReceiver: receiver atNight: i];
        }
    }
    
    if(receiver != nil) {
        for(Player* p in actors) {
            [p addActionAtNight: i to: receiver.id forResult: (result==nil?[NSNumber numberWithBool: isProcessed]:result) withMatchedRules: matchedRules];
        }
    }
    
    return result;
}

-(BOOL) isRule: (Rule*) rule matchedWithActors: (NSArray*) actors andReceiver: (Player*) receiver atNight: (long) i {
    BOOL result = NO;
    for(Player* actor in actors) {
        if(actor != nil && rule.actor == actor.role &&
           ((rule.receiver == Anybody && receiver != nil) || (rule.receiver == Receiver && receiver == nil) || (receiver != nil && rule.receiver == receiver.role))
        ) {
            result = YES;
        
            if(rule.receiver == Receiver) {
                receiver = [self getReceiverForActor: [actors objectAtIndex: 0] atNight: i];
            }
        
            for(Condition* c in rule.conditions) {
                Player* p1 = [self getPlayerFrom: actor and: receiver withRole: c.role1];
                Player* p2 = [self getPlayerFrom: actor and: receiver withRole: c.role2];
                if(![c compare: p1 with: p2 ]) {
                    return NO;    
                };
            }
        } else {
            return NO;
        }
    }
    
    return result;
}

-(int) getRoleNumber : (Role) r {
    NSNumber* num = (NSNumber*)[_roleNumbers objectForKey:[Engin getRoleName:r]];
    return (num && num.intValue > 0) ? num.intValue : 0;                 
}

-(Player*) getPlayerById: (NSString*) id {
    return [_playersMap objectForKey: id];
}

-(NSArray*) getPlayersByRole: (Role) role {
    return [self getPlayersByRole: role withIn: self.players];
}

-(NSArray*) getPlayersByRole: (Role) role withIn: (NSArray*) players {
    if(players == nil) {
        players = self.players;
    }
    
    NSMutableArray* list = [NSMutableArray new];
    for(Player* p in players) {
        if(p.role == role) {
            [list addObject: p];
        }
    }
    
    return list;
}

-(Player*) getReceiverForActor: (Player*) actor atNight: (long) i {
    return [self getPlayerById: [actor getActionReceiverAtNight: i]];
}

-(BOOL) isEffectiveActionForActor: (Player*) actor atNight: (long) i {
    return [actor isEffectiveActionAtNight: i];
}

-(NSArray*) getApplicatedRulesForActor: (Player*) actor atNight: (long) i {
    return [actor getApplicatedRulesAtNight: i];
}


-(Player*) getPlayerFrom: (Player*) p1 and: (Player*) p2 withRole: (Role) r {
    return (r == 0 || r == Receiver || r == Anybody) ? p2 : p1.role == r ? p1 : p2;
}

-(void) resetDistance {
    for(Player* p in self.players) {
        [p resetDistance];
    }
}


-(NSNumber*) executeOperation: (Operation*) o withRule: (Rule*) rule andActors: (NSArray*) actors andReceiver: (Player*) receiver atNight: (long) i {
    NSNumber* result = nil;
    
    if(rule.receiver == Receiver) {
        receiver = [self getReceiverForActor: [actors objectAtIndex: 0] atNight: i];
    }
    
    if(o.role2 == 0 && (receiver.role == o.role1 || o.role1 == Receiver || o.role1 == Anybody)) {
        result = [o execute: receiver : nil : self.players];
    } else {
        for(Player* a in actors) {
            result = [o execute: a : receiver : self.players];
        }
    }
    
    return result;
}


-(int) calculateFinalResult {
    Player* game = [[Player alloc] init: @"game" andName: @"Game" withRole: Game];
    
    for(Rule* r in self.resultRules) {
        BOOL isMatched = YES;
        for(Condition* c in r.conditions) {
            for(Player* p1 in [self getPlayersByRole: c.role1]) {
                NSArray* p2s = [self getPlayersByRole: c.role2];
                if(p2s != nil && [p2s count] > 0) {
                    for(Player* p2 in p2s) {
                        isMatched = isMatched && [c compare: p1 with: p2];
                    }
                } else {
                    isMatched = isMatched && [c compare: p1 with: nil];
                } 
            }
        }
        if(isMatched) {
            for(Operation* o in r.operations) {
                [o execute: game : nil : self.players];
            }
        }
    }
    
    return [[NSNumber numberWithDouble: game.note] intValue];
}

@end



