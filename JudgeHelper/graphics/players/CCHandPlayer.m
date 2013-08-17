//
//  CCHandPlayer.m
//  JudgeHelper
//
//  Created by fyang on 8/1/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "CCHandPlayer.h"
#import "CCEngin.h"
#import "Constants.h"
#import "CCNode+SFGestureRecognizers.h"

@implementation CCHandPlayer

-(id) init: (NSString*) id withRole: (Role) role {
    if(self = [super init: id withRole: role withAvatar: NO]) {
    }
    return self;
}

-(id) init: (NSString*) id andName:(NSString *)name withRole: (Role) role {
    if(self = [super init: id andName:name withRole: role withAvatar: NO]) {
    }
    return self;
}

-(void) showRoleInfo {
    if(!expanded) {
        if(_role > 0) {
            NSString* handIconFile = _hand==LEFTHAND ? @"lefthand.png" : @"righthand.png";
            CGPoint roleIconPosition = _hand==LEFTHAND ? ccp(18, 14) : ccp(22, 14);
            
            handIcon = [CCSprite spriteWithFile: handIconFile];
            if(_role != Citizen) {
                CCSprite* roleIcon = [CCSprite spriteWithFile: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:_role]]];
                roleIcon.position = roleIconPosition;
                roleIcon.opacity = _status == OUT_GAME ? 80 : 999;
                [handIcon addChild:roleIcon];
            }
            
            handIcon.isTouchEnabled = YES;
            UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPlayer:)];
            [handIcon addGestureRecognizer:tapGestureRecognizer];
            
            handIcon.position = [self getHandIconPosition];
            handIcon.opacity = _status == OUT_GAME ? 80 : 999;
            [self addChild:handIcon];
        }
        expanded = YES;
        
        [_player showRoleInfo];
    }
    
}

-(void) hideRoleInfo {
    if(expanded) {
        [self removeChild:handIcon];
        expanded = NO;
        
        [_player hideRoleInfo];
    }
    
}

-(void) updatePlayerIcon {
    handIcon.opacity = _status == OUT_GAME ? 80 : 999;
    [_player updatePlayerIcon];
}

-(void) updateHandIcon {
    NSString* handIconFile = _hand==LEFTHAND ? @"lefthand.png" : @"righthand.png";
    if(_realPositionModeEnable && _position == TOP) {
        handIconFile = _hand==LEFTHAND ?@"righthand.png" :  @"lefthand.png";
    }
    CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:handIconFile];
    [handIcon setTexture:tex];
    
    handIcon.position = [self getHandIconPosition];
}

-(void) addActionIcon: (Role) role withResult:(BOOL)result {
    CCSprite* icon = [CCSprite spriteWithFile: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:role]]];
    icon.opacity = result ? 255 : 80;
    icon.position = [self getActionIconPosition: _actionIcons.count];
    [_actionIcons addObject:icon];
    [self addChild:icon];
}

-(CGPoint) getHandIconPosition {
    float x, y;
    if(!_realPositionModeEnable) {
        x = _hand==LEFTHAND ? -10 : AVATAR_IMG_WIDTH+10;
        y = AVATAR_IMG_HEIGHT+20;
    } else if(_position==BOTTEM || _position==TOP) {
        x = (_hand==LEFTHAND && _position==BOTTEM) || (_hand==RIGHTHAND && _position==TOP) ? -10 : AVATAR_IMG_WIDTH+10;
        y = AVATAR_IMG_HEIGHT+20;
    } else {
        x = _position==LEFT ? -15 : AVATAR_IMG_HEIGHT+15;
        y = (_hand==LEFTHAND && _position==LEFT) || (_hand==RIGHTHAND && _position==RIGHT) ? AVATAR_IMG_HEIGHT+20 : -40;
    }
    return ccp(x, y);
}

-(CGPoint) getActionIconPosition: (int) n {
    float x, y;
    int width = AVATAR_IMG_WIDTH;
    int height = AVATAR_IMG_HEIGHT;
    if(!_realPositionModeEnable) {
        x = _hand==LEFTHAND ? -10 : width+10;
        y = height-10-20*n;
    } else if(_position==BOTTEM || _position==TOP) {
        x = (_hand==LEFTHAND && _position==BOTTEM) || (_hand==RIGHTHAND && _position==TOP) ? -10 : width+10;
        y = height-10-20*n;
    } else {
        x = _position==LEFT ? 10+20*n : width-10-20*n;
        y = (_hand==LEFTHAND && _position==LEFT) || (_hand==RIGHTHAND && _position==RIGHT) ? height+15 : -40;
    }
    return ccp(x,y);
}

-(void) updateActionIcons {
    int n = 0;
    for(CCSprite* icon in _actionIcons) {
        icon.position = [self getActionIconPosition: n];
        n++;
    }
}

-(void) addChild: (CCNode*) child {
    [_player.sprite addChild:child];
}

-(void) removeChild: (CCNode*)child {
    [_player.sprite removeChild:child];
}

-(void) setPosition:(POSITION)position {
    _position = position;
    [self updateHandIcon];
    [self updateActionIcons];
}

-(void) setRealPositionModeEnable:(BOOL)realPositionModeEnable {
    _realPositionModeEnable = realPositionModeEnable;
    [self updateHandIcon];
    [self updateActionIcons];
}

@end
