//
//  ConsoleEngin.m
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import "ConsoleEngin.h"
#import "Rule.h"


@implementation ConsoleEngin

-(NSString*) readLine {
    NSFileHandle *inputFile = [NSFileHandle fileHandleWithStandardInput];
    NSMutableString *inputString = [NSMutableString string];
    
    //do {
    // Read from stdin, check for EOF:
    NSData *data = [inputFile availableData];
    if ([data length] == 0) {
        //NSLog(@"EOF");
        //break;
    }
    // Convert to NSString, replace newlines by spaces, append to current input:
    NSMutableString *tmp = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [tmp replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, [tmp length])];
    [inputString appendString:tmp];
    // Check for semi-colon:
    //} while ([inputString rangeOfString:@";"].location == NSNotFound);
    
    //NSFileHandle *input = [NSFileHandle fileHandleWithStandardInput];
    //NSData *inputData = [NSData dataWithData:[input readDataToEndOfFile]];
    //NSString *inputString = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
    
    return inputString;
}

-(void) run {
    long i = 1;
    while (YES) {
        //1. prepare current active players
        NSMutableArray* initialPlayers = [NSMutableArray new];
        NSMutableArray* currentPlayers = [NSMutableArray new];
        
        for(Player* p in self.players) {
            if([p isInGame]) {
                [initialPlayers addObject: p];
                [currentPlayers addObject: p];
            }
        }
        
        //2. game tour start
        NSLog(@"第%li%@ 天黑请闭眼", i, @"夜");
        [self printPlayersInfo: initialPlayers];
        
        //3. people who has role show up one after another
        for(NSString* sr in _orders) {
            Role r = [Engin getRoleFromString: sr];
            NSLog(@"%@请出来", [self getRoleLabel: r]);
            
            //4. calculate players with the same current role
            NSArray* playersInAction = [self getPlayersByRole: r withIn: currentPlayers];
            Player* selectedPlayer = nil;
            
            do {
                //5. select a receiver for current role action
                NSLog(@"%@请%@", [self getRoleLabel: r], [self getRoleActionTerm: r]);
                
                NSString* n = [self readLine];
                selectedPlayer = [self getPlayerById: n];
            } while (playersInAction != nil && [playersInAction count] > 0 && selectedPlayer == nil);
            
            //6. take action effect, show response if have one
            if(playersInAction != nil && [playersInAction count] > 0) {
                NSNumber* result = [self doActionAtNight: i withActors: [self getPlayersByRole: r] andReceiver: selectedPlayer];
                if(result != nil) {
                    NSLog(@"%@请看好结果: %@", [self getRoleLabel: r], ([result boolValue]?@"正确":@"错误"));
                }
            }
            
            //7. send back current players
            NSLog(@"%@请回去", [self getRoleLabel: r]);
            NSLog(@"----------------");
        }
        
        //8. do clearence after one night
        for(Player* p in self.players) {
            [self doActionAtNight: i withPlayer: p];
        }
        
        //9. remove dead persons from game
        NSMutableArray* deads = [NSMutableArray new];
        for(Player* p in currentPlayers) {
            if(p.life <= 0) {
                p.status = OUT_GAME;
                [deads addObject: p];
            }
        }
        [currentPlayers removeObjectsInArray: deads];
        
        //10. day light turn up
        NSLog(@"天亮了");
        
        //11. anounce the result
        [self printPlayersInfo: initialPlayers];
        NSString* deadNames = [deads count]==0 ? @"无人" : @"";
        BOOL isFirst = YES;
        for(Player* p in deads) {
            deadNames = [[deadNames stringByAppendingString: (isFirst?@"":@", ")] stringByAppendingString: p.name];
            isFirst = NO;
        }
        NSLog(@"今夜%@%@", deadNames, @"死亡");
        
        //12. test if game is over, if not, continue the game
        if([self printFinalResultAtNight: i]) {
            break;
        }
        
        [self printCurrentNightInfo: i];
        
        //13. vote a player to be execute
        NSLog(@"请投票");
        NSString* n = [self readLine];
        
        //14. execution
        [self doActionAtNight: i withActors: [self getPlayersByRole: Judge] andReceiver: [self getPlayerById: n]];
        [deads removeAllObjects];
        for(Player* p in currentPlayers) {
            if(p.life <= 0) {
                p.status = OUT_GAME;
                [deads addObject: p];
            }
        }
        deadNames = [deads count] == 0 ? @"无人" : @"";
        isFirst = YES;
        for(Player* p in deads) {
            deadNames = [[deadNames stringByAppendingString: (isFirst?@"":@", ")] stringByAppendingString: p.name];
            isFirst = NO;
        }
        
        [self printPlayersInfo: currentPlayers];
        NSLog(@"投票结果：%@死亡", deadNames);
        NSLog(@"------------------------------------------");
        
        //15. test if game is over, if not, continue the game
        if([self printFinalResultAtNight: i]) {
            break;
        }
        
        //16. prepare for the next tour
        i++;
        [self resetDistance];
    }
}

-(BOOL) printFinalResultAtNight: (long) i {
    int result = [self calculateFinalResultAtNight: i ];
    if(result > 99) {
        NSLog(@"杀手及警察同时死亡，游戏平局");
        return true;
    } else if(result < 0 ) {
        NSLog(@"邪恶一方获胜");
        return true;
    } else if(result > 0) {
        NSLog(@"正义一方获胜");
        return true;
    }
    
    return false;
}

-(void) printCurrentNightInfo: (long) i {
    NSLog(@"  ===============");
    NSLog(@"  当夜信息");
    for(NSString* sr in _orders) {
        Role r = [Engin getRoleFromString: sr];
        Player* receiver = nil;
        BOOL actionProcessed = NO;
        NSArray* applicatedRules = nil;
        for(Player* p in [self getPlayersByRole: r]) {
            receiver = [self getReceiverForActor: p atNight: i];
            actionProcessed = [self isEffectiveActionForActor: p atNight: i];
            applicatedRules = [self getApplicatedRulesForActor: p atNight: i];
            if(receiver != nil) {
                break;
            }
        }
        if(receiver != nil) {
            NSLog(@"    %@%@%@ : \t%@", [self getRoleLabel: r], [self getRoleActionLabel: r], receiver.id, [self getActionDoneLabel: actionProcessed : applicatedRules]);
        }
    }
    NSLog(@"  ===============");
}

-(void) printPlayersInfo: (NSArray*) players {
    NSLog(@"  ===============");
    NSLog(@"  当前玩家信息");
    for(Player* p in players) {
        if(p.role != Judge) {
            NSLog(@"    %@ \t(%@)", p.name, ([p isInGame] ? [[NSNumber numberWithDouble: p.life] stringValue] : @"死亡"));
        }
    }
    NSLog(@"  ===============");
}

-(NSString*) getRoleLabel: (Role) r {
    switch (r) {
        case Guard:
            return @"花蝴蝶";
        case Killer:
            return @"杀手";
        case Police:
            return @"警察";
        case Doctor:
            return @"医生";
        case Spy:
            return @"老婆";
        case Judge:
            return @"法官";
        case Assassin:
            return @"暗杀";
        case Undercover:
            return @"卧底";
        default:
            return [Engin getRoleName: r];
    }
}

-(NSString*) getRoleActionTerm: (Role) r {
    switch (r) {
        case Guard:
            return @"抱人";
        case Killer:
            return @"杀人";
        case Police:
            return @"验人";
        case Doctor:
            return @"扎人";
        case Spy:
            return @"认夫";
        case Judge:
            return @"判决";
        case Assassin:
            return @"杀人";
        case Undercover:
            return @"验人";
        default:
            return @"";
    }
}

-(NSString*) getRoleActionLabel: (Role) r {
    switch (r) {
        case Guard:
            return @"抱";
        case Killer:
            return @"杀";
        case Police:
            return @"验";
        case Doctor:
            return @"扎";
        case Spy:
            return @"认";
        case Judge:
            return @"处死";
        case Assassin:
            return @"杀";
        case Undercover:
            return @"验";
        default:
            return @"";
    }
}

-(NSString*) getActionDoneLabel: (BOOL) actionProcessed : (NSArray*) applicatedRules {
    NSString* label = nil;
    NSString* key = @"";
    if(applicatedRules != nil) {
        applicatedRules = [applicatedRules sortedArrayUsingComparator:^(Rule* r1, Rule* r2){
            return [r1.name compare: r2.name];
        }];
        
        BOOL isFirst = YES;
        for(Rule* r in applicatedRules) {
            key = [[key stringByAppendingString: (isFirst?@"":@",")] stringByAppendingString: r.name];
            isFirst = NO;
        }
    }
    
    if([key isEqualToString: @"Doctor+"]) {
        label = @"成功救治";
    } else if([key isEqualToString: @"Doctor-"]) {
        label = @"成功扎针";
    }
    
    return label==nil?(actionProcessed?@"成功":@"失败"):label;
}

@end

