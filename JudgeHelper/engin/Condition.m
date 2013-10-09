//
//  Condition.m
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import "Condition.h"

@implementation Condition

-(double) getValue: (Player*) p1 with: (Player*) p2 atNight: (long) night {
    double v = 0;
    int i = _i != nil ? night+[_i intValue] : night;
    switch (_property) {
        case life:
            v = i == night ? p1.life : [p1 getLifeAtNight: i];
            break;
        case note:
            v = i == night ? p1.note : [p1 getNoteAtNight: i];
            break;
        case role:
            v = i == night ? p1.role : [p1 getRoleAtNight: i];
            break;
        case status:
            v = i == night ? p1.status : [p1 getStatusAtNight: i];
            break;
        case defaultDistance:
            v = i == night ? [p1 getDefaultDistanceWith: p2.id] : [p1 getDefaultDistanceAtNight:i with: p2.id];
            break;
        case distance:
            v = i == night ? [p1 getDistanceWith: p2.id] : [p1 getDistanceAtNight:i with: p2.id];
            break;
        default:
            break;
    }
    
    return v;
}

-(BOOL) compare: (Player*) p1 with: (Player*) p2 atNight: (long) night {
    double v = [self getValue:p1 with:p2 atNight:night];
    
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
