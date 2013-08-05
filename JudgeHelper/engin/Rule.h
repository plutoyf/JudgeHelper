//
//  Rule.h
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Role.h"

@interface Rule : NSObject
{
    NSString* _name;
    Role _actor;
    Role _receiver;
    NSArray* _conditions;
    NSArray* _operations;
}

@property (nonatomic, strong) NSString* name;
@property (nonatomic) Role actor;
@property (nonatomic) Role receiver;
@property (nonatomic, strong) NSArray* conditions;
@property (nonatomic, strong) NSArray* operations;

-(NSString*) toString;

@end
