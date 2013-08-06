//
//  MySprite.m
//  JudgeHelper
//
//  Created by YANG FAN on 20/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

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
        _deleteButton.position = ccp(0, self.boundingBox.size.height);
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
        CCLabelTTF* labelTTF = [CCLabelTTF labelWithString:_name fontName:@"Marker Felt" fontSize:14];
        labelTTF.position = ccp(self.boundingBox.size.width/2, -14);
        [self addChild: labelTTF];
    }
}

@end