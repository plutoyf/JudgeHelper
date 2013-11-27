//
//  TableZone.h
//  JudgeHelper
//
//  Created by fyang on 8/13/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "CCPlayer.h"

@interface TableZone : NSObject
{
    CGRect outerZone;
    CGRect innerZone;
    CGRect siteZone;
    float w, h, x, y, x0, x1, y0, y1;
}

-(id) init:(float) tWidth :(float) tHeight :(float) wWidth :(float) wHeight;
-(id) init:(float) tWidth :(float) tHeight :(float) wWidth :(float) wHeight :(float) innerMargin :(float) outerMargin;
-(BOOL) isInside: (CGPoint) p;
-(CGPoint) getBestPosition: (CGPoint) p;
-(float) getDistanceFrom: (CGPoint) p0 to: (CGPoint) p1;
-(CGPoint) getPositionFrom: (CGPoint) p0 to: (CGPoint) p1;
-(CGPoint) getPositionFrom: (CGPoint) p withDistance: (float) d;
-(POSITION) getPlayerPosition: (CGPoint) p;

@end
