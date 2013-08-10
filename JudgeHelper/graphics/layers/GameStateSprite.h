//
//  GameStateSprite.h
//  JudgeHelper
//
//  Created by fyang on 8/2/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "CCEngin.h"

@interface GameStateSprite : CCSprite
{
    CCEngin* engin;
}

-(void) addNewStatus;
-(void) revertStatus;
@end
