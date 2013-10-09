//
//  Expression.h
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Role.h"
#import "Property.h"

@interface Expression : NSObject
{
    Property _property;
    Role _role1;
    Role _role2;
    NSNumber* _i;
    NSString* _op;
    double _value;
}

@property (nonatomic) Property property;
@property (nonatomic) Role role1;
@property (nonatomic) Role role2;
@property (nonatomic) NSNumber* i;
@property (nonatomic, strong) NSString* op;
@property (atomic) double value;

-(NSString*) toString;

@end