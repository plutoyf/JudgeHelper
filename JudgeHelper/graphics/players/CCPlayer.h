//
//  CCPlayer.h
//  JudgeHelper
//
//  Created by fyang on 8/1/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "Player.h"

@interface CCPlayer : Player
{
    CCLabelTTF* labelTTF;
    CCSprite* avatar;
    BOOL expanded;
    NSMutableArray* actionIcons;
    NSMutableArray* actionIconsBackup;
}

@property(atomic) BOOL selectable;
@property (nonatomic, strong) CCSprite* sprite;

-(id) init: (NSString*) name withRole: (Role) role withAvatar: (BOOL) hasAvatar;

-(void) addChild: (CCNode*) child;
-(void) removeChild: (CCNode*)child;

-(void) setRole: (Role) role;
-(void) setLabel: (NSString*) label;
-(BOOL) isInside:(CGPoint) location;
-(void) showRoleInfo;
-(void) hideRoleInfo;
-(void) updatePlayerIcon;
-(void) addActionIcon: (Role) role;
-(void) removeLastActionIcon;
-(void) backupActionIcons;
-(void) restoreActionIcons;
@end
