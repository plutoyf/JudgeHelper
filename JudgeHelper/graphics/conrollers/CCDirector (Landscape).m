//
//  CCDirector.m
//  JudgeHelper
//
//  Created by fyang on 21/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "CCDirector (Landscape).h"

@implementation CCDirector (Landscape)

-(CGSize) winSizeInLandscape {
    CGSize size = _winSizeInPoints;
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if( interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        CGFloat v = size.height;
        size.height = size.width;
        size.width = v;
    }
    
    return size;
}


-(CGSize)winSize
{
	return [self winSizeInLandscape];
}

@end
