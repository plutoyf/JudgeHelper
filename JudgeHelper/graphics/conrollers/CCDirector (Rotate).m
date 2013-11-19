//
//  CCDirector.m
//  JudgeHelper
//
//  Created by fyang on 19/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "CCDirector.h"

@implementation CCDirector (Rotate)

-(BOOL)shouldAutorotate
{
    NSLog(@"CCDirector :shouldAutorotate ");
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    NSLog(@"CCDirector :supportedInterfaceOrientations ");
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    NSLog(@"CCDirector :preferredInterfaceOrientationForPresentation ");
    return UIInterfaceOrientationLandscapeLeft;
}

@end
