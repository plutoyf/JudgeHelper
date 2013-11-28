//
//  UIHandPlayer.m
//  JudgeHelper
//
//  Created by YANG FAN on 26/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "UIHandPlayer.h"
#import "CCEngin.h"

@implementation UIHandPlayer

-(void) showRoleInfo {
    if(!expanded) {
        if(_role > 0) {
            NSString* handIconFile = _hand==LEFTHAND ? @"lefthand.png" : @"righthand.png";
            
            handIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed: handIconFile]];
            
            handIcon.userInteractionEnabled = YES;
            UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectHandPlayer:)];
            [handIcon addGestureRecognizer:tapGestureRecognizer];
            
            //handIcon.position = [self getHandIconPosition];
            handIcon.alpha = _status == OUT_GAME ? .2f : 1.f;
            handIcon.translatesAutoresizingMaskIntoConstraints = NO;
            [_player.view addSubview: handIcon];
            
            [_player.view addConstraint:[NSLayoutConstraint constraintWithItem:handIcon attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_player.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
            [_player.view addConstraint:[NSLayoutConstraint constraintWithItem:handIcon attribute:_hand==LEFTHAND?NSLayoutAttributeTrailing:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_player.view attribute:_hand==LEFTHAND?NSLayoutAttributeLeading:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
            
            [_player.view layoutIfNeeded];
            
            if(_role != Citizen) {
                UIImageView *roleIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:_role]]]];
                roleIcon.alpha = _status == OUT_GAME ? .2f : 1.f;
                roleIcon.translatesAutoresizingMaskIntoConstraints = NO;
                [_player.view addSubview: roleIcon];
                
                [_player.view addConstraint:[NSLayoutConstraint constraintWithItem:roleIcon attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:handIcon attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
                [_player.view addConstraint:[NSLayoutConstraint constraintWithItem:roleIcon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:handIcon attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];

            }
            
        }
        expanded = YES;
        
        [_player showRoleInfo];
    }
    
}

-(void) hideRoleInfo {
    if(expanded) {
        [handIcon removeFromSuperview];
        expanded = NO;
        
        [_player hideRoleInfo];
    }
    
}

-(void) selectHandPlayer: (UITapGestureRecognizer*) sender {
    [self selectPlayer];
}

@end
