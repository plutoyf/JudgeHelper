//
//  RuleResolver.h
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Condition.h"
#import "Operation.h"
#import "Rule.h"

@interface RuleResolver : NSObject
{
}

+(NSArray*) resolveRules: (NSString*) input;

+(NSMutableArray*) resolveRoles: (NSString*) input;

+(NSMutableDictionary*) resolveRoleNumbers: (NSString*) input;

+(NSArray*) resolveOrder: (NSString*) input;

+(void) resolveExpression: (Expression*) e withString: (NSString*) input withActor: (NSString*) actor andReceiver: (NSString*) receiver;

+(Condition*) resolveConditionWithString: (NSString*) input withActor: (NSString*) actor andReceiver: (NSString*) receiver;

+(Operation*) resolveOperationWithString: (NSString*) input withActor: (NSString*) actor andReceiver: (NSString*) receiver;

@end
