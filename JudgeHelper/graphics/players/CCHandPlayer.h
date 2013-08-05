//
//  CCHandPlayer.h
//  JudgeHelper
//
//  Created by fyang on 8/1/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "CCPlayer.h"

typedef enum {
    LEFTHAND = 0, RIGHTHAND = 1
} Hand;

@interface CCHandPlayer : CCPlayer
{
    CCSprite* handIcon;
}

@property (atomic) Hand* hand;
@property (nonatomic, strong) CCPlayer* player;

@end
