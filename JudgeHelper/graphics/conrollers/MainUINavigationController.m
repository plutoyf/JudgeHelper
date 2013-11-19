//
//  MainUINavigationController.m
//  JudgeHelper
//
//  Created by fyang on 19/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "MainUINavigationController.h"

@implementation MainUINavigationController

-(BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

@end
