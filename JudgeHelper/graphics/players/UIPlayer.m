//
//  UIPlayer.m
//  JudgeHelper
//
//  Created by YANG FAN on 25/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "UIPlayer.h"
#import "CCEngin.h"

@implementation UIPlayer

-(id) init: (NSString*) id andName:(NSString *)name withRole: (Role) role {
    if(self = [super init: id andName: name withRole: role]) {
        _actionIcons = [NSMutableArray new];
        _actionIconsBackup = [NSMutableArray new];
    }
    return self;
}

-(void) selectPlayer {
    [self.delegate selectPlayerById: self.id];
}

-(void) playerPositionDidChanged {
    [self.delegate playerPositionChanged: self];
}

-(void) setRole: (Role) role {
    if(_role != role) {
        if(_initialRole == 0) {
            _initialRole = role;
        }
        _role = role;
        
        [self hideRoleInfo];
        [self showRoleInfo];
    }
}



-(void) setLabel: (NSString*) label {
    self.view.name.text = label;
}

-(void) showRoleInfo {
    if(!expanded) {
        if(_role == Citizen) {
            [self setLabel: _name];
        } else if(_role > 0) {
            [self setLabel: [NSString stringWithFormat:@"%@ [%@]", _name, [CCEngin getRoleLabel: _role]]];
        }
        expanded = YES;
    }
}

-(void) hideRoleInfo {
    if(expanded) {
        [self setLabel: _name];
        expanded = NO;
    }
}

-(void) rollbackStatus {
    [super rollbackStatus];
    
    if(_roleStack.count == 0 && _initialRole > 0) {
        self.role = _initialRole;
    }
}

-(void) updatePlayerIcon {
    self.view.alpha = _status == OUT_GAME ? .3f : 1.f;
}

-(void) addActionIcon: (Role) role withResult:(BOOL)result {
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:role]]]];
    icon.alpha = result ? 1.f : .3f;
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [_actionIcons addObject:icon];
    [self addChild:icon];
    [self.view layoutIfNeeded];
}

-(void) removeLastActionIcon {
    if(_actionIcons && _actionIcons.count > 0){
        [self removeChild:[_actionIcons lastObject]];
        [_actionIcons removeLastObject];
    }
}

-(void) removeAllActionIcon {
    while(_actionIcons.count > 0) {
        [self removeChild:[_actionIcons lastObject]];
        [_actionIcons removeLastObject];
    }
}

-(void) backupActionIcons {
    NSMutableArray* iconsBackup = [NSMutableArray arrayWithArray:_actionIcons];
    [_actionIconsBackup addObject:iconsBackup];
    
    [self removeAllActionIcon];
}

-(void) restoreActionIcons {
    NSMutableArray* iconsBackup = (NSMutableArray*)[_actionIconsBackup lastObject];
    [_actionIconsBackup removeLastObject];
    for(UIImageView* icon in iconsBackup) {
        [_actionIcons addObject:icon];
        [self addChild:icon];
    }
    
    [self.view layoutIfNeeded];
}

-(void) addChild: (UIView*) child {
    [self.view addSubview:child];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:child attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view.imageView attribute:NSLayoutAttributeTop multiplier:1.f constant:-20.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:child attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view.imageView attribute:NSLayoutAttributeLeading multiplier:1.f constant:20.f*(_actionIcons.count-1)]];
}

-(void) removeChild: (UIView*)child {
    [child removeFromSuperview];
}


@end
