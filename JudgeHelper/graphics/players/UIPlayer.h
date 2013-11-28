//
//  UIPlayer.h
//  JudgeHelper
//
//  Created by YANG FAN on 25/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"
#import "PlayerView.h"

typedef enum {
    BOTTEM = 0, LEFT = 2, TOP = 3, RIGHT = 4
} POSITION;

@protocol UIPlayerControleDelegate;

@interface UIPlayer : Player<PlayerViewDelegate> {
    BOOL _realPositionModeEnable;
    POSITION _position;
    BOOL expanded;
    Role _initialRole;
    NSMutableArray* _actionIcons;
    NSMutableArray* _actionIconsBackup;
}

@property (nonatomic, strong) PlayerView* view;
@property (nonatomic, assign) id<UIPlayerControleDelegate> delegate;

@property (atomic) BOOL realPositionModeEnable;
@property (atomic) POSITION position;

-(void) addActionIcon: (Role) roler withResult: (BOOL) result;

-(void) showRoleInfo;
-(void) hideRoleInfo;

@end

@protocol UIPlayerControleDelegate
@required
-(void) selectPlayerById: (NSString*) id;
-(void) selectAllPlayersToMove;
-(void) playerPositionChanged : (UIPlayer*) player;
-(void) superLongPressPlayer : (UIPlayer*) player;
-(void) movePlayer: (UIPlayer*) player toPosition: (CGPoint) point;
@end
