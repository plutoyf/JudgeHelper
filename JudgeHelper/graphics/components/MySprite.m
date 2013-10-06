//
//  MySprite.m
//  JudgeHelper
//
//  Created by YANG FAN on 20/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "Constants.h"
#import "MySprite.h"
#import "CCNode+SFGestureRecognizers.h"

@implementation MySprite


-(id)init {
    if(self = [super init]) {
    }
    return self;
}

-(void) showDeleteButtonWithTarget: (id)target action:(SEL)action {
    if(_deleteButton == nil) {
        _deleteButton = [CCSprite spriteWithFile:@"delete_mini.png"];
        [_deleteButton setScaleX: REVERSE_X(30)/_deleteButton.contentSize.width];
        [_deleteButton setScaleY: REVERSE_X(30)/_deleteButton.contentSize.height];
        _deleteButton.position = ccp(-AVATAR_IMG_WIDTH/2, AVATAR_IMG_HEIGHT);
        _deleteButton.isTouchEnabled = YES;
        
        UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [_deleteButton addGestureRecognizer:tapGestureRecognizer];
        
        [self addChild:_deleteButton];
    }
}

-(void) removeDeleteButton {
    if(_deleteButton != nil) {
        [self removeChild:_deleteButton];
        _deleteButton = nil;
    }
}

-(void) showName {
    if(_name) {
        CCLabelTTF* labelTTF = [CCLabelTTF labelWithString:_name fontName:@"Marker Felt" fontSize:VALUE(16, 12)];
        labelTTF.position = ccp(self.boundingBox.size.width/2, -VALUE(14, 10));
        [self addChild: labelTTF];
    }
}


-(void) setAvatar:(CCSprite *)avatar {
    _avatar = avatar;
    [_avatar setScaleX: AVATAR_IMG_WIDTH/avatar.contentSize.width];
    [_avatar setScaleY: AVATAR_IMG_HEIGHT/avatar.contentSize.height];
    _avatar.position = ccp(0, AVATAR_IMG_HEIGHT/2);
    [self addChild:_avatar];
}

@end