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
#import "CCNode+SFGestureRecognizers.h"
#import "UIImage+Resize.h"

@implementation CCPlayer

-(id) init: (NSString*) id {
    return [self init: id withRole: Citizen];
}

-(id) init: (NSString*) id withRole: (Role) role {
    return [self init: id withRole: role withAvatar:YES];
}

-(id) init: (NSString*) id withRole: (Role) role withAvatar: (BOOL) hasAvatar {
    NSString* name = [[NSUserDefaults standardUserDefaults] objectForKey:[id stringByAppendingString:@"-name"]];

    if(self = [super init: id andName: name withRole: role]) {
        _selectable = YES;
        actionIcons = [NSMutableArray new];
        actionIconsBackup = [NSMutableArray new];
        
        if(hasAvatar) {
            NSData* imgData = [[NSUserDefaults standardUserDefaults] dataForKey:[id stringByAppendingString:@"-img"]];
            UIImage* image = [UIImage imageWithData:imgData];
            image = [image resizedImage:CGSizeMake(AVATAR_IMG_WIDTH, AVATAR_IMG_HEIGHT) interpolationQuality:kCGInterpolationDefault];
            CCTexture2D *texture = [[CCTexture2D alloc] initWithCGImage: image.CGImage resolutionType: kCCResolutioniPad];
            _sprite = [[CCSprite alloc] initWithTexture:texture];
            CGSize textureSize = [texture contentSize];
            
            labelTTF = [CCLabelTTF labelWithString:_name fontName:@"Marker Felt" fontSize:14];
            labelTTF.position = ccp(textureSize.width/2, -14);
            [_sprite addChild: labelTTF];
        } else {
            _sprite = [CCSprite new];
        }
                
        _sprite.isTouchEnabled = YES;
        
        UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPlayer:)];
        [_sprite addGestureRecognizer:tapGestureRecognizer];
        
        UIGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(movePlayer:)];
        [_sprite addGestureRecognizer:longPressGestureRecognizer];

    }
    return self;
}

-(void) selectPlayer: (UITapGestureRecognizer*) sender {
    if(self.delegate) {
        [self.delegate selectPlayerById: self.id];
    }
}

-(void) movePlayer: (UILongPressGestureRecognizer*) sender {
    CGPoint location = [sender locationInView:sender.view];
    CGPoint locationInWorldSpace = [[CCDirector sharedDirector] convertToGL:location];
    CGPoint locationInMySpriteSpace = [sender.node convertToNodeSpace:locationInWorldSpace];
    
    if(sender.state == UIGestureRecognizerStateBegan) {
        originalPoint = locationInMySpriteSpace;
    } else {
        sender.node.position = ccpSub(ccpAdd(sender.node.position, locationInMySpriteSpace), originalPoint);
    }
}

-(void) setRole: (Role) role {
    if(_role != role) {
        _role = role;
        [self hideRoleInfo];
        [self showRoleInfo];
    }
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

-(void) updatePlayerIcon {
    _sprite.opacity = _status == OUT_GAME ? 80 : 999;
}

-(void) addActionIcon: (Role) role {
    CCSprite* icon = [CCSprite spriteWithFile: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:role]]];
    CGSize iconSize = icon.boundingBox.size;
    int n = actionIcons.count;
    float x = iconSize.width/2+iconSize.width*n;
    float y = AVATAR_IMG_HEIGHT+iconSize.height/2+2;
    
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
