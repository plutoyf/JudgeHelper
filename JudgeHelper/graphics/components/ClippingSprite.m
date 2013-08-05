//
//  ClippingSprite.m
//  JudgeHelper
//
//  Created by YANG FAN on 03/08/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "ClippingSprite.h"

@implementation ClippingSprite


- (void) visit {
    if (!self.visible) {
        return;
    }
    glEnable(GL_SCISSOR_TEST);
    glScissor(_openWindowRect.origin.x, _openWindowRect.origin.y, _openWindowRect.size.width, _openWindowRect.size.height);
    [super visit];
    glDisable(GL_SCISSOR_TEST);
}

@end
