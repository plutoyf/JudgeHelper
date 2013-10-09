//
//  Operation.h
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import "Condition.h"

@interface Operation : Condition
{
}

-(NSNumber*) execute: (Player*) p1 :(Player*) p2 :(NSArray*) players atNight: (long) night ;

@end