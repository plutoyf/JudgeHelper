//
//  UIDoubleHandPlayer.h
//  JudgeHelper
//
//  Created by YANG FAN on 26/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "UIHandPlayer.h"

@interface UIDoubleHandPlayer : UIPlayer
{
}

@property (nonatomic, strong) UIHandPlayer* leftHandPlayer;
@property (nonatomic, strong) UIHandPlayer* rightHandPlayer;

-(void) setLeftHandPlayer:(UIHandPlayer*) leftHandPlayer;
-(void) setRightHandPlayer:(UIHandPlayer*) rightHandPlayer;

@end
