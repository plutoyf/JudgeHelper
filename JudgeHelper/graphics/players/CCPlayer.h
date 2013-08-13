//
//  CCPlayer.h
//  JudgeHelper
//
//  Created by fyang on 8/1/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "Player.h"
#import "MySprite.h"

@protocol CCPlayerControleDelegate;

@interface CCPlayer : Player
{
    CCLabelTTF* labelTTF;
    BOOL expanded;
    BOOL _settled;
    NSMutableArray* _actionIcons;
    NSMutableArray* _actionIconsBackup;
    CGPoint originalPoint;
    UILongPressGestureRecognizer *longPressGestureRecognizer;
}

@property(atomic) BOOL selectable;
@property (nonatomic, strong) CCSprite* sprite;
@property (atomic) BOOL settled;
@property (nonatomic, strong, readonly) NSMutableArray* actionIcons;
@property (nonatomic, strong, readonly) NSMutableArray* actionIconsBackup;
@property (nonatomic, assign) id<CCPlayerControleDelegate> delegate;

-(id) init: (NSString*) id;
-(id) init: (NSString*) id withRole: (Role) role;
-(id) init: (NSString*) id withRole: (Role) role withAvatar: (BOOL) hasAvatar;
-(id) init: (NSString*) id andName:(NSString *)name;
-(id) init: (NSString*) id andName:(NSString *)name withRole: (Role) role;
-(id) init: (NSString*) id andName:(NSString *)name withRole: (Role) role withAvatar: (BOOL) hasAvatar;

-(void) addChild: (CCNode*) child;
-(void) removeChild: (CCNode*)child;

-(void) selectPlayer: (UITapGestureRecognizer*) sender;
-(void) setSettled: (BOOL) settled;
-(void) setRole: (Role) role;
-(void) setLabel: (NSString*) label;
-(void) showRoleInfo;
-(void) hideRoleInfo;
-(void) updatePlayerIcon;
-(void) addActionIcon: (Role) roler withResult: (BOOL) result;
-(void) removeLastActionIcon;
-(void) backupActionIcons;
-(void) restoreActionIcons;
@end

@protocol CCPlayerControleDelegate
@required
-(void) selectPlayerById: (NSString*) id;
-(void) playerPositionChanged : (CCPlayer*) player;
-(void) movePlayer: (CCPlayer*) player toPosition: (CGPoint) point;
@end
