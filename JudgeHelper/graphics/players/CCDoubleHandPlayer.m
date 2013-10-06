//
//  CCDoubleHandPlayer.m
//  JudgeHelper
//
//  Created by fyang on 8/1/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "CCDoubleHandPlayer.h"
#import "Engin.h"
#import "CCNode+SFGestureRecognizers.h"

@implementation CCDoubleHandPlayer

-(void) selectPlayer: (UITapGestureRecognizer*) sender {
    [self hideRoleInfo];
    [self showRoleInfo];
    [super selectPlayer:sender];
}

-(void) setLeftHandPlayer:(CCHandPlayer *) player {
    player.hand = LEFTHAND;
    player.player = self;
    player.position = _position;
    player.realPositionModeEnable = _realPositionModeEnable;
    _leftHandPlayer = player;
}

-(void) setRightHandPlayer:(CCHandPlayer *) player {
    player.hand = RIGHTHAND;
    player.player = self;
    player.position = _position;
    player.realPositionModeEnable = _realPositionModeEnable;
    _rightHandPlayer = player;
}

-(void) showRoleInfo {
    if(!expanded) {
        [_leftHandPlayer showRoleInfo];
        [_rightHandPlayer showRoleInfo];
        
        if ((_leftHandPlayer.role > 0 && _leftHandPlayer.role != Citizen) || (_rightHandPlayer.role > 0 && _rightHandPlayer.role != Citizen)) {
            //[self setLabel: [NSString stringWithFormat:@"[%@] %@ [%@]", [Engin getRoleName: _leftHandPlayer.role], _name, [Engin getRoleName: _rightHandPlayer.role]]];
        } else {
            [super showRoleInfo];
        }
        expanded = YES;
    }
}

-(void) hideRoleInfo {
    if(expanded) {
        [_leftHandPlayer hideRoleInfo];
        [_rightHandPlayer hideRoleInfo];
        
        [super hideRoleInfo];
        expanded = NO;
    }
}

-(void) updatePlayerIcon {
    if(_leftHandPlayer.status == OUT_GAME && _rightHandPlayer.status == OUT_GAME) {
        self.sprite.opacity = 80;
    } else if(_leftHandPlayer.status == IN_GAME || _rightHandPlayer.status == IN_GAME) {
        self.sprite.opacity = 999;
    } else {
        [super updatePlayerIcon];
    }
}

-(void) setPosition:(POSITION)position {
    _position = position;
    _leftHandPlayer.position = position;
    _rightHandPlayer.position = position;
}

-(void) setRealPositionModeEnable:(BOOL)realPositionModeEnable {
    _realPositionModeEnable = realPositionModeEnable;
    _leftHandPlayer.realPositionModeEnable = realPositionModeEnable;
    _rightHandPlayer.realPositionModeEnable = realPositionModeEnable;
}

@end
