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

-(id) init: (NSString*) id {
    return [self init: id withRole: Citizen];
}

-(id) init: (NSString*) id withRole: (Role) role {
    if(self = [super init: id withRole: role withAvatar: NO]) {
    }
    return self;
}

-(void) showRoleInfo {
    if(!expanded) {
        if(_role > 0) {
            NSString* handIconFile = _hand==LEFTHAND ? @"lefthand.png" : @"righthand.png";
            CGPoint handIconPosition = _hand==LEFTHAND ? ccp(-10, AVATAR_IMG_HEIGHT+20) : ccp(AVATAR_IMG_WIDTH+10, AVATAR_IMG_HEIGHT+20);
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
            
            handIcon.position = handIconPosition;
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

-(void) addActionIcon: (Role) role {
    CCSprite* icon = [CCSprite spriteWithFile: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:role]]];
    int width = AVATAR_IMG_WIDTH;
    int height = AVATAR_IMG_HEIGHT;
    float x, y;
    int n = actionIcons.count;
    if(_hand == LEFTHAND) {
        x = -10;
        y = height-10-20*n;
    } else {
        x = width+10;
        y = height-10-20*n;
    }
    
    icon.position = ccp(x, y);
    [actionIcons addObject:icon];
    [self addChild:icon];
}


-(void) addChild: (CCNode*) child {
    [_player.sprite addChild:child];
}

-(void) removeChild: (CCNode*)child {
    [_player.sprite removeChild:child];
}

@end
