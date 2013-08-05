//
//  GameStateSprite.m
//  JudgeHelper
//
//  Created by fyang on 8/2/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "GameStateSprite.h"

@implementation GameStateSprite

-(id) init {
    if(self = [super init]) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        GLubyte *buffer = malloc(sizeof(GLubyte)*4);
        for (int i=0;i<4;i++) {buffer[i]=255;}
        CCTexture2D *tex = [[CCTexture2D alloc] initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_RGB5A1 pixelsWide:1 pixelsHigh:1 contentSize:size];
        [self setTexture:tex];
        [self setTextureRect:CGRectMake(0, 0, size.width, size.height)];
        free(buffer);
        
        _position = ccp(size.width/2*3-0, size.height/2);
    }
    
    return self;
}
@end
