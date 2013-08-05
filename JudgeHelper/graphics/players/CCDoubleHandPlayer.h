//
//  CCDoubleHandPlayer.h
//  JudgeHelper
//
//  Created by fyang on 8/1/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "CCHandPlayer.h"

@interface CCDoubleHandPlayer : CCPlayer
{
}

@property (nonatomic, strong) CCHandPlayer* leftHandPlayer;
@property (nonatomic, strong) CCHandPlayer* rightHandPlayer;

-(void) setLeftHandPlayer:(CCHandPlayer*) leftHandPlayer;
-(void) setRightHandPlayer:(CCHandPlayer*) rightHandPlayer;

@end
