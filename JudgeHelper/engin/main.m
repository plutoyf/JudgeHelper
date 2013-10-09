//
//  main.m
//  JudgeHelper
//
//  Created by fyang on 7/18/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConsoleEngin.h"
#import "RuleResolver.h"

int main0(int argc, const char * argv[])
{

    @autoreleasepool {        
        NSString* eligibilityRulesString = @"";
        
        NSString* actionRulesString = @"";
        actionRulesString = [actionRulesString stringByAppendingString: @"Rule ( Guard+  ) :  Guard,  Anybody  -[ distance(Guard,  Anybody) == 1                      ]>  distance(Anybody) =  1.1 ; distance(Guard, Anybody) = 0.1 ; "];
        actionRulesString = [actionRulesString stringByAppendingString: @"Rule ( Killer  ) :  Killer, Anybody  -[ distance(Killer, Anybody) <= 1                      ]>  life(Anybody)     -= 1                                      "];
        actionRulesString = [actionRulesString stringByAppendingString: @"Rule ( Doctor+ ) :  Doctor, Anybody  -[ distance(Doctor, Anybody) <= 1 ; life(Anybody) <= 0 ]>  life(Anybody)     += 1                                      "];
        actionRulesString = [actionRulesString stringByAppendingString: @"Rule ( Doctor- ) :  Doctor, Anybody  -[ distance(Doctor, Anybody) <= 1 ; life(Anybody) >  0 ]>  life(Anybody)     -= 0.5                                    "];
        actionRulesString = [actionRulesString stringByAppendingString: @"Rule ( Judge   ) :  Judge,  Anybody  -[ distance(Judge,  Anybody) <= 1                      ]>  life(Anybody)     =  0                                      "];
        actionRulesString = [actionRulesString stringByAppendingString: @"Rule ( Police  ) :  Police, Anybody  -[                                                     ]>  role(Anybody)     == 3                                      "];
        actionRulesString = [actionRulesString stringByAppendingString: @"Rule ( Spy     ) :  Spy,    Anybody  -[                                                     ]>  role(Anybody)     == 3                                      "];
        
        NSString* clearenceRulesString = @"";
        clearenceRulesString = [actionRulesString stringByAppendingString: @"Rule ( Guard-  ) :  Guard            -[ distance(Guard, Receiver) <  1 ; life(Guard) <= 0   ]>  life(Result)      =  0                                      "];
        
        NSString* ordersString = @"Guard, Killer, Police, Doctor, Spy";
        
        NSString* resultRulesString = @"";
        resultRulesString = [resultRulesString stringByAppendingString: @"Rule ( Police1 ) :  Game  -[ life(Killer) <=0 ]>  note(Game) += 2 "];
        resultRulesString = [resultRulesString stringByAppendingString: @"Rule ( Killer1 ) :  Game  -[ life(Police) <=0 ]>  note(Game) -= 1 "];
        resultRulesString = [resultRulesString stringByAppendingString: @"Rule ( Killer2 ) :  Game  -[ life(Guard)  <=0 ; life(Doctor) <=0 ; life(Spy) <=0 ; life(Citizen) <=0 ]>  note(Game) -= 1 "];
        resultRulesString = [resultRulesString stringByAppendingString: @"Rule ( Equals  ) :  Game  -[ life(Police) <=0 ; life(Killer) <=0 ]>  note(Game) += 999 "];
        
        NSArray* orders = [RuleResolver resolveOrder: ordersString];
        NSArray* eligibilityRules = [RuleResolver resolveRules: eligibilityRulesString];
        NSArray* actionRules = [RuleResolver resolveRules: actionRulesString];
        NSArray* clearenceRules = [RuleResolver resolveRules: clearenceRulesString];
        NSArray* resultRules = [RuleResolver resolveRules: resultRulesString];
        
        NSLog(@"\n====== Role Orders ======\n");
        for (NSString* o in orders) {
            NSLog(@"%@", o);
        }
        
        NSLog(@"\n====== Eligibility Rules ======\n");
        for (Rule* r in eligibilityRules) {
            NSLog(@"%@", [r toString]);
        }
        
        NSLog(@"\n====== Action Rules ======\n");
        for (Rule* r in actionRules) {
            NSLog(@"%@", [r toString]);
        }
        
        NSLog(@"\n====== Clearence Rules ======\n");
        for (Rule* r in clearenceRules) {
            NSLog(@"%@", [r toString]);
        }
        
        NSLog(@"\n====== Result Rules ======\n");
        for (Rule* r in resultRules) {
            NSLog(@"%@", [r toString]);
        }
        
        NSMutableArray* players = [NSMutableArray new];
        Player* guard = [[Player alloc] init: @"guard" andName: @"花蝴蝶" withRole: Guard];
        Player* killer1 = [[Player alloc] init: @"killer1" andName: @"杀手1" withRole: Killer];
        Player* killer2 = [[Player alloc] init: @"killer2" andName: @"杀手2" withRole: Killer];
        Player* police1 = [[Player alloc] init: @"police1" andName: @"警察1" withRole: Police];
        Player* police2 = [[Player alloc] init: @"police2" andName: @"警察2" withRole: Police];
        Player* doctor = [[Player alloc] init: @"doctor" andName: @"医生" withRole: Doctor];
        Player* spy = [[Player alloc] init: @"spy" andName: @"老婆" withRole: Spy];
        Player* citizen1 = [[Player alloc] init: @"citizen1" andName: @"平民1" withRole: Citizen];
        Player* citizen2 = [[Player alloc] init: @"citizen2" andName: @"平民2" withRole: Citizen];
        Player* citizen3 = [[Player alloc] init: @"citizen3" andName: @"平民3" withRole: Citizen];
        Player* judge = [[Player alloc] init: @"judge" andName: @"法官" withRole: Judge];
        [players addObject: guard];
        [players addObject: killer1];
        [players addObject: killer2];
        [players addObject: police1];
        [players addObject: police2];
        [players addObject: doctor];
        [players addObject: spy];
        [players addObject: citizen1];
        [players addObject: citizen2];
        [players addObject: citizen3];
        [players addObject: judge];
        
        Engin* engin = [[ConsoleEngin new] initWithRules:eligibilityRules :actionRules :clearenceRules :resultRules andRoles:nil andOrders:orders];
        [engin setPlayers: players];
        
        [engin run];
        
    }
    return 0;
}

