//
//  MySprite.h
//  JudgeHelper
//
//  Created by YANG FAN on 20/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySprite : CCSprite {
}

@property(nonatomic, retain) NSString* name;
@property(atomic) BOOL selectable;
@property(atomic) BOOL selected;

@end