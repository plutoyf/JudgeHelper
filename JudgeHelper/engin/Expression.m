//
//  Expression.m
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import "Expression.h"
#import "Engin.h"

@implementation Expression

-(NSString *) toString {
    NSMutableString* str = [NSMutableString stringWithString: @"[ "];
    [str appendString: [Engin getPropertyName: _property]];
    [str appendString: @"("];
    [str appendString: [Engin getRoleName: _role1]];
    if (_role2 != 0) {
        [str appendString: @", "];
        [str appendString: [Engin getRoleName: _role2]];
    }
    if (_i != nil) {
        [str appendString: @", "];
        [str appendString: [_i stringValue]];
    }
    [str appendString: @") "];
    [str appendString: _op];
    [str appendString: @" "];
    [str appendString: [NSString stringWithFormat: @"%f", _value]];
    [str appendString: @" ]"];
    
    return str;
}

@end