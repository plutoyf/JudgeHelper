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
        _realPositionModeEnable = YES;
        _position = BOTTEM;
        _selectable = YES;
        _actionIcons = [NSMutableArray new];
        _actionIconsBackup = [NSMutableArray new];
        
        if(hasAvatar) {
            NSData* imgData = [[NSUserDefaults standardUserDefaults] dataForKey:[id stringByAppendingString:@"-img"]];
            UIImage* image = [UIImage imageWithData:imgData];
            image = [image resizedImage:CGSizeMake(AVATAR_IMG_WIDTH, AVATAR_IMG_HEIGHT) interpolationQuality:kCGInterpolationDefault];
            CCTexture2D *texture = [[CCTexture2D alloc] initWithCGImage: image.CGImage resolutionType: kCCResolutioniPad];
            _sprite = [[CCSprite alloc] initWithTexture:texture];
            NSString* positionStr = [[NSUserDefaults standardUserDefaults] stringForKey:[id stringByAppendingString:@"-pos"]];
            _sprite.position = [self getPositionFromString : positionStr];
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
        
        shortPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shortPressMovePlayer:)];
        shortPressGestureRecognizer.minimumPressDuration = 0;
        shortPressGestureRecognizer.delegate = self;
        [_sprite addGestureRecognizer:shortPressGestureRecognizer];
        
        longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMovePlayer:)];
        longPressGestureRecognizer.minimumPressDuration = 1.2;
        longPressGestureRecognizer.allowableMovement = 5;
        longPressGestureRecognizer.delegate = self;
        [_sprite addGestureRecognizer:longPressGestureRecognizer];
        
        superLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(superLongPressMovePlayer:)];
        superLongPressGestureRecognizer.minimumPressDuration = 5;
        superLongPressGestureRecognizer.allowableMovement = 20;
        superLongPressGestureRecognizer.delegate = self;
        [_sprite addGestureRecognizer:superLongPressGestureRecognizer];

        
        [tapGestureRecognizer requireGestureRecognizerToFail:shortPressGestureRecognizer];
        [tapGestureRecognizer requireGestureRecognizerToFail:longPressGestureRecognizer];
        [tapGestureRecognizer requireGestureRecognizerToFail:superLongPressGestureRecognizer];

    }
    return self;
}

-(CGPoint) getPositionFromString: (NSString*) positionStr {
    CGPoint pos = CGPointMake(0, 0);
    
    long i = [positionStr rangeOfString: @","].location;
    if(i > 0) {
        pos.x =  [[positionStr substringToIndex: i] floatValue];
        pos.y = [[positionStr substringFromIndex: i+1] floatValue];
    }
    
    return pos;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void) selectPlayer: (UITapGestureRecognizer*) sender {
    if(self.delegate) {
        [self.delegate selectPlayerById: self.id];
    }
}

-(void) setSettled: (BOOL) settled {
    _settled = settled;
    shortPressGestureRecognizer.minimumPressDuration = settled?0.15:0;
}

-(void) longPressMovePlayer: (UILongPressGestureRecognizer*) sender {
    CGPoint location = [sender locationInView:sender.view];
    CGPoint locationInWorldSpace = [[CCDirector sharedDirector] convertToGL:location];
    CGPoint locationInMySpriteSpace = [sender.node convertToNodeSpace:locationInWorldSpace];
    
    if(wasSetteledBeforeShortPressMove) {
        if(sender.state == UIGestureRecognizerStateBegan) {
            sender.node.position = positionBeforeShortPressMove;
            _settled = wasSetteledBeforeShortPressMove;
            longPressMoveBegan = YES;
            originalPoint = locationInMySpriteSpace;
            [_delegate selectAllPlayersToMove];
        } else if(longPressMoveBegan) {
            if(sender.state == UIGestureRecognizerStateEnded) {
                [_delegate playerPositionChanged: nil];
                longPressMoveBegan = NO;
            } else {
                [_delegate movePlayer: self toPosition:ccpSub(ccpAdd(sender.node.position, locationInMySpriteSpace), originalPoint)];
            }
        }
    }
}

-(void) superLongPressMovePlayer: (UILongPressGestureRecognizer*) sender {
    if(sender.state == UIGestureRecognizerStateBegan) {
        [_delegate superLongPressPlayer:self];
    }
}


-(void) shortPressMovePlayer: (UILongPressGestureRecognizer*) sender {
    CGPoint location = [sender locationInView:sender.view];
    CGPoint locationInWorldSpace = [[CCDirector sharedDirector] convertToGL:location];
    CGPoint locationInMySpriteSpace = [sender.node convertToNodeSpace:locationInWorldSpace];
    
    if(!longPressMoveBegan) {
        if(sender.state == UIGestureRecognizerStateBegan) {
            positionBeforeShortPressMove = sender.node.position;
            wasSetteledBeforeShortPressMove = _settled;
            originalPoint = locationInMySpriteSpace;
            [self setReadyToMove: YES];
        } else if(sender.state == UIGestureRecognizerStateEnded) {
            [_delegate playerPositionChanged: self];
        } else if(!longPressMoveBegan) {
            [_delegate movePlayer: self toPosition:ccpSub(ccpAdd(sender.node.position, locationInMySpriteSpace), originalPoint)];
        }
    }
}

-(void) setReadyToMove:(BOOL)readyToMove {
    _readyToMove = readyToMove;
    if(layerColer) {
        [_sprite removeChild:layerColer];
    }
    if(readyToMove) {
        layerColer = [CCLayerColor layerWithColor:ccc4(0,255,0,255)];
        layerColer.contentSize = CGSizeMake(_sprite.texture.contentSize.width+4, _sprite.texture.contentSize.height+4);
        layerColer.position = ccp(-2, -2);
        [_sprite addChild:layerColer z:-1];
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
