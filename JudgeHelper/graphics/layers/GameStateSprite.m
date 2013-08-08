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

-(BOOL) hasAddedActionReceiverForRole: (Role) r atNight: (int) i {
    NSNumber* key = [NSNumber numberWithInt:r];
    if(![actionReceiverMap objectForKey:key]) [actionReceiverMap setObject:[NSMutableDictionary new] forKey:key];
    NSMutableDictionary* addedActionReceivers = [actionReceiverMap objectForKey:key];
    return [addedActionReceivers objectForKey:[NSNumber numberWithInt:i]] != nil;
}

-(void) addActionIcon:(CCSprite*) icon forPlayer: (NSString*) id atNight: (int) i {
    int line = [self getPlayerLineNumber:id];
    if(![actionIconMap objectForKey:id]) [actionIconMap setObject:[NSMutableDictionary new] forKey:id];
    NSMutableDictionary* playersActionIcons = [actionIconMap objectForKey:id];
    NSNumber* key = [NSNumber numberWithInt:i];
    if(![playersActionIcons objectForKey:key]) [playersActionIcons setObject:[NSMutableArray new] forKey:key];
    NSMutableArray* icons = [playersActionIcons objectForKey:key];
    icon.position = ccp(100+100*(i-1)+20*icons.count, 200+50*line);
    [icons addObject:icon];
    [self addChild:icon];
}

-(int) getPlayerLineNumber: (NSString*) id {
    return [pIds indexOfObject:id];
}

NSMutableDictionary* actionReceiverMap;
NSMutableDictionary* actionIconMap;
NSMutableArray* pIds;
-(void) addNewStatus {
    CCEngin* engin = [CCEngin getEngin];
    int night = [engin getCurrentNight];
    
    if(!pIds) {
        //init
        pIds = [NSMutableArray new];
        actionReceiverMap = [NSMutableDictionary new];
        actionIconMap = [NSMutableDictionary new];
        int i = 0;
        for(CCPlayer* p in engin.players) {
            [pIds addObject:p.id];
            CCLabelTTF* label = [CCLabelTTF labelWithString:p.name fontName:@"Marker Felt" fontSize:14];
            label.position = ccp( 50 , 200+50*i++);
            [self addChild:label];
        }
    }
    
    for(CCPlayer* p in engin.players) {
        NSString* receiverId = [p.actionReceivers objectForKey: [NSNumber numberWithInt:night]];
        if(receiverId && ![self hasAddedActionReceiverForRole:p.role atNight:night]) {
            CCSprite* icon = [CCSprite spriteWithFile: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:p.role]]];
            [self addActionIcon:icon forPlayer:receiverId atNight:night];
            NSNumber* key = [NSNumber numberWithInt:p.role];
            [((NSMutableDictionary*)[actionReceiverMap objectForKey:key]) setObject:receiverId forKey:[NSNumber numberWithInt:night]];
        }
    }
}

-(void) revertStatus {
    CCEngin* engin = [CCEngin getEngin];
    for(CCPlayer* p in engin.players) {
        
    }
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
            [self updateIcons:icons atPosition:ccp(50+j*100, size.height-50*i)];
            j++;
        }
        [self updateIcons:p.actionIcons atPosition:ccp(50+j*100, size.height-50*i)];
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
