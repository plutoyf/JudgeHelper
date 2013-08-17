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

typedef enum {
    BOTTEM = 0, LEFT = 2, TOP = 3, RIGHT = 4
} POSITION;

@protocol CCPlayerControleDelegate;

@interface CCPlayer : Player <UIGestureRecognizerDelegate>
{
    CCLabelTTF* labelTTF;
    CCLayerColor *layerColer;
    BOOL _realPositionModeEnable;
    POSITION _position;
    BOOL expanded;
    BOOL longPressMoveBegan;
    BOOL wasSetteledBeforeShortPressMove;
    CGPoint positionBeforeShortPressMove;
    CGPoint originalPoint;
    NSMutableArray* _actionIcons;
    NSMutableArray* _actionIconsBackup;
    UILongPressGestureRecognizer *shortPressGestureRecognizer;
    UILongPressGestureRecognizer *longPressGestureRecognizer;
    UILongPressGestureRecognizer *superLongPressGestureRecognizer;
}

@property (atomic) BOOL realPositionModeEnable;
@property (atomic) POSITION position;
@property (atomic) BOOL selectable;
@property (nonatomic, strong) CCSprite* sprite;
@property (atomic) BOOL settled;
@property (atomic) BOOL readyToMove;
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

-(void) setPosition: (POSITION) position;
-(void) setRealPositionModeEnable: (BOOL) realPositionModeEnable;
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
-(void) selectAllPlayersToMove;
-(void) playerPositionChanged : (CCPlayer*) player;
-(void) superLongPressPlayer : (CCPlayer*) player;
-(void) movePlayer: (CCPlayer*) player toPosition: (CGPoint) point;
@end
