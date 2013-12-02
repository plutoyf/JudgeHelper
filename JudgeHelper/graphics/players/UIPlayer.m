//
//  UIPlayer.m
//  JudgeHelper
//
//  Created by YANG FAN on 25/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "UIPlayer.h"
#import "CCEngin.h"
#import "DeviceSettings.h"

@implementation UIPlayer

@synthesize tapGestureRecognizer=tapGestureRecognizer;

-(id) init: (NSString*) id andName:(NSString *)name withRole: (Role) role {
    if(self = [super init: id andName: name withRole: role]) {
        _actionIcons = [NSMutableArray new];
        _actionIconsBackup = [NSMutableArray new];
    }
    return self;
}

-(void) selectPlayer: (UITapGestureRecognizer*) sender {
    if(self.delegate && !self.readyToMove) {
        [self.delegate selectPlayerById: self.id];
    }
}

-(void) setSettled: (BOOL) settled {
    _settled = settled;
    shortPressGestureRecognizer.minimumPressDuration = settled?0.15:0;
}


-(void) shortPressMovePlayer: (UILongPressGestureRecognizer*) sender {
    CGPoint location = [sender locationInView:self.view.superview];
    if(!longPressMoveBegan) {
        if(sender.state == UIGestureRecognizerStateBegan) {
            positionBeforeShortPressMove = location;
            wasSetteledBeforeShortPressMove = _settled;
            originalPoint = ccpSub(self.view.center, location);
            [self setReadyToMove: YES];
        } else if(sender.state == UIGestureRecognizerStateEnded) {
            [_delegate playerPositionChanged: self];
            shortPressMoveBegan = NO;
        } else {
            //NSLog(@"shortPressMove %f %f", location.x, location.y);
            shortPressMoveBegan = YES;
            [_delegate movePlayer: self toPosition:ccpAdd(location, originalPoint)];
        }
    }
}

-(void) longPressMovePlayer: (UILongPressGestureRecognizer*) sender {
    CGPoint location = [sender locationInView:self.view.superview];
    CGPoint locationInPlayerSpace = [sender locationInView:self.view];
    
    if(wasSetteledBeforeShortPressMove && !shortPressMoveBegan) {
        if(sender.state == UIGestureRecognizerStateBegan) {
            //sender.node.position = positionBeforeShortPressMove;
            _settled = wasSetteledBeforeShortPressMove;
            longPressMoveBegan = YES;
            originalPoint = locationInPlayerSpace;
            [_delegate selectAllPlayersToMove];
        } else if(longPressMoveBegan) {
            if(sender.state == UIGestureRecognizerStateEnded) {
                [_delegate playerPositionChanged: nil];
                longPressMoveBegan = NO;
            } else {
                //NSLog(@"longPressMove %f %f", location.x, location.y);
                [_delegate movePlayer: self toPosition:location];
                //[_delegate movePlayer: self toPosition:ccpSub(ccpAdd(location, CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)), originalPoint)];
            }
        }
    }
}

-(void) superLongPressMovePlayer: (UILongPressGestureRecognizer*) sender {
    if(sender.state == UIGestureRecognizerStateBegan) {
        [_delegate superLongPressPlayer:self];
    }
}

-(void) setReadyToMove:(BOOL)readyToMove {
    _readyToMove = readyToMove;
    
    if(readyToMove) {
        self.view.imageView.alpha = .4f;
    } else {
        self.view.imageView.alpha = 1.f;
    }
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

-(void) setView: (PlayerView *) view {
    _view = view;
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPlayer:)];
    [self.view.imageView addGestureRecognizer:tapGestureRecognizer];
    
    shortPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shortPressMovePlayer:)];
    shortPressGestureRecognizer.minimumPressDuration = 0.4;
    shortPressGestureRecognizer.delegate = self;
    [self.view.imageView addGestureRecognizer:shortPressGestureRecognizer];
    
    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMovePlayer:)];
    longPressGestureRecognizer.minimumPressDuration = 1.2;
    longPressGestureRecognizer.allowableMovement = 20;
    longPressGestureRecognizer.delegate = self;
    [self.view.imageView addGestureRecognizer:longPressGestureRecognizer];
    
    superLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(superLongPressMovePlayer:)];
    superLongPressGestureRecognizer.minimumPressDuration = 5;
    superLongPressGestureRecognizer.allowableMovement = 20;
    superLongPressGestureRecognizer.delegate = self;
    [self.view.imageView addGestureRecognizer:superLongPressGestureRecognizer];
    
    
    [tapGestureRecognizer requireGestureRecognizerToFail:shortPressGestureRecognizer];
    [tapGestureRecognizer requireGestureRecognizerToFail:longPressGestureRecognizer];
    [tapGestureRecognizer requireGestureRecognizerToFail:superLongPressGestureRecognizer];
}

-(void) setLabel: (NSString*) label {
    self.view.name.text = label;
}

-(void) showRoleInfo {
    if(!expanded) {
        if(_role == Citizen) {
            [self setLabel: _name];
        } else if(_role > 0) {
            [self setLabel: [NSString stringWithFormat:@"%@\n[%@]", _name, [CCEngin getRoleLabel: _role]]];
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
    
    if((self.role == 0 || self.role == Citizen) && _initialRole > 0) {
        self.role = _initialRole;
    }
}

-(void) updatePlayerIcon {
    self.view.alpha = _status == OUT_GAME ? .4f : 1.f;
}

-(void) addActionIcon: (Role) role withResult:(BOOL)result {
    UIImage *iconImage = [UIImage imageNamed: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:role]]];
    UIImageView *icon = [[UIImageView alloc] initWithImage: iconImage];
    
    [icon addConstraint:[NSLayoutConstraint constraintWithItem:icon attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(iconImage.size.width)]];
    [icon addConstraint:[NSLayoutConstraint constraintWithItem:icon attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(iconImage.size.height)]];
        
    icon.alpha = result ? 1.f : .4f;
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
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:child attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view.imageView attribute:NSLayoutAttributeTop multiplier:1.f constant:REVERSE(-20)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:child attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view.imageView attribute:NSLayoutAttributeLeading multiplier:1.f constant:REVERSE(20)*(_actionIcons.count-1)]];
}

-(void) removeChild: (UIView*)child {
    [child removeFromSuperview];
}



-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
