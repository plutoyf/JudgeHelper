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

-(void) addNewStatusWithActorRole: (Role) role andReceiver: (Player*) receiver andResult: (BOOL) result;
-(void) revertStatus;
@end
