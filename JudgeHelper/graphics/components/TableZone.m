//
//  TableZone.m
//  JudgeHelper
//
//  Created by fyang on 8/13/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "TableZone.h"

@implementation TableZone

-(id) init: (float) width : (float) height {
    if(self = [super init]) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        float innerMargin = 200, outerMargin = 200;
        siteZone = CGRectMake(size.width/2-width/2, size.height/2-height/2, width, height);
        innerZone = CGRectMake(size.width/2-width/2+innerMargin/2, size.height/2-height/2+innerMargin/2, width-innerMargin, height-innerMargin);
        outerZone = CGRectMake(size.width/2-width/2-outerMargin/2, size.height/2-height/2-outerMargin/2, width+outerMargin, height+outerMargin);
        
        w = siteZone.size.width;
        h = siteZone.size.height;
        x = siteZone.origin.x+w/2;
        y = siteZone.origin.y+h/2;
        x0 = x-w/2;
        x1 = x+w/2;
        y0 = y-h/2;
        y1 = y+h/2;

    }
    return self;
}

-(BOOL) isInside: (CGPoint) p {
    BOOL isInOuterZone = CGRectContainsPoint(outerZone, p);
    BOOL isInInnterZone = CGRectContainsPoint(innerZone, p);
    return isInOuterZone && !isInInnterZone;
}

-(CGPoint) getBestPosition: (CGPoint) p {
    float dt = fabsf(y1-p.y), db = fabsf(y0-p.y), dr = fabsf(x1-p.x), dl = fabsf(x0-p.x);
    
    int s = 1;
    float min = dt;
    if(dr < min) {
        s = 2;
        min = dr;
    } else if(dr == min) {
        s += 2;
    }
    if(db < min) {
        s = 4;
        min = db;
    } else if(db == min) {
        s += 4;
    }
    if(dl < min) {
        s = 8;
        min = dl;
    } else if(dl == min) {
        s += 8;
    }
    
    CGPoint p1 = p;
    if(s == 1 || s == 2 || s == 4 || s == 8) {
        p1.x = s==2?x1:s==8?x0:p.x<x0?x0:p.x>x1?x1:p.x;
        p1.y = s==1?y1:s==4?y0:p.y<y0?y0:p.y>y1?y1:p.y;
    } else if(s == 3 || s == 6 || s == 9 || s == 12) {
        p1.x = (s==3 || s==6)?x1:x0;
        p1.y = (s==3 || s==9)?y1:y0;
    }
    
    return p1;
}

-(CGPoint) getPositionFrom: (CGPoint) p0 to: (CGPoint) p1 {
    if((p0.x==x0 || p0.x==x1) && (p0.y==y0 || p0.y==y1)) {
        if(fabsf(p1.x-p0.x)<=fabsf(p1.y-p0.y)) {
            p0.y = p0.y==y1?p0.y-1:p0.y+1;
        } else {
            p0.x = p0.x==x1?p0.x-1:p0.x+1;
        }
    }
    
    if(p0.x==x0 || p0.x==x1) {
        p1.x = p0.x;
        float dy = p1.y - p0.y;
        if(dy > 0) {
            p1.y = dy<y1-p1.y?p1.y:y1;
        } else {
            p1.y = dy>y0-p1.y?p1.y:y0;
        }
    } else if(p0.y==y0 || p0.y==y1) {
        p1.y = p0.y;
        float dx = p1.x - p0.x;
        if(dx > 0) {
            p1.x = dx<x1-p1.x?p1.x:x1;
        } else {
            p1.x = dx>x0-p1.x?p1.x:x0;
        }
    }
    
    return p1;
}

@end
