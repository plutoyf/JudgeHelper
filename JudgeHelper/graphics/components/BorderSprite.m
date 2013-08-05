//
//  BorderSprite.m
//  JudgeHelper
//
//  Created by YANG FAN on 04/08/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "BorderSprite.h"

@implementation BorderSprite

-(void) draw {
    [super draw];
    
    ccDrawColor4B(0, 0, 255, 255);
    glLineWidth(2);
    float x = _borderRect.origin.x;
    float y = _borderRect.origin.y;
    float w = _borderRect.size.width;
    float h = _borderRect.size.height;
    CGPoint vertices2[] = {
        ccp(x,y),
        ccp(x+w,y),
        ccp(x+w,y+h),
        ccp(x,y+h)
    };
    ccDrawPoly(vertices2, 4, YES);
}

@end
