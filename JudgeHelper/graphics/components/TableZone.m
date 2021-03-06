//
//  TableZone.m
//  JudgeHelper
//
//  Created by fyang on 8/13/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "TableZone.h"

@implementation TableZone

-(id) init:(float) tWidth :(float) tHeight :(float) wWidth :(float) wHeight {
    return [self init:tWidth :tHeight :wWidth :wHeight :200 :200];
}

-(id) init:(float) tWidth :(float) tHeight :(float) wWidth :(float) wHeight :(float) innerMargin :(float) outerMargin {
    if(self = [super init]) {
        siteZone = CGRectMake(wWidth/2-tWidth/2, wHeight/2-tHeight/2, tWidth, tHeight);
        innerZone = CGRectMake(wWidth/2-tWidth/2+innerMargin/2, wHeight/2-tHeight/2+innerMargin/2, tWidth-innerMargin, tHeight-innerMargin);
        outerZone = CGRectMake(wWidth/2-tWidth/2-outerMargin/2, wHeight/2-tHeight/2-outerMargin/2, tWidth+outerMargin, tHeight+outerMargin);
        
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

-(BOOL) is:(float) f around:(float) f0 {
    return f > f0-1 && f < f0+1;
}

-(float) getDistanceFrom: (CGPoint) p0 to: (CGPoint) p1 {
    float d = 0;
    int i = 1;
    while(i > 0) {
        i = 0;
        if([self is:p0.x around:x0]) {
            i++;
            if([self is:p0.x around:p1.x]) {
                d += p1.y-p0.y;
                p0.y = p1.y;
            } else {
                d += y1-p0.y;
                p0.y = y1;
            }
        }
        if([self is:p0.y around:y1]) {
            i++;
            if([self is:p0.y around:p1.y]) {
                d += p1.x-p0.x;
                p0.x = p1.x;
            } else {
                d += x1-p0.x;
                p0.x = x1;
            }
        }
        if([self is:p0.x around:x1]) {
            i++;
            if([self is:p0.x around:p1.x]) {
                d += p0.y-p1.y;
                p0.y = p1.y;
            } else {
                d += p0.y-y0;
                p0.y = y0;
            }
        }
        if([self is:p0.y around:y0]) {
            i++;
            if([self is:p0.y around:p1.y]) {
                d += p0.x-p1.x;
                p0.x = p1.x;
            } else {
                d += p0.x-x0;
                p0.x = x0;
            }
        }
        if([self is:p0.x around:p1.x] && [self is:p0.y around:p1.y]) {
            i = 0;
        }
    }
    
    return (![self is:p0.x around:p1.x] || ![self is:p0.y around:p1.y]) ? 0 : d;
}

-(CGPoint) getPositionFrom: (CGPoint) p0 to: (CGPoint) p1 {
    if(([self is:p0.x around:x0] || [self is:p0.x around:x1]) && ([self is:p0.y around:y0] || [self is:p0.y around:y1])) {
        if(fabsf(p1.x-p0.x)<=fabsf(p1.y-p0.y)) {
            p0.y = p0.y==y1?p0.y-1:p0.y+1;
        } else {
            p0.x = p0.x==x1?p0.x-1:p0.x+1;
        }
    }
    
    if([self is:p0.x around:x0] || [self is:p0.x around:x1]) {
        p1.x = p0.x;
        float dy = p1.y - p0.y;
        if(dy > 0) {
            p1.y = dy<y1-p1.y?p1.y:y1;
        } else {
            p1.y = dy>y0-p1.y?p1.y:y0;
        }
    } else if([self is:p0.y around:y0] || [self is:p0.y around:y1]) {
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

-(CGPoint) getPositionFrom: (CGPoint) p withDistance: (float) d {
    if(![self is:p.x around:x0] && ![self is:p.x around:x1] && ![self is:p.y around:y0] && ![self is:p.y around:y1]) return p;
    
    while (d>0) {
        if ([self is:p.x around:x0]) {
            float delta = y1-p.y<d?y1-p.y:d;
            p.y += delta;
            d -= delta;
        }
        if ([self is:p.y around:y1]) {
            float delta = x1-p.x<d?x1-p.x:d;
            p.x += delta;
            d -= delta;
        }
        if ([self is:p.x around:x1]) {
            float delta = p.y-y0<d?p.y-y0:d;
            p.y -= delta;
            d -= delta;
        }
        if ([self is:p.y around:y0]) {
            float delta = p.x-x0<d?p.x-x0:d;
            p.x -= delta;
            d -= delta;
        }
    }
    
    while (d<0) {
        if ([self is:p.x around:x0]) {
            float delta = y0-p.y>d?y0-p.y:d;
            p.y += delta;
            d -= delta;
        }
        if ([self is:p.y around:y1]) {
            float delta = x0-p.x>d?x0-p.x:d;
            p.x += delta;
            d -= delta;
        }
        if ([self is:p.x around:x1]) {
            float delta = p.y-y1>d?p.y-y1:d;
            p.y -= delta;
            d -= delta;
        }
        if ([self is:p.y around:y0]) {
            float delta = p.x-x1>d?p.x-x1:d;
            p.x -= delta;
            d -= delta;
        }
    }
    return p;
}

-(POSITION) getPlayerPosition: (CGPoint) p {
    if([self is:p.y around:y0]) return BOTTEM;
    if([self is:p.y around:y1]) return TOP;
    if([self is:p.x around:x0]) return LEFT;
    if([self is:p.x around:x1]) return RIGHT;
    return BOTTEM;
}

@end
