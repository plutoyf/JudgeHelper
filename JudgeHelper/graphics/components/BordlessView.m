//
//  BordlessView.m
//  JudgeHelper
//
//  Created by fyang on 28/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "BordlessView.h"

@implementation BordlessView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for(UIView *subview in self.subviews)
    {
        UIView *view = [subview hitTest:[self convertPoint:point toView:subview] withEvent:event];
        if(view) return view;
    }
    return [super hitTest:point withEvent:event];
}

@end
