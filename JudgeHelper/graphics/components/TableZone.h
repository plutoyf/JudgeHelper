//
//  TableZone.h
//  JudgeHelper
//
//  Created by fyang on 8/13/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableZone : NSObject
{
    CGRect outerZone;
    CGRect innerZone;
    CGRect siteZone;
    float w, h, x, y, x0, x1, y0, y1;
}

-(id) init: (float) width : (float) height;
-(BOOL) isInside: (CGPoint) p;
-(CGPoint) getBestPosition: (CGPoint) p;
-(CGPoint) getPositionFrom: (CGPoint) p0 to: (CGPoint) p1;

@end
