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

@interface UIPlayer : Player <UIGestureRecognizerDelegate> {
    BOOL _realPositionModeEnable;
    POSITION _position;
    BOOL expanded;
    
    BOOL shortPressMoveBegan;
    BOOL longPressMoveBegan;
    BOOL wasSetteledBeforeShortPressMove;
    CGPoint positionBeforeShortPressMove;
    CGPoint originalPoint;
    UITapGestureRecognizer *tapGestureRecognizer;
    UILongPressGestureRecognizer *shortPressGestureRecognizer;
    UILongPressGestureRecognizer *longPressGestureRecognizer;
    UILongPressGestureRecognizer *superLongPressGestureRecognizer;
    
    Role _initialRole;
    NSMutableArray* _actionIcons;
    NSMutableArray* _actionIconsBackup;
}

@property (nonatomic, strong) PlayerView* view;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) id<UIPlayerControleDelegate> delegate;

@property (atomic) BOOL settled;
@property (atomic) BOOL readyToMove;
@property (atomic) BOOL realPositionModeEnable;
@property (atomic) POSITION position;


-(void) setRole: (Role) role;
-(void) setView: (PlayerView *) view;
-(void) addChild: (UIView*) child;
-(void) removeChild: (UIView*)child;

-(void) addActionIcon: (Role) roler withResult: (BOOL) result;
-(void) showRoleInfo;
-(void) hideRoleInfo;
-(void) updatePlayerIcon;
-(void) addActionIcon: (Role) roler withResult: (BOOL) result;
-(void) removeLastActionIcon;
-(void) backupActionIcons;
-(void) restoreActionIcons;

-(void) selectPlayer: (UITapGestureRecognizer*) sender;


@end

@protocol UIPlayerControleDelegate
@required
-(void) selectPlayerById: (NSString*) id;
-(void) selectAllPlayersToMove;
-(void) playerPositionChanged : (UIPlayer*) player;
-(void) superLongPressPlayer : (UIPlayer*) player;
-(void) movePlayer: (UIPlayer*) player toPosition: (CGPoint) point;
@end
