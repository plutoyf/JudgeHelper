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
        engin = [[CCEngin new] initWithRules:[self createEligibilityRules] :[self createActionRules] :[self createClearenceRules] :[self createResultRules] andRoles:[self createRoles] andOrders:[self createOrders]];
        [engin initRoles:[self createRoleNumbers]];
    }
    return engin;
}

+(NSMutableArray*) createRoles {
    NSString* rolesString = @"Judge(1), Guard(1), Killer(2), Police(2), Doctor(1), Spy(1), Citizen(3), Assassin(0), Undercover(0)";
    //rolesString = @"Judge(1), Guard(0), Killer(1), Police(1), Doctor(0), Spy(0), Citizen(16), Assassin(0), Undercover(0)";
    return [RuleResolver resolveRoles: rolesString];
}

+(NSMutableDictionary*) createRoleNumbers {
    NSString* rolesString = @"Judge(1), Guard(1), Killer(2), Police(2), Doctor(1), Spy(1), Citizen(3), Assassin(0), Undercover(0)";
    rolesString = @"Judge(1), Guard(0), Killer(1), Police(1), Doctor(0), Spy(0), Citizen(0), Assassin(0), Undercover(0)";
    return [RuleResolver resolveRoleNumbers: rolesString];
}

+(NSString*) getOrdersString {
    return @"Assassin, Guard, Killer, Police, Doctor, Spy, Undercover";
}

+(NSMutableArray*) createOrders {
    return [RuleResolver resolveOrder: [self getOrdersString]];
}

+(NSArray*) getEligibilityRulesArray {
    NSMutableArray* rulesArray = [NSMutableArray new];
    [rulesArray addObject: @"Rule ( Guard-select      ) :  Guard, Anybody       -[ status(Anybody) == IN_GAME ; distance(Guard, Anybody) < 2 ]>"];
    [rulesArray addObject: @"Rule ( Killer-select     ) :  Killer, Anybody      -[ status(Anybody) == IN_GAME ; ]>"];
    [rulesArray addObject: @"Rule ( Doctor-select     ) :  Doctor, Anybody      -[ status(Anybody) == IN_GAME ; ]>"];
    [rulesArray addObject: @"Rule ( Judge-select      ) :  Judge, Anybody       -[ status(Anybody) == IN_GAME ; ]>"];
    [rulesArray addObject: @"Rule ( Police-select     ) :  Police, Anybody      -[ ]>"];
    [rulesArray addObject: @"Rule ( Spy-select        ) :  Spy, Anybody         -[ ]>"];
    [rulesArray addObject: @"Rule ( Assassin-select   ) :  Assassin, Anybody    -[ status(Anybody) == IN_GAME ; ]>"];
    [rulesArray addObject: @"Rule ( Assassin-select   ) :  Assassin, Anybody    -[ role(Anybody)   == Game    ; ]>"];
    [rulesArray addObject: @"Rule ( Undercover-select ) :  Undercover, Anybody  -[ ]>"];
    return rulesArray;
}

+(NSArray*) getActionRulesArray {
    NSMutableArray* rulesArray = [NSMutableArray new];
    [rulesArray addObject: @"Rule ( Guard-protect        ) :  Guard,      Anybody  -[ distance(Guard,  Anybody) <= 1 ]>  distance(Anybody) = 1.1 ; distance(Guard, Anybody) = 0.1 "];
    [rulesArray addObject: @"Rule ( Killer-kill          ) :  Killer,     Anybody  -[ distance(Killer, Anybody) <= 1 ; role(Anybody) != Assassin ]>  life(Anybody) -= 1 "];
    [rulesArray addObject: @"Rule ( Doctor-cure          ) :  Doctor,     Anybody  -[ distance(Doctor, Anybody) <= 1 ; life(Anybody) <= 0 ]> life(Anybody) += 1   "];
    [rulesArray addObject: @"Rule ( Doctor-miss          ) :  Doctor,     Anybody  -[ distance(Doctor, Anybody) <= 1 ; life(Anybody) >  0 ]> life(Anybody) -= 0.5 "];
    [rulesArray addObject: @"Rule ( Judge-lyncher        ) :  Judge,      Anybody  -[ distance(Judge,  Anybody) <= 1 ]>  life(Anybody) = 0 "];
    [rulesArray addObject: @"Rule ( Assassin-kill        ) :  Assassin,   Anybody  -[ role(Anybody) != Game ]>  role(Assassin) = Killer ; life(Anybody) -= 2 ; "];
    [rulesArray addObject: @"Rule ( Police-research      ) :  Police,     Anybody  -[ ]>  role(Anybody) == Killer "];
    [rulesArray addObject: @"Rule ( Spy-research         ) :  Spy,        Anybody  -[ ]>  role(Anybody) == Killer "];
    [rulesArray addObject: @"Rule ( Undercover-research1 ) :  Undercover, Anybody  -[ ]>  role(Anybody) == Killer "];
    [rulesArray addObject: @"Rule ( Undercover-research2 ) :  Undercover, Anybody  -[ ]>  role(Anybody) == Assassin "];
    return rulesArray;
}

+(NSArray*) getClearenceRulesArray {
    NSMutableArray* rulesArray = [NSMutableArray new];
    [rulesArray addObject: @"Rule ( Guard-dead      ) :  Guard            -[ distance(Guard, Receiver) < 1 ; life(Guard) <= 0 ]>  life(Receiver) = 0 "];
    [rulesArray addObject: @"Rule ( Guard-maxi      ) :  Guard            -[ distance(Guard, Receiver) < 1 ; distance(Guard, Receiver, -1) < 1 ; ]>  defaultDistance(Guard, Anybody) = 2 "];
    return rulesArray;
}

+(NSArray*) getResultRulesArray {
    NSMutableArray* rulesArray = [NSMutableArray new];
    [rulesArray addObject: @"Rule ( Police1         ) :  Game  -[ life(Killer) <= 0 ; life(Assassin)   <= 0 ]>  note(Game) += 2 "];
    [rulesArray addObject: @"Rule ( Killer1         ) :  Game  -[ life(Police) <= 0 ; life(Undercover) <= 0 ]>  note(Game) -= 1 "];
    [rulesArray addObject: @"Rule ( Killer2         ) :  Game  -[ life(Guard)  <= 0 ; life(Doctor)     <= 0 ; life(Spy)    <= 0 ; life(Citizen)  <= 0 ]>  note(Game) -= 1 "];
    [rulesArray addObject: @"Rule ( Equals          ) :  Game  -[ life(Police) <= 0 ; life(Undercover) <= 0 ; life(Killer) <= 0 ; life(Assassin) <= 0 ]>  note(Game) += 999 "];
    return rulesArray;
}

+(NSString*) getEligibilityRulesString {
    NSString* rulesString = @"";
    for(NSString* r in [self getEligibilityRulesArray]) {
        rulesString = [rulesString stringByAppendingString: r];
    }
    return rulesString;
}

+(NSArray*) createEligibilityRules {
    return [RuleResolver resolveRules: [self getEligibilityRulesString]];
}

+(NSString*) getActionRulesString {
    NSString* rulesString = @"";
    for(NSString* r in [self getActionRulesArray]) {
        rulesString = [rulesString stringByAppendingString: r];
    }
    return rulesString;
}

+(NSArray*) createActionRules {
    return [RuleResolver resolveRules: [self getActionRulesString]];
}

+(NSString*) getClearenceRulesString {
    NSString* rulesString = @"";
    for(NSString* r in [self getClearenceRulesArray]) {
        rulesString = [rulesString stringByAppendingString: r];
    }
    return rulesString;
}

+(NSArray*) createClearenceRules {
    return [RuleResolver resolveRules: [self getClearenceRulesString]];
}

+(NSString*) getResultRulesString {
    NSString* rulesString = @"";
    for(NSString* r in [self getResultRulesArray]) {
        rulesString = [rulesString stringByAppendingString: r];
    }
    return rulesString;
}

+(NSArray*) createResultRules {
    return [RuleResolver resolveRules: [self getResultRulesString]];
}

//GAME ENGIN

-(void) run {
    inGame = TRUE;
    night = 0;
    state = 1;
    oIndex = 0;
    playersInActionHistory = [NSMutableArray new];
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
            
            if([self getPlayersByRole: roleInAction].count != [self getCurrentRoleNumber: roleInAction]) {
                [self.displayDelegate definePlayerForRole: roleInAction];
                break;
            } else {
                if(!speedMode) break;
            }
        case 3:
            NSLog(@"case 3");
            if([self getPlayersByRole: roleInAction].count == [self getCurrentRoleNumber: roleInAction]) {
                playersInAction = [self getPlayersByRole: roleInAction withIn: currentPlayers];
                [self.displayDelegate showMessage: [NSString stringWithFormat:@"%@请%@", [self getRoleLabel: roleInAction], [self getRoleActionTerm: roleInAction]]];
                [self.displayDelegate updateEligiblePlayers: [self getEligiblePlayersAtNight:night wtihActors:playersInAction] withBypass: [self isBypassableActionAtNight:night withActors:playersInAction]];
                
                state++;
            }
            break;
        case 4:
            NSLog(@"case 4");
            //6. take action effect, show response if have one
            playersInAction = [self getPlayersByRole: roleInAction withIn: currentPlayers];
            if(playersInAction.count > 0) {
                
                //calculate players with the same current role
                selectedPlayer = [self getPlayerById: selectedPlayerId];
                if(selectedPlayer != nil && [self isEligibleActionAtNight: night withActors: [self getPlayersByRole: roleInAction] andReceiver: selectedPlayer]){
                    NSLog(@"%ld - %@", night, [self getRoleLabel:roleInAction]);
                    
                    [self.displayDelegate updateEligiblePlayers: nil withBypass: NO];
                    [self recordPlayersStatus];
                    
                    Player* actor = [playersInAction objectAtIndex:0];
                    NSNumber* result = [self doActionAtNight: night withActors: playersInAction andReceiver: selectedPlayer];
                    
                    [self.displayDelegate addPlayersStatusWithActorRole:roleInAction andReceiver:selectedPlayer andResult: [actor getActionResultAtNight:night forRole:roleInAction].boolValue];
                    [self.displayDelegate addActionIcon: roleInAction to: selectedPlayer withResult: [actor getActionResultAtNight:night forRole:roleInAction].boolValue];
                    [self.displayDelegate updatePlayerLabels];
                    [self updateCurrentRoleNumbersFromLastRoles];
                    
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
                [self.displayDelegate updateEligiblePlayers: nil withBypass: NO];
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
                    [self doClearenceAtNight: night withPlayer: p];
                }
                
                [self updateCurrentRoleNumbersFromLastRoles];
                
                [self recordNightStatus : night];
                
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
            if([self printFinalResultAtNight: night]) {
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
                
                [self.displayDelegate addPlayersStatusWithActorRole:Judge andReceiver:selectedPlayer andResult: [actor getActionResultAtNight:night forRole:roleInAction].boolValue];
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
            if([self printFinalResultAtNight: night]) {
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
            [self.displayDelegate restoreBackupActionIcon];
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
                roleInAction = Judge;
                [self rollbackPlayersStatus];
                [self calculateCurrentPlayers];
                [self.displayDelegate restoreBackupActionIcon];
                [self.displayDelegate updatePlayerLabels];
                [self.displayDelegate updatePlayerIcons];
                [self.displayDelegate showMessage: @"请投票"];
                oIndex = _orders.count;
                night--;
                [self.displayDelegate showNightMessage: night];
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
                
                NSLog(@"%ld - %@", night, [self getRoleLabel:roleInAction]);
                NSMutableDictionary* oldRoles = [NSMutableDictionary new];
                for(Player* p in _players) {
                    [oldRoles setObject: [NSNumber numberWithInt:p.role] forKey:p.id];
                }
                
                [self rollbackPlayersStatus];
                if(oIndex == _orders.count-1 && state >= 7) {
                    NSLog(@"%ld - %@", night, [self getRoleLabel:roleInAction]);
                    [self rollbackPlayersStatus];
                    [self calculateCurrentPlayers];
                    [self.displayDelegate resetPlayerIcons: currentPlayers];
                }
                [self updateCurrentRoleNumbersFromOldRoles: oldRoles];
                
                [self.displayDelegate updatePlayerLabels];
                if(playersInAction.count > 0) {
                    [self.displayDelegate removeActionIconFrom: [self getReceiverForActor: [playersInAction objectAtIndex:0] atNight: night]];
                }
                [self.displayDelegate showMessage: [NSString stringWithFormat:@"%@请%@", [self getRoleLabel: roleInAction], [self getRoleActionTerm: roleInAction]]];
                [self.displayDelegate updateEligiblePlayers: [self getEligiblePlayersAtNight:night wtihActors:playersInAction] withBypass: [self isBypassableActionAtNight:night withActors:playersInAction]];
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
    
    playersInAction = [self getPlayersByRole: roleInAction withIn: currentPlayers];
    if(playersInAction.count > 0) {
        Player* actor = (Player*)[playersInAction objectAtIndex:0];
        Player* receiver = [self getReceiverForActor:actor atNight:night];
        [self action: (receiver==nil ? @"" : receiver.id) inSpeed:YES];
    } else {
        [self action: @"" inSpeed:YES];
    }
    
    [self debugPlayers];
}

-(void) recordNightStatus : (long) i {
    [super recordNightStatus: i];
}

-(void) recordPlayersStatus {
    [super recordPlayersStatus];
    [playersInActionHistory addObject:playersInAction];
}

-(void) rollbackPlayersStatus {
    [super rollbackPlayersStatus];
    playersInAction = [playersInActionHistory lastObject];
    [playersInActionHistory removeLastObject];
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

-(void) initRoles: (NSDictionary*) roleNumbers {
    [super initRoles:roleNumbers];
    _currentRoleNumbers = [NSMutableDictionary dictionaryWithDictionary:_roleNumbers];
}

-(BOOL) didFinishedSettingPlayerForRole: (Role) r {
    return ([self getCurrentRoleNumber:r] == [self getPlayersByRole:r].count);
}

-(int) getCurrentRoleNumber: (Role) r {
    NSNumber* num = (NSNumber*)[_currentRoleNumbers objectForKey:[Engin getRoleName:r]];
    return (num && num.intValue > 0) ? num.intValue : 0;
}

-(void) updateCurrentRoleNumbersFromLastRoles {
    NSMutableDictionary* oldRoles = [NSMutableDictionary new];
    for(Player* p in _players) {
        [oldRoles setObject: p.roleStack.lastObject forKey:p.id];
    }
    [self updateCurrentRoleNumbersFromOldRoles: oldRoles];
}

-(void) updateCurrentRoleNumbersFromOldRoles: (NSDictionary*) oldRoles {
    for(Player* p in _players) {
        NSString* key0 = [Engin getRoleName: [[oldRoles objectForKey:p.id ] intValue]];
        NSString* key1 = [Engin getRoleName: p.role];
        if(key0 != key1) {
            [_currentRoleNumbers setObject: [NSNumber numberWithInt:[[_currentRoleNumbers objectForKey:key0] intValue]-1] forKey: key0];
            [_currentRoleNumbers setObject: [NSNumber numberWithInt:[[_currentRoleNumbers objectForKey:key1] intValue]+1] forKey: key1];
        }
    }
}

-(BOOL) isBypassableActionAtNight: (long) i withActors: (NSArray*) actors {
    return [self isEligibleActionAtNight: i withActors: actors andReceiver: [self getPlayerById:[Engin getRoleName:Game]]];
}

-(NSArray*) getEligiblePlayersAtNight: (long) i wtihActors: (NSArray*) actors {
    NSMutableArray* eligiblePlayers = [NSMutableArray new];
    for(Player* p in _players) {
        if(actors.count == 0 || [self isEligibleActionAtNight: i withActors: actors andReceiver: p]) {
            [eligiblePlayers addObject:p];
        }
    }
    return eligiblePlayers;
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


-(BOOL) printFinalResultAtNight: (long) i {
    int result = [self calculateFinalResultAtNight: i];
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
+(NSString*) getRoleLabel: (Role) r {
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
        case Citizen:
            return @"平民";
        case Assassin:
            return @"暗杀";
        case Undercover:
            return @"卧底";
        default:
            return [Engin getRoleName: r];
    }
}

-(NSString*) getRoleLabel: (Role) r {
    return [CCEngin getRoleLabel: r];
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
        case Assassin:
            return @"assassin";
        case Undercover:
            return @"undercover";
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


