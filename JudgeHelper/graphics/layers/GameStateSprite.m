//
//  GameStateSprite.m
//  JudgeHelper
//
//  Created by fyang on 8/2/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "GameStateSprite.h"
#import "CCEngin.h"
#import "CCPlayer.h"

@implementation GameStateSprite

-(id) init {
    if(self = [super init]) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        self.contentSize = size;
        
        CCLayerColor *layerColer = [CCLayerColor layerWithColor:ccc4(0,100,100,255)];
        layerColer.position = ccp(0, 0);
        [self addChild:layerColer];
        
        _position = ccp(size.width/2*3-50, size.height/2);
    }
    
    return self;
}


-(void) updateState {
    [self removeAllChildren];
    
    CCEngin* engin = [CCEngin getEngin];
    CGSize size = self.boundingBox.size;
    int i = 1;
    for(CCPlayer* p in engin.players) {
        CCLabelTTF* label = [CCLabelTTF labelWithString:p.name fontName:@"Marker Felt" fontSize:14];
        label.position = ccp( 50 , size.height-50*i);
        [self addChild:label];
        int j = 0;
        for(NSArray* icons in p.actionIconsBackup) {
            [self updateIcons:icons atPosition:ccp(100+j*100, size.height-50*i)];
            j++;
        }
        [self updateIcons:p.actionIcons atPosition:ccp(100+j*100, size.height-50*i)];
        i++;
    }
}

-(void) updateIcons: (NSArray*) icons atPosition: (CGPoint) pos {
    for(CCSprite* icon in icons) {
        CCSprite* copy = [CCSprite spriteWithTexture:icon.texture];
        pos.x += copy.boundingBox.size.width;
        copy.position = pos;
        [self addChild:copy];
    }
}
@end
