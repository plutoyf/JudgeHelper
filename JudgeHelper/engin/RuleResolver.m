//
//  RuleResolver.m
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import "RuleResolver.h"
#import "Engin.h"

@implementation RuleResolver

+(NSArray*) resolveRules: (NSString*) input
{
    
    NSMutableArray* rules = [NSMutableArray array];
    input = [input stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSArray* rs = [input componentsSeparatedByString:@"Rule("];
    for (int i = 0; i<[rs count]; i++) {
        NSString* r = [[rs objectAtIndex: i] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
        if([r length] == 0) {
            continue;
        }
        
        long i0 = [r rangeOfString: @"):"].location;
        long i1 = [r rangeOfString: @"-["].location;
        long i2 = [r rangeOfString: @"]>"].location;
        
        NSString* part0 = [r substringToIndex: i0];
        NSString* part1 = [r substringWithRange: NSMakeRange(i0+2, i1-i0-2)];
        NSString* part2 = [r substringWithRange: NSMakeRange(i1+2, i2-i1-2)];
        NSString* part3 = [r substringFromIndex: i2+2];
        
        Rule *rule = [Rule new];
        rule.name = part0;
        long j = [part1 rangeOfString: @","].location;
        NSString *actor, *receiver;
        if(j != NSNotFound) {
            actor = [part1 substringToIndex: j];
            receiver = [part1 substringFromIndex: j+1];
        } else {
            actor = part1;
            receiver = [Engin getRoleName: Receiver];
        }
        rule.actor = [Engin getRoleFromString: actor];
        rule.receiver = [Engin getRoleFromString: receiver];
        
        NSMutableArray* conditions = [NSMutableArray array];
        if ([part2 length] > 0) {
            NSArray* cons = [part2 componentsSeparatedByString:@";"];
            for(j=0; j<[cons count]; j++) {
                if([[cons objectAtIndex: j] length] > 0) {
                    [conditions addObject: [RuleResolver resolveConditionWithString: [cons objectAtIndex: j] withActor: actor andReceiver: receiver]];
                }
            }
        }
        rule.conditions = conditions;
        
        NSMutableArray* operations = [NSMutableArray array];
        if ([part3 length] > 0) {
            NSArray* ops = [part3 componentsSeparatedByString:@";"];
            for(j=0; j<[ops count]; j++) {
                if([[ops objectAtIndex: j] length] > 0) {
                    [operations addObject: [RuleResolver resolveOperationWithString: [ops objectAtIndex: j] withActor: actor andReceiver: receiver]];
                }
            }
        }
        rule.operations = operations;
        
        [rules addObject: rule];
    }
    
    return rules;
}

+(NSMutableArray*) resolveRoles: (NSString*) input
{
    NSMutableArray* roles = [NSMutableArray array];
    input = [input stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSArray* rs = [input componentsSeparatedByString:@","];
    for(int i = 0; i<[rs count]; i++) {
        if([[rs objectAtIndex: i] length] > 0) {
            NSString* r = [rs objectAtIndex: i];
            [roles addObject: [r substringToIndex: [r rangeOfString:@"("].location]];
        }
    }
    
    return roles;
}

+(NSMutableDictionary*) resolveRoleNumbers: (NSString*) input
{
    NSMutableDictionary* roleNumbers = [NSMutableDictionary dictionary];
    input = [input stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSArray* rs = [input componentsSeparatedByString:@","];
    for(int i = 0; i<[rs count]; i++) {
        if([[rs objectAtIndex: i] length] > 0) {
            NSString* r = [rs objectAtIndex: i];
            long i0 = [r rangeOfString:@"("].location;
            long i1 = [r rangeOfString:@")"].location;
            NSString* key = [r substringToIndex: i0];
            NSNumber* value = [NSNumber numberWithInt: [r substringWithRange: NSMakeRange(i0+1, i1-i0-1)].intValue];

            [roleNumbers setObject:value forKey:key];
        }
    }
    
    return roleNumbers;
}

+(NSArray*) resolveOrder: (NSString*) input
{
    NSMutableArray* order = [NSMutableArray array];
    input = [input stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSArray* rs = [input componentsSeparatedByString:@","];
    for(int i = 0; i<[rs count]; i++) {
        if([[rs objectAtIndex: i] length] > 0) {
            [order addObject: [rs objectAtIndex: i]];
        }
    }
    
    return order;
}

+(void) resolveExpression: (Expression*) e withString: (NSString*) input withActor: (NSString*) actor andReceiver: (NSString*) receiver
{
    // = += -= *= /=
    // == != < > <= >=
    long l = 1;
    long i0 = [input rangeOfString:@"("].location;
    long i1 = [input rangeOfString:@")"].location;
    long i2 = [input rangeOfString:@"=" options: NSBackwardsSearch].location;
    if(i2 != NSNotFound && [input characterAtIndex: i2-1] != ')') {
        l = 2;
        i2--;
    } else if(i2 == NSNotFound) {
        i2 = [input rangeOfString: @"<"].location != NSNotFound ? [input rangeOfString: @"<"].location : [input rangeOfString: @">"].location;
    }
    NSString* part1 = [input substringToIndex: i0];
    NSString* part2 = [input substringWithRange: NSMakeRange(i0+1, i1-i0-1)];
    NSString* part3 = [input substringWithRange: NSMakeRange(i1+1, i2+l-i1-1)];
    NSString* part4 = [input substringFromIndex: i2+l];
    
    e.property = [Engin getPropertyFromString: part1];
    Role role1 = 0, role2 = 0;
    NSNumber* i = nil;
    NSArray* params = [part2 componentsSeparatedByString:@","];
    if(params.count >= 1) {
        role1 = [Engin getRoleFromString: [params objectAtIndex: 0]];
    }
    if(params.count >= 2) {
        role2 = [Engin getRoleFromString: [params objectAtIndex: 1]];
    }
    if(params.count >= 3) {
        i = [NSNumber numberWithInteger: [[params objectAtIndex: 2] integerValue]];
    }
    
    e.role1 = role1;
    e.role2 = role2;
    e.i = i;
    e.op = part3;
    
    double value = [Engin getRoleFromString : part4];
    if(value == 0) {
        value = [Engin getStatusFromString : part4];
    }
    if(value == 0) {
        value = [part4 doubleValue];
    }
    
    e.value = value;
}

+(Condition*) resolveConditionWithString: (NSString*) input withActor: (NSString*) actor andReceiver: (NSString*) receiver {
    
    Condition *c = nil;
    if([input length] > 0) {
        c = [Condition new];
        [RuleResolver resolveExpression: c withString: input withActor: actor andReceiver: receiver];
    }
    return c;
}

+(Operation*) resolveOperationWithString: (NSString*) input withActor: (NSString*) actor andReceiver: (NSString*) receiver
{
    Operation *o = nil;
    if([input length] > 0) {
        o = [Operation new];
        [RuleResolver resolveExpression: o withString: input withActor: actor andReceiver: receiver];
    }
    return o;
}

@end



