//
//  CCPlayer.m
//  JudgeHelper
//
//  Created by fyang on 8/1/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "CCPlayer.h"
#import "CCEngin.h"
#import "Constants.h"

@implementation CCPlayer

-(id) init: (NSString*) name {
    return [self init: name withRole: Citizen];
}

-(id) init: (NSString*) name withRole: (Role) role {
    return [self init: name withRole: role withAvatar:YES];
}

-(id) init: (NSString*) name withRole: (Role) role withAvatar: (BOOL) hasAvatar {
    if(self = [super init: name withRole: role]) {
        _selectable = YES;
        _sprite = [CCSprite new];
        actionIcons = [NSMutableArray new];
        actionIconsBackup = [NSMutableArray new];
        
        if(hasAvatar) {
            NSData* imgData = [[NSUserDefaults standardUserDefaults] dataForKey:name];
            UIImage* iconImg = [UIImage imageWithData:imgData];
            CCTexture2D *texture = [[CCTexture2D alloc] initWithCGImage: iconImg.CGImage resolutionType: kCCResolutioniPad];
            avatar = [[CCSprite alloc] initWithTexture:texture];
            CGSize textureSize = [texture contentSize];
            [avatar setScaleX: AVATAR_IMG_WIDTH/textureSize.width];
            [avatar setScaleY: AVATAR_IMG_HEIGHT/textureSize.height];
            
            [_sprite addChild:avatar];
            
            labelTTF = [CCLabelTTF labelWithString:_name fontName:@"Marker Felt" fontSize:12];
            labelTTF.position = ccp(0, -46);
            [_sprite addChild: labelTTF];
        }
        

    }
    return self;
}

-(void) setRole: (Role) role {
    if(_role != role) {
        _role = role;
        [self hideRoleInfo];
        [self showRoleInfo];
    }
}

-(void) setAvatarWithTexture: (CCTexture2D*) texture {
    if(avatar) {
        [_sprite removeChild:avatar];
    }
    
    avatar = [[CCSprite alloc] initWithTexture:texture];
    CGSize textureSize = [texture contentSize];
    [avatar setScaleX: AVATAR_IMG_WIDTH/textureSize.width];
    [avatar setScaleY: AVATAR_IMG_HEIGHT/textureSize.height];
    
    [_sprite addChild:avatar];
    
}

-(void) setLabel: (NSString*) label {
    labelTTF.string = label;
}

-(void) showRoleInfo {
    if(!expanded) {
        if(_role > 0 && _role != Citizen) {
            [self setLabel: [NSString stringWithFormat:@"%@ [%@]", _name, [Engin getRoleName: _role]]];
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

-(BOOL) isInside:(CGPoint) location {
    return CGRectContainsPoint(avatar.boundingBox, ccpSub(location, self.sprite.boundingBox.origin));
}

-(void) updatePlayerIcon {
    avatar.opacity = _status == OUT_GAME ? 80 : 999;
}

-(void) addActionIcon: (Role) role {
    CCSprite* icon = [CCSprite spriteWithFile: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:role]]];
    float x = -AVATAR_IMG_WIDTH/2+10, y = AVATAR_IMG_HEIGHT/2+10;
    int n = actionIcons.count;
    x = -AVATAR_IMG_WIDTH/2+10+20*n;
    y = AVATAR_IMG_HEIGHT/2+10;
    
    icon.position = ccp(x, y);
    [actionIcons addObject:icon];
    [self addChild:icon];
}

-(void) removeLastActionIcon {
    if(actionIcons && actionIcons.count > 0){
        [self removeChild:[actionIcons lastObject]];
        [actionIcons removeLastObject];
    }
}

-(void) removeAllActionIcon {
    while(actionIcons.count > 0) {
        [self removeChild:[actionIcons lastObject]];
        [actionIcons removeLastObject];
    }
}

-(void) backupActionIcons {
    [actionIcons addObject: actionIconsBackup];
    [self removeAllActionIcon];
}

-(void) restoreActionIcons {
    NSMutableArray* iconsBackup = (NSMutableArray*)[actionIconsBackup lastObject];
    [actionIconsBackup removeLastObject];
    for(CCSprite* icon in iconsBackup) {
        [actionIcons addObject:icon];
        [self addChild:icon];
    }
}

-(void) addChild: (CCNode*) child {
    [_sprite addChild:child];
}

-(void) removeChild: (CCNode*)child {
    [_sprite removeChild:child];
}

@end
