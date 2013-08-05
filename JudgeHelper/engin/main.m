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
        NSString* rulesString = @"";
        rulesString = [rulesString stringByAppendingString: @"Rule ( Guard+  ) :  Guard,  Anybody  -[ distance(Guard,  Anybody) == 1                      ]>  distance(Anybody) =  1.1 ; distance(Guard, Anybody) = 0.1 ; "];   
        rulesString = [rulesString stringByAppendingString: @"Rule ( Guard-  ) :  Guard            -[ distance(Guard, Receiver) <  1 ; life(Guard) <= 0   ]>  life(Result)      =  0                                      "];
        rulesString = [rulesString stringByAppendingString: @"Rule ( Killer  ) :  Killer, Anybody  -[ distance(Killer, Anybody) <= 1                      ]>  life(Anybody)     -= 1                                      "];
        rulesString = [rulesString stringByAppendingString: @"Rule ( Doctor+ ) :  Doctor, Anybody  -[ distance(Doctor, Anybody) <= 1 ; life(Anybody) <= 0 ]>  life(Anybody)     += 1                                      "];
        rulesString = [rulesString stringByAppendingString: @"Rule ( Doctor- ) :  Doctor, Anybody  -[ distance(Doctor, Anybody) <= 1 ; life(Anybody) >  0 ]>  life(Anybody)     -= 0.5                                    "];
        rulesString = [rulesString stringByAppendingString: @"Rule ( Judge   ) :  Judge,  Anybody  -[ distance(Judge,  Anybody) <= 1                      ]>  life(Anybody)     =  0                                      "];
        rulesString = [rulesString stringByAppendingString: @"Rule ( Police  ) :  Police, Anybody  -[                                                     ]>  role(Anybody)     == 3                                      "];
        rulesString = [rulesString stringByAppendingString: @"Rule ( Spy     ) :  Spy,    Anybody  -[                                                     ]>  role(Anybody)     == 3                                      "];
        
        NSString* ordersString = @"Guard, Killer, Police, Doctor, Spy";
        
        NSString* resultRulesString = @"";
        resultRulesString = [resultRulesString stringByAppendingString: @"Rule ( Police1 ) :  Game  -[ life(Killer) <=0 ]>  note(Game) += 2 "];
        resultRulesString = [resultRulesString stringByAppendingString: @"Rule ( Killer1 ) :  Game  -[ life(Police) <=0 ]>  note(Game) -= 1 "];
        resultRulesString = [resultRulesString stringByAppendingString: @"Rule ( Killer2 ) :  Game  -[ life(Guard)  <=0 ; life(Doctor) <=0 ; life(Spy) <=0 ; life(Citizen) <=0 ]>  note(Game) -= 1 "];
        resultRulesString = [resultRulesString stringByAppendingString: @"Rule ( Equals  ) :  Game  -[ life(Police) <=0 ; life(Killer) <=0 ]>  note(Game) += 999 "];
        
        NSArray* orders = [RuleResolver resolveOrder: ordersString];
        NSArray* rules = [RuleResolver resolveRules: rulesString];
        NSArray* resultRules = [RuleResolver resolveRules: resultRulesString];
        
        NSLog(@"\n====== Game Orders ======\n");
        for (NSString* o in orders) {
            NSLog(@"%@", o);
        }
        
        NSLog(@"\n====== Game Rules ======\n");
        for (Rule* r in rules) {
            NSLog(@"%@", [r toString]);
        }
        
        NSLog(@"\n====== Result Rules ======\n");
        for (Rule* r in resultRules) {
            NSLog(@"%@", [r toString]);
        }
        
        NSMutableArray* players = [NSMutableArray new];
        Player* guard = [[Player alloc] init: @"花蝴蝶" withRole: Guard];
        Player* killer1 = [[Player alloc] init: @"杀手1" withRole: Killer];
        Player* killer2 = [[Player alloc] init: @"杀手2" withRole: Killer];
        Player* police1 = [[Player alloc] init: @"警察1" withRole: Police];
        Player* police2 = [[Player alloc] init: @"警察2" withRole: Police];
        Player* doctor = [[Player alloc] init: @"医生" withRole: Doctor];
        Player* spy = [[Player alloc] init: @"老婆" withRole: Spy];
        Player* citizen1 = [[Player alloc] init: @"平民1" withRole: Citizen];
        Player* citizen2 = [[Player alloc] init: @"平民2" withRole: Citizen];
        Player* citizen3 = [[Player alloc] init: @"平民3" withRole: Citizen];
        Player* judge = [[Player alloc] init: @"法官" withRole: Judge];
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
        
        Engin* engin = [[ConsoleEngin new] initWithRules:rules andResultRules:resultRules andRoles:nil andOrders:orders];
        [engin setPlayers: players];
        
        [engin run];
        
    }
    return 0;
}

