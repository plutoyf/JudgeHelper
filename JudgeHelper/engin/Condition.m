//
//  Condition.m
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import "Condition.h"

@implementation Condition

-(BOOL) compare: (Player*) p1 with: (Player*) p2 {
    double v = 0;
    switch (_property) {
        case life:
            v = p1.life;
            break;
        case note:
            v = p1.note;
            break;
        case role:
            v = p1.role;
            break;
        case status:
            v = p1.status;
            break;
        case distance:
            v = [p1 getDistanceWith: p2.name];
            break;
        default:
            break;
    }
    
    if ([_op isEqualToString:@"=="]) {
        return v==_value;
    } else if ([_op isEqualToString:@"!="]) {
        return v!=_value;
    } else if ([_op isEqualToString:@"<"]) {
        return v<_value;
    } else if ([_op isEqualToString:@"<="]) {
        return v<=_value;
    } else if ([_op isEqualToString:@">"]) {
        return v>_value;
    } else if ([_op isEqualToString:@">="]) {
        return v>=_value;
    }
    
    return NO;
}

@end
