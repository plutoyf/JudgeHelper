    //
//  HelloWorldLayer.m
//  JudgeHelper
//
//  Created by YANG FAN on 20/07/13.
//  Copyright YANG FAN 2013. All rights reserved.
//


// Import the interfaces
#import "CCEngin.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "RuleResolver.h"
#import "MySprite.h"

static CCEngin *engin = nil;

@implementation CCEngin

+(CCEngin*) getEngin {
    if(engin == nil) {
        engin = [[CCEngin new] initWithRules:[self createRules] andResultRules:[self createResultRules] andRoles:[self createRoles] andOrders:[self createOrders]];
        [engin initRoles:[self createRoleNumbers]];
    }
    return engin;
}

+(NSMutableArray*) createRoles {
    NSString* rolesString = @"Judge(1), Guard(1), Killer(2), Police(2), Doctor(1), Spy(1), Citizen(3)";
    rolesString = @"Judge(1), Guard(0), Killer(1), Police(1), Doctor(0), Spy(0), Citizen(0)";
    return [RuleResolver resolveRoles: rolesString];
}

+(NSMutableDictionary*) createRoleNumbers {
    NSString* rolesString = @"Judge(1), Guard(1), Killer(2), Police(2), Doctor(1), Spy(1), Citizen(3)";
    rolesString = @"Judge(1), Guard(0), Killer(1), Police(1), Doctor(0), Spy(0), Citizen(0)";
    return [RuleResolver resolveRoleNumbers: rolesString];
}

+(NSMutableArray*) createOrders {
    NSString* ordersString = @"Guard, Killer, Police, Doctor, Spy";
    return [RuleResolver resolveOrder: ordersString];
}

+(NSArray*) createRules {
    NSString* rulesString = @"";
    rulesString = [rulesString stringByAppendingString: @"Rule ( Guard+  ) :  Guard,  Anybody  -[ status(Anybody) == IN_GAME ; distance(Guard,  Anybody) == 1                      ]>  distance(Anybody)  =  1.1  ; distance(Guard, Anybody) = 0.1 "];
    rulesString = [rulesString stringByAppendingString: @"Rule ( Guard-  ) :  Guard            -[ distance(Guard, Receiver) < 1 ; life(Guard) <= 0 ]>  life(Receiver)     =  0                                     "];
    rulesString = [rulesString stringByAppendingString: @"Rule ( Killer  ) :  Killer, Anybody  -[ status(Anybody) == IN_GAME ; distance(Killer, Anybody) <= 1                      ]>  life(Anybody)     -= 1                                      "];
    rulesString = [rulesString stringByAppendingString: @"Rule ( Doctor+ ) :  Doctor, Anybody  -[ status(Anybody) == IN_GAME ; distance(Doctor, Anybody) <= 1 ; life(Anybody) <= 0 ]>  life(Anybody)     += 1                                      "];
    rulesString = [rulesString stringByAppendingString: @"Rule ( Doctor- ) :  Doctor, Anybody  -[ status(Anybody) == IN_GAME ; distance(Doctor, Anybody) <= 1 ; life(Anybody) >  0 ]>  life(Anybody)     -= 0.5                                    "];
    rulesString = [rulesString stringByAppendingString: @"Rule ( Judge   ) :  Judge,  Anybody  -[ status(Anybody) == IN_GAME ; distance(Judge,  Anybody) <= 1                      ]>  life(Anybody)      =  0                                     "];
    rulesString = [rulesString stringByAppendingString: @"Rule ( Police  ) :  Police, Anybody  -[ ]>  role(Anybody) == Killer                                 "];
    rulesString = [rulesString stringByAppendingString: @"Rule ( Spy     ) :  Spy,    Anybody  -[ ]>  role(Anybody) == Killer                                 "];
    
    return [RuleResolver resolveRules: rulesString];
    
}

+(NSArray*) createResultRules {
    NSString* resultRulesString = @"";
    resultRulesString = [resultRulesString stringByAppendingString: @"Rule ( Police1 ) :  Game  -[ life(Killer) <=0 ]>  note(Game) += 2 "];
    resultRulesString = [resultRulesString stringByAppendingString: @"Rule ( Killer1 ) :  Game  -[ life(Police) <=0 ]>  note(Game) -= 1 "];
    resultRulesString = [resultRulesString stringByAppendingString: @"Rule ( Killer2 ) :  Game  -[ life(Guard)  <=0 ; life(Doctor) <=0 ; life(Spy) <=0 ; life(Citizen) <=0 ]>  note(Game) -= 1 "];
    resultRulesString = [resultRulesString stringByAppendingString: @"Rule ( Equals  ) :  Game  -[ life(Police) <=0 ; life(Killer) <=0 ]>  note(Game) += 999 "];
    
    return [RuleResolver resolveRules: resultRulesString];
}

//GAME ENGIN

-(void) run {
    inGame = TRUE;
    night = 0;
    state = 1;
    oIndex = 0;
    [self doAction];
}

-(void) doAction {
    [self doAction: NO];
}

-(void) doAction: (BOOL) speedMode {
    if(!inGame) {
        return;
    }
    
    if([self getPlayersByRole: Judge].count <= 0) {
        [self.displayDelegate definePlayerForRole: Judge];
        return;
    }
    
    NSString* deadNames;
    NSArray* playersInAction;
    switch (state) {
        case 1:
            NSLog(@"case 1");
            night++;
            [self.displayDelegate showNightMessage: night];
            
            //1. prepare current active players
            initialPlayers = [NSMutableArray new];
            currentPlayers = [NSMutableArray new];
            
            for(Player* p in _players) {
                if([p isInGame]) {
                    [initialPlayers addObject: p];
                    [currentPlayers addObject: p];
                }
            }
            
            [self.displayDelegate backupActionIcon];
            [self.displayDelegate showMessage: [NSString stringWithFormat:@"第%li%@ 天黑请闭眼", night, @"夜"]];
            state++;
            if(!speedMode) break;
        case 2:
            NSLog(@"case 2");
            if(oIndex < 0 || oIndex >= _orders.count) {
                oIndex = 0;
            }
            
            //2. people who has role show up one after another
            roleInAction = [Engin getRoleFromString: [_orders objectAtIndex: oIndex]];
            
            [self.displayDelegate showMessage: [NSString stringWithFormat:@"%@请出来", [self getRoleLabel: roleInAction]]];
            state++;
            
            if([self getPlayersByRole: roleInAction].count != [self getRoleNumber: roleInAction]) {
                [self.displayDelegate definePlayerForRole: roleInAction];
                break;
            } else {
                if(!speedMode) break;
            }
        case 3:
            NSLog(@"case 3");
            if([self getPlayersByRole: roleInAction].count == [self getRoleNumber: roleInAction]) {
                [self.displayDelegate showMessage: [NSString stringWithFormat:@"%@请%@", [self getRoleLabel: roleInAction], [self getRoleActionTerm: roleInAction]]];
                state++;
            }
            break;
        case 4:
            NSLog(@"case 4");
            //6. take action effect, show response if have one
            playersInAction = [self getPlayersByRole: roleInAction withIn: currentPlayers];
            if(playersInAction != nil && playersInAction.count > 0) {
                //calculate players with the same current role
                selectedPlayer = [self getPlayerById: selectedPlayerId];
                if(selectedPlayer != nil && [self isEligibleActionAtNight: night withActors: [self getPlayersByRole: roleInAction] andReceiver: selectedPlayer]){
                    NSLog(@"%ld - %@", night, [self getRoleLabel:roleInAction]);
                    
                    [self recordPlayersStatus];
                    
                    Player* actor = [playersInAction objectAtIndex:0];
                    NSNumber* result = [self doActionAtNight: night withActors: playersInAction andReceiver: selectedPlayer];
                    
                    [self.displayDelegate addPlayersStatusWithActorRole:roleInAction andReceiver:selectedPlayer andResult: [actor getActionResultAtNight:night].boolValue];
                    [self.displayDelegate addActionIcon: ((Player*)[playersInAction objectAtIndex: 0]).role to: selectedPlayer withResult: [actor getActionResultAtNight:night].boolValue];
                    [self.displayDelegate updatePlayerLabels];
                    [self debugPlayers];
                    
                    state++;
                    if(result != nil) {
                        [self.displayDelegate showMessage: [NSString stringWithFormat:@"%@请看好结果: %@", [self getRoleLabel: roleInAction], ([result boolValue]?@"正确":@"错误")]];
                        if(!speedMode) break;
                    }
                } else {
                    break;
                }
                
            } else {
                [self recordPlayersStatus];
                [self.displayDelegate addPlayersStatusWithActorRole:nil andReceiver:nil andResult:nil];
                NSLog(@"%ld - %@", night, [self getRoleLabel:roleInAction]);
                
                state++;
            }
        case 5:
            NSLog(@"case 5");
            //send back current players
            [self.displayDelegate showMessage: [NSString stringWithFormat:@"%@请回去", [self getRoleLabel: roleInAction]]];
            state++;
            if(!speedMode) break;
        case 6:
            NSLog(@"case 6");
            oIndex++;
            
            if (oIndex < _orders.count) {
                state = 2;
                [self doAction: speedMode];
                break;
            } else {
                NSLog(@"%ld - %@", night, [self getRoleLabel:roleInAction]);
                
                [self recordPlayersStatus];
                
                //8. do clearence after one night
                for(Player* p in currentPlayers) {
                    [self doActionAtNight: night withPlayer: p];
                }
                
                //9. remove dead persons from game
                deadPlayers = [NSMutableArray new];
                for(Player* p in currentPlayers) {
                    if(p.life <= 0) {
                        p.status = OUT_GAME;
                        [deadPlayers addObject: p];
                    }
                }
                [currentPlayers removeObjectsInArray: deadPlayers];
                
                [self.displayDelegate addPlayersStatusWithActorRole:nil andReceiver:nil andResult:nil];
                [self.displayDelegate updatePlayerIcons];
                [self.displayDelegate updatePlayerLabels];
                
                //10. day light turn up
                [self.displayDelegate showMessage: @"天亮了"];
                state++;
                if(!speedMode) break;
            }
        case 7:
            NSLog(@"case 7");
            //11. anounce the result
            [self debugPlayersInfo: initialPlayers];
            
            deadNames = deadPlayers.count==0 ? @"无人" : @"";
            BOOL isFirst = YES;
            for(Player* p in deadPlayers) {
                deadNames = [[deadNames stringByAppendingString: (isFirst?@"":@", ")] stringByAppendingString: p.name];
                isFirst = NO;
            }
            
            [self.displayDelegate updatePlayerIcons];
            [self debugPlayers];
            [self.displayDelegate showMessage: [NSString stringWithFormat:@"今夜%@%@", deadNames, @"死亡"]];
            state++;
            break;
        case 8:
            NSLog(@"case 8");
            [self debugCurrentNightInfo: night];
            state++;
        case 9:
            NSLog(@"case 9");
            //test if game is over, if not, continue the game
            if([self printFinalResult]) {
                inGame = NO;
                state = 0;
                break;
            }
            
            roleInAction = Judge;
            //vote a player to be execute
            [self.displayDelegate showMessage: @"请投票"];
            state++;
            break;
        case 10:
            NSLog(@"case 10");
            //calculate players with the same current role
            selectedPlayer = [self getPlayerById: selectedPlayerId];
            if(selectedPlayer != nil && [self isEligibleActionAtNight: night withActors: [self getPlayersByRole: roleInAction] andReceiver: selectedPlayer]){
                //14. execution
                NSLog(@"%ld - %@", night, [self getRoleLabel:roleInAction]);
                
                [self recordPlayersStatus];
                
                NSArray* actors = [self getPlayersByRole:roleInAction];
                Player* actor = [actors objectAtIndex:0];
                [self doActionAtNight: night withActors: actors andReceiver: selectedPlayer];
                [self.displayDelegate updatePlayerLabels];
                
                NSMutableArray* deads = [NSMutableArray new];
                for(Player* p in currentPlayers) {
                    if(p.life <= 0) {
                        p.status = OUT_GAME;
                        [deads addObject: p];
                    }
                }
                NSString* deadNames = [deads count]==0 ? @"无人" : @"";
                BOOL isFirst = YES;
                for(Player* p in deads) {
                    deadNames = [[deadNames stringByAppendingString: (isFirst?@"":@", ")] stringByAppendingString: p.name];
                    isFirst = NO;
                }
                
                [self debugPlayers];
                [self debugPlayersInfo: currentPlayers];
                
                [self.displayDelegate addPlayersStatusWithActorRole:Judge andReceiver:selectedPlayer andResult: [actor getActionResultAtNight:night].boolValue];
                [self.displayDelegate updatePlayerIcons];
                [self.displayDelegate showMessage: [NSString stringWithFormat:@"投票结果：%@死亡", deadNames]];
                state++;
                break;
            } else {
                break;
            }
        case 11:
            NSLog(@"case 11");
            //test if game is over, if not, continue the game
            if([self printFinalResult]) {
                inGame = NO;
                state = 0;
            }
            
            NSLog(@"continue");
            
            //prepare for the next tour
            [self resetDistance];
            state = 1;
            [self doAction: speedMode];
            break;
        default:
            break;
    }
}

-(void) undoAction {
    if(!inGame || night < 1) {
        return;
    }
    
    switch (state) {
        case 1:
            if(night == 1) {
                break;
            }
        case 11:
            // go back to state 10
            NSLog(@"%ld - %@", night, [self getRoleLabel:roleInAction]);
            [self rollbackPlayersStatus];
            [self.displayDelegate updatePlayerLabels];
            [self.displayDelegate updatePlayerIcons];
            [self.displayDelegate showMessage: @"请投票"];
            state=10;
            break;
        case 2:
        case 3:
        case 4:
            if((oIndex <= 0 || oIndex >= _orders.count) && night>1) {
                NSLog(@"%ld - %@", night, [self getRoleLabel:roleInAction]);
                [self rollbackPlayersStatus];   
                [self calculateCurrentPlayers];
                [self.displayDelegate updatePlayerLabels];
                [self.displayDelegate updatePlayerIcons];
                [self.displayDelegate showMessage: @"请投票"];
                roleInAction = Judge;
                oIndex = _orders.count;
                night--;
                [self.displayDelegate showNightMessage: night];
                [self.displayDelegate restoreBackupActionIcon];
                state=10;
                break;
            }
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
            if(oIndex > 0 || (oIndex == 0 && night > 1) || state >= 5) {
                if(state != 5 && state != 6)oIndex--;
                //people who has role show up one after another
                roleInAction = [Engin getRoleFromString: [_orders objectAtIndex: oIndex]];
                NSArray* playersInAction = [self getPlayersByRole: roleInAction];
                
                NSLog(@"%ld - %@", night, [self getRoleLabel:roleInAction]);
                [self rollbackPlayersStatus];
                if(oIndex == _orders.count-1 && state >= 7) {
                    NSLog(@"%ld - %@", night, [self getRoleLabel:roleInAction]);
                    [self rollbackPlayersStatus];
                    [self calculateCurrentPlayers];
                    [self.displayDelegate resetPlayerIcons: currentPlayers];
                }
                [self.displayDelegate updatePlayerLabels];
                [self.displayDelegate removeActionIconFrom: [self getReceiverForActor: [playersInAction objectAtIndex:0] atNight: night]];
                [self.displayDelegate showMessage: [NSString stringWithFormat:@"%@请%@", [self getRoleLabel: roleInAction], [self getRoleActionTerm: roleInAction]]];
                [self.displayDelegate definePlayerForRole:0];
                state = 4;
            } else if(night > 1) {
                state = 1;
                [self undoAction];
            }
            break;
        default:
            break;
    }
    
    [self debugPlayers];
    
}

-(void) redoAction {
    if(!inGame) {
        return;
    }
    
    NSArray* playersInAction = [self getPlayersByRole: roleInAction withIn: currentPlayers];
    if(playersInAction != nil && [playersInAction count] > 0) {
        Player* actor = (Player*)[playersInAction objectAtIndex:0];
        Player* receiver = [self getReceiverForActor:actor atNight:night];
        [self action: (receiver==nil ? @"" : receiver.id) inSpeed:YES];
    } else {
        [self action: @"" inSpeed:YES];
    }
    
    [self debugPlayers];
}

-(void) recordPlayersStatus {
    [super recordPlayersStatus];
}

-(void) rollbackPlayersStatus {
    [super rollbackPlayersStatus];
    [self.displayDelegate rollbackPlayersStatus];
}

-(void) calculateCurrentPlayers {
    [currentPlayers removeAllObjects];
    for(Player* p in _players) {
        if([p isInGame]) {
            [currentPlayers addObject:p];
        }
    }
}

-(Role) getCurrentRole {
    return (oIndex < 0 || oIndex >= _orders.count) ? 0 : [Engin getRoleFromString: [_orders objectAtIndex: oIndex]];
}

-(int) getCurrentNight {
    return night > 0 ? night : 0;
}


-(void) action: (NSString*) id {
    [self action:id inSpeed: NO];
}

-(void) action: (NSString*) id inSpeed: (BOOL) speedMode {
    if(inGame) {
        if([id isEqualToString: @"UNDO_ACTION"]) {
            selectedPlayerId = @"";
            selectedPlayer = nil;
            [self undoAction];
            
        } else if([id isEqualToString: @"REDO_ACTION"]) {
            selectedPlayerId = @"";
            selectedPlayer = nil;
            [self redoAction];
            
        } else {
            selectedPlayerId = id;
            selectedPlayer = nil;
            [self doAction: speedMode];
        }
    }
}


-(BOOL) printFinalResult {
    int result = [self calculateFinalResult];
    BOOL isFinished = NO;
    if(result > 99) {
        [self.displayDelegate showMessage:@"杀手及警察同时死亡，游戏平局"];
        isFinished = YES;
    } else if(result < 0 ) {
        [self.displayDelegate showMessage:@"邪恶一方获胜"];
        isFinished = YES;
    } else if(result > 0) {
        [self.displayDelegate showMessage:@"正义一方获胜"];
        isFinished = YES;
    }
    
    if(isFinished) {
        [self.displayDelegate gameFinished];
        return isFinished;
    }
    
    return false;
}

// labels - TODO: i18n
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
        default:
            return @"";
    }
}

+(NSString*) getRoleCode: (Role) r {
    switch (r) {
        case Guard:
            return @"guard";
        case Killer:
            return @"killer";
        case Police:
            return @"police";
        case Doctor:
            return @"doctor";
        case Spy:
            return @"spy";
        case Judge:
            return @"judge";
        default:
            return @"citizen";
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

//Debug
-(void) debugPlayers {
    [self.displayDelegate showDebugMessage:@"" inIncrement:NO];
    for(Player* p in _players) {
        [self.displayDelegate showPlayerDebugMessage:p inIncrement:YES];
    }
}

-(void) debugCurrentNightInfo: (long) i {
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
            NSLog(@"    %@%@%@ : \t%@", [self getRoleLabel: r], [self getRoleActionLabel: r], receiver.name, [self getActionDoneLabel: actionProcessed : applicatedRules]);
        }
    }
    NSLog(@"  ===============");
}

-(void) debugPlayersInfo: (NSArray*) players {
    NSLog(@"  ===============");
    NSLog(@"  当前玩家信息");
    for(Player* p in players) {
        if(p.role != Judge) {
            NSLog(@"    %@ \t(%@)", p.name, ([p isInGame] ? [[NSNumber numberWithDouble: p.life] stringValue] : @"死亡"));
        }
    }
    NSLog(@"  ===============");
}

@end


