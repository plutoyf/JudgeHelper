//
//  Condition.h
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import "Expression.h"
#import "Player.h"

@interface Condition : Expression
{
}

-(BOOL) compare: (Player*) p1 with: (Player*) p2 atNight: (long) night ;
-(double) getValue: (Player*) p1 with: (Player*) p2 atNight: (long) night ;

@end
