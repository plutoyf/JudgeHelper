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

-(id) init: (NSString*) id andName:(NSString *)name {
    return [self init: id andName:name withRole: Citizen];
}

-(id) init: (NSString*) id withRole: (Role) role {
    return [self init: id withRole: role withAvatar:YES];
}

-(id) init: (NSString*) id andName:(NSString *)name withRole: (Role) role {
    return [self init: id andName:name withRole: role withAvatar:YES];
}

-(id) init: (NSString*) id withRole: (Role) role withAvatar: (BOOL) hasAvatar {
    NSString* name = [[NSUserDefaults standardUserDefaults] objectForKey:[id stringByAppendingString:@"-name"]];
    return [self init: id andName:name withRole: role withAvatar:hasAvatar];
}

-(id) init: (NSString*) id andName:(NSString *)name withRole: (Role) role withAvatar: (BOOL) hasAvatar {
    if(self = [super init: id andName: name withRole: role]) {
        _selectable = YES;
        _actionIcons = [NSMutableArray new];
        _actionIconsBackup = [NSMutableArray new];
        
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
        
        longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(movePlayer:)];
        longPressGestureRecognizer.minimumPressDuration = 0;
        [_sprite addGestureRecognizer:longPressGestureRecognizer];

    }
    return self;
}

-(void) selectPlayer: (UITapGestureRecognizer*) sender {
    if(self.delegate) {
        [self.delegate selectPlayerById: self.id];
    }
}

-(void) setSettled: (BOOL) settled {
    _settled = settled;
    longPressGestureRecognizer.minimumPressDuration = settled?0.2:0;
}

-(void) movePlayer: (UILongPressGestureRecognizer*) sender {
    CGPoint location = [sender locationInView:sender.view];
    CGPoint locationInWorldSpace = [[CCDirector sharedDirector] convertToGL:location];
    CGPoint locationInMySpriteSpace = [sender.node convertToNodeSpace:locationInWorldSpace];
    
    if(sender.state == UIGestureRecognizerStateBegan) {
        originalPoint = locationInMySpriteSpace;
        CCLayerColor *layerColer = [CCLayerColor layerWithColor:ccc4(0,255,0,255)];
        layerColer.contentSize = CGSizeMake(_sprite.texture.contentSize.width+4, _sprite.texture.contentSize.height+4);
        layerColer.position = ccp(-2, -2);
        layerColer.tag = 9;
        [_sprite addChild:layerColer z:-1];
    } else if(sender.state == UIGestureRecognizerStateEnded) {
        [_sprite removeChildByTag:9];
        [_delegate playerPositionChanged: self];
    } else {
        [_delegate movePlayer: self toPosition:ccpSub(ccpAdd(sender.node.position, locationInMySpriteSpace), originalPoint)];
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

-(void) addActionIcon: (Role) role withResult:(BOOL)result {
    CCSprite* icon = [CCSprite spriteWithFile: [NSString stringWithFormat:@"Icon-20-%@.png", [CCEngin getRoleCode:role]]];
    icon.opacity = result ? 255 : 80;
    CGSize iconSize = icon.boundingBox.size;
    int n = _actionIcons.count;
    float x = iconSize.width/2+iconSize.width*n;
    float y = AVATAR_IMG_HEIGHT+iconSize.height/2+2;
    
    icon.position = ccp(x, y);
    [_actionIcons addObject:icon];
    [self addChild:icon];
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
    for(CCSprite* icon in iconsBackup) {
        [_actionIcons addObject:icon];
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
