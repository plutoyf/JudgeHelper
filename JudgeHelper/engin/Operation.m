//
//  Operation.m
//  JudgeHelper
//
//  Created by fyang on 7/19/13.
//  Copyright (c) 2013 com.learncocos2d. All rights reserved.
//

#import "Operation.h"

@implementation Operation

-(NSNumber*) execute: (Player*) p1 :(Player*) p2 :(NSArray*) players atNight: (long) night {
    double v = [self getValue:p1 with:p2 atNight:night];
    
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
        return [NSNumber numberWithBool: [super compare: p1 with: p2 atNight:night]];
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
        case defaultDistance:
            if (p2 != nil) {
                [p1 setDefaultDistance: v withPlayer: p2.id];
                [p2 setDefaultDistance: v withPlayer: p1.id];
            } else {
                for (Player* p in players) {
                    [p1 setDefaultDistance: v withPlayer: p.id];
                    [p setDefaultDistance: v withPlayer: p1.id];
                }
            }
            break;
        case distance:
            if (p2 != nil) {
                [p1 setDistance: v withPlayer: p2.id];
                [p2 setDistance: v withPlayer: p1.id];
            } else {
                for (Player* p in players) {
                    [p1 setDistance: v withPlayer: p.id];
                    [p setDistance: v withPlayer: p1.id];
                }
            }
            break;
        default:
            break;
    }
    
    return nil;
}

@end