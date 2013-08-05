//
//  Operation.m
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import "Operation.h"

@implementation Operation

-(NSNumber*) execute: (Player*) p1 :(Player*) p2 :(NSArray*) players {
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
            v = p2 != nil ? [p1 getDistanceWith: p2.name] : 0;
            break;
        default:
            break;
    }
    
    if ([_op isEqualToString:@"="]) {
        v=_value;
    } else if ([_op isEqualToString:@"+="]) {
        v+=_value;
    } else if ([_op isEqualToString:@"-="]) {
        v-=_value;
    } else if ([_op isEqualToString:@"*="]) {
        v*=_value;
    } else if ([_op isEqualToString:@"/="]) {
        v/=_value;
    } else {
        return [NSNumber numberWithBool: [super compare: p1 with: p2]];
    }
    
    switch (_property) {
        case life:
            p1.life = v;
            break;
        case note:
            p1.note = v;
            break;
        case status:
            p1.status = v;
            break;
        case distance:
            if (p2 != nil) {
                [p1 setDistance: v withPlayer: p2.name];
                [p2 setDistance: v withPlayer: p1.name];
            } else {
                for (Player* p in players) {
                    [p1 setDistance: v withPlayer: p.name];
                    [p setDistance: v withPlayer: p1.name];
                }
            }
            break;
        default:
            break;
    }
    
    return nil;
}

@end