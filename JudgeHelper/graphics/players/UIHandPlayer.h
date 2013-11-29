//
//  UIHandPlayer.h
//  JudgeHelper
//
//  Created by YANG FAN on 26/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlayer.h"

typedef enum {
    LEFTHAND = 0, RIGHTHAND = 1
} Hand;

@interface UIHandPlayer : UIPlayer
{
    UIImageView* handIcon;
}

@property (atomic) Hand* hand;
@property (nonatomic, strong) UIPlayer* player;

@end
