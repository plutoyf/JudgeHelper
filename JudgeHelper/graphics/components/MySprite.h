//
//  MySprite.h
//  JudgeHelper
//
//  Created by YANG FAN on 20/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "DeviceSettings.h"
#import "Role.h"

@interface MySprite : CCSprite {
}

@property(nonatomic, retain) NSString* id;
@property(nonatomic, retain) NSString* name;
@property(atomic) Role role;
@property(atomic) BOOL selectable;
@property(atomic) BOOL selected;
@property(nonatomic, retain) CCSprite* deleteButton;
@property(nonatomic, retain) CCSprite* avatar;
@property(nonatomic, retain) CCLabelTTF* label;

-(void) showDeleteButtonWithTarget: (id)target action:(SEL)action;
-(void) removeDeleteButton;
-(void) showName;
-(void) setAvatar:(CCSprite *)avatar;

@end