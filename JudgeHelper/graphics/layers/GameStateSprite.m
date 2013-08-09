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
        [self addChild:layerColer z:-1];        
        
        _position = ccp(size.width/2, size.height/2*3-10);
        
        //init
        CCEngin* engin = [CCEngin getEngin];
        pIds = [NSMutableArray new];
        actionReceiverMap = [NSMutableDictionary new];
        actionIconMap = [NSMutableDictionary new];
        int i = 0;
        for(CCPlayer* p in engin.players) {
            if(p.role == Judge) continue;
            [pIds addObject:p.id];
            CCLabelTTF* label = [CCLabelTTF labelWithString:p.name fontName:@"Marker Felt" fontSize:14];
            label.position = ccp(50, 80+40*i++);
            [self addChild:label];
        }
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
    icon.position = ccp(100+20*icon.tag, 80+40*line);
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
    
    // print live color grid
    [self paintLifeLine: engin.players];
    
    // print action icon
    for(CCPlayer* p in engin.players) {
        NSArray* orders = engin.orders;
        Role currentRole = [engin getCurrentRole];
        if(!currentRole || [orders indexOfObject:[Engin getRoleName:p.role]] <= [orders indexOfObject: [Engin getRoleName:currentRole]]) {
        
            NSString* receiverId = [p.actionReceivers objectForKey: [NSNumber numberWithInt:night]];
            NSNumber* result = [p.actionResults objectForKey: [NSNumber numberWithInt:night]];
            
            if(receiverId && ![self hasAddedActionReceiverForRole:p.role atNight:night]) {
                MySprite* icon = [MySprite spriteWithFile: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:p.role]]];
                icon.role = p.role;
                icon.tag = p.lifeStack.count;
                if(!result.boolValue) icon.opacity = 80;
                [self addActionIcon:icon forPlayer:receiverId atNight:night];
                [((NSMutableDictionary*)[actionReceiverMap objectForKey:[NSNumber numberWithInt:p.role]]) setObject:receiverId forKey:[NSNumber numberWithInt:night]];
            }
        }
    }
}

-(void) revertStatus {
    CCEngin* engin = [CCEngin getEngin];
    [self paintLifeLine: engin.players];
    
    int i = ((CCPlayer*)[engin.players objectAtIndex:0]).lifeStack.count+1;
    int night = [engin getCurrentNight];
    for(CCPlayer* p in engin.players) {
        NSMutableDictionary* playersActionIcons = [actionIconMap objectForKey:p.id];
        NSMutableArray* icons = [playersActionIcons objectForKey:[NSNumber numberWithInt:night]];
        for(MySprite* icon in icons) {
            if(icon.tag == i) {
                [((NSMutableDictionary*)[actionReceiverMap objectForKey:[NSNumber numberWithInt:icon.role]]) removeObjectForKey:[NSNumber numberWithInt:night]];
                [icons removeObject:icon];
                [self removeChild:icon];
            }
        }
    }
}

-(void) paintLifeLine: (NSArray*) players {
    
    [self removeChildByTag: 9];
    
    for(CCPlayer* p in players) {
        if(p.role == Judge) continue;
        
        int i0 = 0;
        double v0 = 0;
        Status s0 = 0;
        int i = 0;
        ccColor4B color = ccc4(0, 255, 0, 255);
        int line = [self getPlayerLineNumber:p.id];
        
        for(NSNumber* v in p.lifeStack) {
            if(i==0) {
                i0 = i;
                v0 = v.floatValue;
                s0 = ((NSNumber*)[p.statusStack objectAtIndex:0]).intValue;
            } else {
                if(v0 != v.floatValue || s0 != ((NSNumber*)[p.statusStack objectAtIndex:i]).intValue) {
                    // draw color box
                    CCLayerColor *layerColer = [CCLayerColor layerWithColor:color];
                    layerColer.contentSize = CGSizeMake((i-i0)*20, 2);
                    layerColer.position = ccp(100+i0*20+10, 80+40*line-12);
                    [self addChild:layerColer z:-1];
                    
                    // move forward
                    i0 = i;
                    v0 = v.floatValue;
                    s0 = ((NSNumber*)[p.statusStack objectAtIndex:i]).intValue;
                    color = (s0 == OUT_GAME) ? ccc4(0, 0, 0, 255) :  (v0>=1) ? ccc4(0, 255, 0, 255) : (v0<=0) ? ccc4(255, 0, 0, 255) : ccc4(100, 100, 0, 255);
                }
            }
            i++;
        }
        
        CCLayerColor *layerColer = [CCLayerColor layerWithColor:color];
        layerColer.contentSize = CGSizeMake((50-i0)*20, 2);
        layerColer.position = ccp(100+i0*20+10, 80+40*line-12);
        [self addChild:layerColer z:-1];
        
        if(p.status == OUT_GAME) {
            CCLayerColor *layerColer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
            layerColer.tag = 9;
            layerColer.contentSize = CGSizeMake(40, 1);
            layerColer.position = ccp(30, 80+40*line);
            [self addChild:layerColer];
        }
    }
    
}

@end
