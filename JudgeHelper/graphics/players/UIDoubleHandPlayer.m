//
//  UIDoubleHandPlayer.m
//  JudgeHelper
//
//  Created by YANG FAN on 26/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "UIDoubleHandPlayer.h"

@implementation UIDoubleHandPlayer

-(void) selectPlayer {
    [self hideRoleInfo];
    [self showRoleInfo];
    [super selectPlayer];
}

-(void) setLeftHandPlayer:(UIHandPlayer *) player {
    player.hand = LEFTHAND;
    player.player = self;
    player.position = _position;
    player.realPositionModeEnable = _realPositionModeEnable;
    _leftHandPlayer = player;
}

-(void) setRightHandPlayer:(UIHandPlayer *) player {
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
        
        if (_leftHandPlayer.role == Citizen && _rightHandPlayer.role  == Citizen) {
        } else if (_leftHandPlayer.role > 0 || _rightHandPlayer.role > 0) {
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
        self.view.alpha = .3f;
    } else if(_leftHandPlayer.status == IN_GAME || _rightHandPlayer.status == IN_GAME) {
        self.view.alpha = 1.f;
    } else {
        [super updatePlayerIcon];
    }
}


@end
