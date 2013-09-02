//
//  ClippingSprite.h
//  JudgeHelper
//
//  Created by YANG FAN on 03/08/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "CCSprite.h"

@interface ClippingSprite : CCSprite

@property (atomic) CGRect openWindowRect;

-(void) clip;

@end
