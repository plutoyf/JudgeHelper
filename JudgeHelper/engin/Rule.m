//
//  Rule.m
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import "Rule.h"
#import "Engin.h"
#import "Expression.h"

@implementation Rule

-(NSString*) toString {
    NSMutableString* str = [NSMutableString stringWithString: @"Rule"];
    if (_name != nil && [_name length] > 0) {
        [str appendString: @"'"];
        [str appendString: _name];
        [str appendString: @"' "];
    }
    [str appendString: @"\n  Actor : "];
    [str appendString: [self toStringFromRole: _actor]];
    [str appendString: @"\n  Receiver : "];
    [str appendString: [self toStringFromRole: _receiver]];
    [str appendString: @"\n  Conditions : "];
    [str appendString: [self toStringFromExpressions: _conditions]];
    [str appendString: @"\n  Operations : "];
    [str appendString: [self toStringFromExpressions: _operations]];
    
    return str;
}

-(NSString*) toStringFromRole: (Role) r {
    return r == 0 ? @"null" : [Engin getRoleName: r];
}

-(NSString*) toStringFromExpressions: (NSArray*) expressions {
    NSMutableString* str = nil;
    if(expressions != nil) {
        for(Expression* e in expressions) {
            if (str == nil) {
                str = [NSMutableString stringWithString:@""];
            } else {
                [str appendString: @", "];
            }
            [str appendString: [e toString]];
        }
    }
    return str == nil ? @"" : str;
}

@end

