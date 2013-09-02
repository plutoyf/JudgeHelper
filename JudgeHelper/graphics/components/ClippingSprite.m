//
//  ClippingSprite.m
//  JudgeHelper
//
//  Created by YANG FAN on 03/08/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "ClippingSprite.h"

@implementation ClippingSprite

-(void) clip {
    CGSize size = [[CCDirector sharedDirector] winSize];
        
    CCLayerColor *layerColerUp = [CCLayerColor layerWithColor:ccc4(0,0,0,255)];
    layerColerUp.contentSize = CGSizeMake(size.width, size.height-_openWindowRect.origin.y-_openWindowRect.size.height);
    layerColerUp.position = ccp(0, _openWindowRect.origin.y+_openWindowRect.size.height);
    [self addChild:layerColerUp z:1];
    
    CCLayerColor *layerColerBottom = [CCLayerColor layerWithColor:ccc4(0,0,0,255)];
    layerColerBottom.contentSize = CGSizeMake(size.width, _openWindowRect.origin.y);
    layerColerBottom.position = ccp(0, 0);
    [self addChild:layerColerBottom z:1];
    
    CCLayerColor *layerColerleft = [CCLayerColor layerWithColor:ccc4(0,0,0,255)];
    layerColerleft.contentSize = CGSizeMake(_openWindowRect.origin.x, size.height);
    layerColerleft.position = ccp(0, 0);
    [self addChild:layerColerleft z:1];
    
    CCLayerColor *layerColerRight = [CCLayerColor layerWithColor:ccc4(0,0,0,255)];
    layerColerRight.contentSize = CGSizeMake(size.width-_openWindowRect.origin.x-_openWindowRect.size.width, size.height);
    layerColerRight.position = ccp(_openWindowRect.origin.x+_openWindowRect.size.width, 0);
    [self addChild:layerColerRight z:1];
    
    CCLayerColor *layerColerBody = [CCLayerColor layerWithColor:ccc4(255,255,255,255)];
    layerColerBody.contentSize = CGSizeMake(_openWindowRect.size.width, _openWindowRect.size.height);
    layerColerBody.position = ccp(_openWindowRect.origin.x, _openWindowRect.origin.y);
    [self addChild:layerColerBody z:-1];

}

/*
- (void) visit {
    if (!self.visible) {
        return;
    }
    glEnable(GL_SCISSOR_TEST);
    glScissor(_openWindowRect.origin.x, _openWindowRect.origin.y, _openWindowRect.size.width, _openWindowRect.size.height);
    [super visit];
    glDisable(GL_SCISSOR_TEST);
}
*/

@end
