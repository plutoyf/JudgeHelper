//
//  UIHandPlayer.m
//  JudgeHelper
//
//  Created by YANG FAN on 26/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "UIHandPlayer.h"
#import "CCEngin.h"
#import "DeviceSettings.h"

@implementation UIHandPlayer

-(void) showRoleInfo {
    if(!expanded) {
        if(_role > 0) {
            NSString* handIconFile = _hand==LEFTHAND ? @"lefthand.png" : @"righthand.png";
            
            UIImage *handImage = [UIImage imageNamed: handIconFile];
            handIcon = [[UIImageView alloc] initWithImage: handImage];
            [handIcon addConstraint:[NSLayoutConstraint constraintWithItem:handIcon attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(handImage.size.width)]];
            [handIcon addConstraint:[NSLayoutConstraint constraintWithItem:handIcon attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(handImage.size.height)]];
            
            handIcon.userInteractionEnabled = YES;
            UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectHandPlayer:)];
            [handIcon addGestureRecognizer:tapGestureRecognizer];
            
            //handIcon.position = [self getHandIconPosition];
            handIcon.alpha = _status == OUT_GAME ? .3f : 1.f;
            handIcon.translatesAutoresizingMaskIntoConstraints = NO;
            [_player.view addSubview: handIcon];
            
            [_player.view addConstraint:[NSLayoutConstraint constraintWithItem:handIcon attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_player.view attribute:NSLayoutAttributeTop multiplier:1.f constant:-2.f]];
            [_player.view addConstraint:[NSLayoutConstraint constraintWithItem:handIcon attribute:_hand==LEFTHAND?NSLayoutAttributeTrailing:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_player.view attribute:_hand==LEFTHAND?NSLayoutAttributeLeading:NSLayoutAttributeTrailing multiplier:1.f constant:(_hand==LEFTHAND?1:-1)*REVERSE(10)]];
            
            [_player.view layoutIfNeeded];
            
            if(_role != Citizen) {
                UIImage *roleImage = [UIImage imageNamed: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:_role]]];
                UIImageView *roleIcon = [[UIImageView alloc] initWithImage:roleImage];
                
                [roleIcon addConstraint:[NSLayoutConstraint constraintWithItem:roleIcon attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(roleImage.size.width)]];
                [roleIcon addConstraint:[NSLayoutConstraint constraintWithItem:roleIcon attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(roleImage.size.height)]];
                
                roleIcon.alpha = _status == OUT_GAME ? .2f : 1.f;
                roleIcon.translatesAutoresizingMaskIntoConstraints = NO;
                [handIcon addSubview: roleIcon];
                
                [handIcon addConstraint:[NSLayoutConstraint constraintWithItem:roleIcon attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:handIcon attribute:NSLayoutAttributeCenterX multiplier:1.f constant:(_hand==LEFTHAND?-1:1)*REVERSE(2)]];
                [handIcon addConstraint:[NSLayoutConstraint constraintWithItem:roleIcon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:handIcon attribute:NSLayoutAttributeCenterY multiplier:1.f constant:REVERSE(6)]];

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

-(void) updatePlayerIcon {
    handIcon.alpha = _status == OUT_GAME ? .3f : 1.f;
    [_player updatePlayerIcon];
}

-(void) selectHandPlayer: (UITapGestureRecognizer*) sender {
    [self selectPlayer:sender];
}

-(void) addActionIcon: (Role) role withResult:(BOOL)result {
    UIImage *iconImage = [UIImage imageNamed: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:role]]];
    UIImageView *icon = [[UIImageView alloc] initWithImage: iconImage];
    
    [icon addConstraint:[NSLayoutConstraint constraintWithItem:icon attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(iconImage.size.width)]];
    [icon addConstraint:[NSLayoutConstraint constraintWithItem:icon attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(iconImage.size.height)]];
    
    icon.alpha = result ? 1.f : .3f;
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [_actionIcons addObject:icon];
    [self addChild:icon];
    [_player.view layoutIfNeeded];
}

-(void) addChild: (UIView*) child {
    [_player.view addSubview:child];
    
    [_player.view addConstraint:[NSLayoutConstraint constraintWithItem:child attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_player.view.imageView attribute:NSLayoutAttributeTop multiplier:1.f constant:REVERSE(20)*(_actionIcons.count-1)]];
    [_player.view addConstraint:[NSLayoutConstraint constraintWithItem:child attribute:_hand==LEFTHAND?NSLayoutAttributeTrailing:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_player.view.imageView attribute:_hand==LEFTHAND?NSLayoutAttributeLeading:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
}


@end
