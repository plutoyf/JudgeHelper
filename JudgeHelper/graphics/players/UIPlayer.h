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

@protocol UIPlayerControleDelegate;

@interface UIPlayer : Player<PlayerViewDelegate> {
    Role _initialRole;
    NSMutableArray* _actionIcons;
    NSMutableArray* _actionIconsBackup;
}

@property (nonatomic, strong) PlayerView* view;
@property (nonatomic, assign) id<UIPlayerControleDelegate> delegate;

-(void) addActionIcon: (Role) roler withResult: (BOOL) result;

@end

@protocol UIPlayerControleDelegate
@required
-(void) selectPlayerById: (NSString*) id;
-(void) selectAllPlayersToMove;
-(void) playerPositionChanged : (UIPlayer*) player;
-(void) superLongPressPlayer : (UIPlayer*) player;
-(void) movePlayer: (UIPlayer*) player toPosition: (CGPoint) point;
@end