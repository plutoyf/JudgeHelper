//
//  SelectRoleScene.m
//  JudgeHelper
//
//  Created by YANG FAN on 28/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "SelectPlayerLayer.h"

#import "AppDelegate.h"
#import "Constants.h"
#import "ClippingSprite.h"
#import "CCNode+SFGestureRecognizers.h"
#import "UIImage+Resize.h"

@implementation SelectPlayerLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SelectPlayerLayer *layer = [SelectPlayerLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) cleanUpSprite: (id) sender {
    [self removeChild:(CCNode*)sender];
}

- (void) selectPlayer: (UITapGestureRecognizer*) sender {
    if(isIgnorePresse) return;
    MySprite* icon = (MySprite*)sender.node;
    [self selectPlayerById: icon.id fromPosition:[icon convertToWorldSpace:ccp(IMG_WIDTH/4, 0)]];
}

-(void) selectPlayerById:(NSString*) id {
    [self selectPlayerById:id fromPosition:ccp(0,0)];
}

-(void) selectPlayerById:(NSString*) id fromPosition: (CGPoint) p0 {
    if(playerToRemove != nil) {
        [playerToRemove stopAllActions];
        [playerToRemove setRotation:0];
        [playerToRemove removeDeleteButton];
        playerToRemove = nil;
        [playerToRemove2 stopAllActions];
        [playerToRemove2 setRotation:0];
        [playerToRemove2 removeDeleteButton];
        playerToRemove2 = nil;

        return;
    }
    
    MySprite* selPersonIcon = [personIconsMap objectForKey:id];
    MySprite* selPersonIcon2 = [personIconsMap2 objectForKey:id];
    
    if(!selPersonIconsMap) {
        selPersonIconsMap = [NSMutableDictionary new];
    }
    
    int numPerLine = 10;
    
    if (selPersonIcon.selected) {
        [self deselectPersonIcon:selPersonIcon];
        [self deselectPersonIcon:selPersonIcon2];
        
        selPersonNumber--;
        MySprite *copyPersonIcon = [selPersonIconsMap objectForKey:selPersonIcon.id];
        [selPersonIconsMap removeObjectForKey:selPersonIcon.id];
        
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.25 position:p0];
        CCCallFuncN *clean = [CCCallFuncN actionWithTarget:self selector:@selector(cleanUpSprite:)];
        [copyPersonIcon runAction:[CCSequence actions:move, clean, nil]];
        
        for(MySprite* personIcon in selPersonIconsMap.allValues) {
            if(personIcon.position.y<copyPersonIcon.position.y || (personIcon.position.y==copyPersonIcon.position.y && personIcon.position.x>copyPersonIcon.position.x)) {
                if(personIcon.position.x == REVERSE_X(60)) {
                    CCMoveTo *move1 = [CCMoveTo actionWithDuration:0.1 position:ccp(REVERSE_X(60+100*numPerLine), personIcon.position.y+REVERSE_Y(100))];
                    CCMoveTo *move2 = [CCMoveTo actionWithDuration:0.15 position:ccp(REVERSE_X(60+100*(numPerLine-1)), personIcon.position.y+REVERSE_Y(100))];
                    [personIcon runAction:[CCSequence actions:move1, move2, nil]];
                } else {
                    CCMoveTo *move = [CCMoveTo actionWithDuration:0.25 position:ccp(personIcon.position.x-REVERSE_X(100), personIcon.position.y)];
                    [personIcon runAction:[CCSequence actions:move, nil]];
                }
            }
        }
        
    } else {
        [self selectPersonIcon:selPersonIcon];
        [self selectPersonIcon:selPersonIcon2];
                
        MySprite *copyPersonIcon = [MySprite new];
        copyPersonIcon.id = selPersonIcon.id;
        copyPersonIcon.name = selPersonIcon.name;
        [copyPersonIcon showName];
        copyPersonIcon.avatar = [MySprite spriteWithTexture:selPersonIcon.avatar.texture];
        
        BOOL hasP0 = p0.x!=0 || p0.y!=0;
        CGPoint p1 = ccp(REVERSE_X(60)+REVERSE_X(100)*(selPersonNumber%numPerLine), REVERSE_Y(570)-REVERSE_Y(100)*(int)(selPersonNumber/numPerLine));
        copyPersonIcon.position = hasP0?p0:p1;
        
        [selPersonIconsMap setObject:copyPersonIcon forKey:copyPersonIcon.id];
        [self addChild:copyPersonIcon];
        
        if(hasP0) {
            CCMoveTo *move = [CCMoveTo actionWithDuration:0.25 position:p1];
            [copyPersonIcon runAction:[CCSequence actions:move, nil]];
        }
        
        selPersonNumber++;
    }
}


-(void) selectPersonIcon: (MySprite*) personIcon {
    personIcon.selected = YES;
    personIcon.avatar.opacity = 100;
    //[personIcon runAction:[CCRepeatForever actionWithAction:[CCSequence actions: [CCRotateBy actionWithDuration:0.1 angle:-4.0], [CCRotateBy actionWithDuration:0.1 angle:0.0], [CCRotateBy actionWithDuration:0.1 angle:4.0], [CCRotateBy actionWithDuration:0.1 angle:0.0], nil]]];
}

-(void) deselectPersonIcon: (MySprite*) personIcon {
    personIcon.selected = NO;
    personIcon.avatar.opacity = 255;
    //[personIcon stopAllActions];
    //[personIcon setRotation:0];
}

- (void) shortPressePlayer: (UILongPressGestureRecognizer*) sender {
    if(sender.state == UIGestureRecognizerStateBegan) {
        isIgnorePresse = speed != 0;
    }
}

- (void) longPressePlayer: (UILongPressGestureRecognizer*) sender {
    if(playerToRemove || isIgnorePresse || ((MySprite*)sender.node.parent).selected) return;
    
    NSString* id = ((MySprite*)sender.node).id;
    playerToRemove = [personIconsMap objectForKey:id];
    playerToRemove2 = [personIconsMap2 objectForKey:id];
    
    [playerToRemove showDeleteButtonWithTarget:self action:@selector(removePlayer:)];
    [playerToRemove2 showDeleteButtonWithTarget:self action:@selector(removePlayer:)];
    
    [playerToRemove runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCRotateBy actionWithDuration:0.05 angle:-4.0], [CCRotateBy actionWithDuration:0.05 angle:4.0], [CCRotateBy actionWithDuration:0.05 angle:4.0], [CCRotateBy actionWithDuration:0.05 angle:-4.0], nil]]];
    [playerToRemove2 runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCRotateBy actionWithDuration:0.05 angle:-4.0], [CCRotateBy actionWithDuration:0.05 angle:4.0], [CCRotateBy actionWithDuration:0.05 angle:4.0], [CCRotateBy actionWithDuration:0.05 angle:-4.0], nil]]];
}


- (void) removePlayer: (UITapGestureRecognizer*) sender {
    if(playerToRemove != nil) {
        // stop animation
        [playerToRemove stopAllActions];
        [playerToRemove setRotation: 0.0f];
        [playerToRemove2 stopAllActions];
        [playerToRemove2 setRotation: 0.0f];
        
        // remove from system storage
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        [pids removeObject:playerToRemove.id];
        [userDefaults setObject:pids forKey:pidsKey];
        [userDefaults removeObjectForKey:[playerToRemove.id stringByAppendingString:@"-name"]];
        [userDefaults removeObjectForKey:[playerToRemove.id stringByAppendingString:@"-img"]];
        [userDefaults synchronize];
        
        //remove from local cache
        int i = [personIcons indexOfObject:playerToRemove];
        [personIcons removeObject:playerToRemove];
        [personIcons2 removeObject:playerToRemove2];
        [personIconsMap removeObjectForKey:playerToRemove.id];
        [personIconsMap2 removeObjectForKey:playerToRemove.id];
        
        // remove from playesPool
        [playersPool removeChild:playerToRemove];
        [playersPool2 removeChild:playerToRemove2];
        
        // sort playersPool
        for(; i < personIcons.count; i++) {
            CCSprite* node = [personIcons objectAtIndex:i];
            node.position = ccpSub(node.position, REVERSE_XY(IMG_WIDTH+20, 0));
            ((CCSprite*)[personIcons2 objectAtIndex:i]).position = node.position;

        }
        [self setPlayersPoolPosition: playersPool.position];
        
        playerToRemove = nil;
        playerToRemove2 = nil;
    }
    
}

- (void) toNextScreen : (id) sender {
    // init players
    NSArray* playerIds = [self getSelectedPlayerIds];
    if(playerIds.count >= 2) {
        GlobalSettings* global = [GlobalSettings globalSettings];
        [global setPlayerIds: playerIds];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[SelectRoleLayer scene] ]];
    }
}

CreatePlayerLayer* createPlayerLayer;
-(void) showCreatePlayerScreen {
    if(createPlayerLayer) {
        [self removeChild:createPlayerLayer];
    }
    
    createPlayerLayer = [[CreatePlayerLayer alloc] init];
    createPlayerLayer.delegate = self;
    [self addChild:createPlayerLayer];
}


-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        isIgnorePresse = NO;
        selPersonNumber = 0;
        engin = [CCEngin getEngin];
        
        // ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF* titleLabel = [CCLabelTTF labelWithString:@"玩家设定" fontName:@"Marker Felt" fontSize:REVERSE_Y(32)];
        titleLabel.position = ccp( titleLabel.boundingBox.size.width/2+REVERSE_X(20) , size.height-REVERSE_Y(100) );
        [self addChild: titleLabel];
        
        
        CCMenuItem *addPlayerMenuItem = [CCMenuItemImage itemFromNormalImage:@"add.png" selectedImage:@"add-sel.png" target:self selector:@selector(addPlayerButtonTapped:)];
        [addPlayerMenuItem setScaleX: IMG_WIDTH/addPlayerMenuItem.contentSize.width];
        [addPlayerMenuItem setScaleY: IMG_HEIGHT/addPlayerMenuItem.contentSize.height];
        CCMenu *playerMenu = [CCMenu menuWithItems:addPlayerMenuItem, nil];
        playerMenu.position = ccp(size.width-REVERSE_X(200), REVERSE_Y(100));
        [self addChild:playerMenu];
        
        CCMenuItem *nextMenuItem = [CCMenuItemImage itemFromNormalImage:@"next.png" selectedImage:@"next-sel.png" target:self selector:@selector(toNextScreen:)];
        [nextMenuItem setScaleX: IMG_WIDTH/nextMenuItem.contentSize.width];
        [nextMenuItem setScaleY: IMG_HEIGHT/nextMenuItem.contentSize.height];
        nextMenu = [CCMenu menuWithItems:nextMenuItem, nil];
        nextMenu.position = ccp(size.width-REVERSE_X(100), REVERSE_Y(100));
        [self addChild:nextMenu];
        
        playersPoolCadre = [[CCSprite alloc] init];
        [playersPoolCadre setContentSize:CGSizeMake(size.width, REVERSE_Y(100))];
        playersPoolCadre.position = ccp(size.width/2, REVERSE_Y(170+100/2));
        playersPoolCadre.isTouchEnabled = YES;
        UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePlayersByPanGesture:)];
        panGestureRecognizer.delegate = self;
        [playersPoolCadre addGestureRecognizer:panGestureRecognizer];

        
        playersPool = [[CCSprite alloc] init];
        playersPool.position = ccp(0, 0);
        [playersPoolCadre addChild:playersPool];
        playersPool2 = [[CCSprite alloc] init];
        playersPool2.position = ccp(0, 0);
        [playersPoolCadre addChild:playersPool2];
        
        [self addChild:playersPoolCadre];
        [self initPlayers];
    }
    [self scheduleUpdate];
	return self;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

float speed = 0;
-(void) update:(ccTime)delta {
    if(fabs(speed) > 1) {
        CGPoint newPosition = ccpAdd(playersPool.position, ccp(speed, 0));
        speed *= fabs(speed)<10 ? 0.9 : 0.92;
        [self setPlayersPoolPosition: newPosition];
    } else {
        speed = 0;
    }
}


CreatePlayerLayer* createPlayerLayer;
-(void) addPlayerButtonTapped: (id) sender {
    //createPlayerLayer = [[CreatePlayerLayer alloc] init];
    //[self addChild:createPlayerLayer];
    [self showCreatePlayerScreen];
}

-(void) setPlayersPoolPosition : (CGPoint) newPosition {
    newPosition.y = playersPool.position.y;
    CCNode* lastPlayer = [personIcons lastObject];
    float width = [[CCDirector sharedDirector] winSize].width;
    BOOL cycleMode = lastPlayer.position.x+AVATAR_IMG_WIDTH/2+REVERSE_X(20) > width;
    
    if(!cycleMode) {
        if(lastPlayer.position.x+AVATAR_IMG_WIDTH/2+REVERSE_X(20)+newPosition.x < width) {
            newPosition.x = width-lastPlayer.position.x-AVATAR_IMG_WIDTH/2-REVERSE_X(20);
        }
        if(newPosition.x > REVERSE_X(20)) {
            newPosition.x = REVERSE_X(20);
        }
        playersPool.position = newPosition;
        playersPool2.position = ccp(width+REVERSE_X(100), newPosition.y);
    } else {
        playersPool.position = newPosition.x > REVERSE_X(20) ? ccp(newPosition.x-lastPlayer.position.x-AVATAR_IMG_WIDTH/2-REVERSE_X(20), playersPool.position.y) : newPosition;
        CGPoint position2 = ccp(playersPool.position.x+lastPlayer.position.x+AVATAR_IMG_WIDTH/2+REVERSE_X(20), playersPool.position.y);
        if(position2.x < REVERSE_X(20)) {
            playersPool.position = position2;
        }
        playersPool2.position = ccp(lastPlayer.position.x+AVATAR_IMG_WIDTH/2+playersPool.position.x+REVERSE_X(20), playersPool.position.y);
    }
}

CGPoint originalPoint;
-(void) movePlayersByPanGesture: (UIPanGestureRecognizer*) sender {
    CGPoint location = [sender locationInView:sender.view];
    CGPoint locationInWorldSpace = [[CCDirector sharedDirector] convertToGL:location];
    CGPoint locationInMySpriteSpace = [playersPool convertToNodeSpace:locationInWorldSpace];
    
    if(sender.state == UIGestureRecognizerStateBegan) {
        originalPoint = locationInMySpriteSpace;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [sender velocityInView:sender.view.superview];
        //NSLog(@"Velocity %f, %f", velocity.x, velocity.y);
        speed = fabs(velocity.x)>1000 ? velocity.x/50 : 0;
    } else {
        CGPoint newPosition = ccpSub(ccpAdd(playersPool.position, locationInMySpriteSpace), originalPoint);
        [self setPlayersPoolPosition: newPosition];
    }
}

- (void)handlePlayersPoolPanGesture:(UIPanGestureRecognizer*)aPanGestureRecognizer {
    CGPoint translation = [aPanGestureRecognizer translationInView:aPanGestureRecognizer.view];
    translation.y *= -1;
    [aPanGestureRecognizer setTranslation:CGPointZero inView:aPanGestureRecognizer.view];
}


NSString * const pidsKey = @"pids";
NSMutableArray* pids;
-(void) initPlayers {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    id obj = [userDefaults objectForKey:pidsKey];
    pids = obj==nil ? [NSMutableArray new] : [NSMutableArray arrayWithArray:obj];
    
    GlobalSettings* global = [GlobalSettings globalSettings];
    NSArray* selPlayerIds = [global getPlayerIds];
    
    personIcons = [NSMutableArray new];
    personIcons2 = [NSMutableArray new];
    personIconsMap = [NSMutableDictionary new];
    personIconsMap2 = [NSMutableDictionary new];
    for(NSString* id in pids) {
        NSString* name = [userDefaults stringForKey:[id stringByAppendingString:@"-name"]];
        NSData* imgData = [userDefaults dataForKey:[id stringByAppendingString:@"-img"]];
        UIImage* image = [UIImage imageWithData:imgData];
        [self addPlayer:id withName:name andImage:image forDouble:NO];
        [self addPlayer:id withName:name andImage:image forDouble:YES];
        if([selPlayerIds containsObject:id]) {
            [self selectPlayerById: id];
        }
    }
    [self setPlayersPoolPosition: ccp(REVERSE_X(20), 0)];
    
}

-(void) createPlayer: (NSString*) name withImage: (UIImage*) image {
    if(name.length <= 0) return;    
    //1. save player's info
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* id = [NSNumber numberWithLong: (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970])].stringValue;
    [pids addObject:id];
    [userDefaults setObject:pids forKey:pidsKey];
    [userDefaults setObject:name forKey:[id stringByAppendingString:@"-name"]];
    [userDefaults setObject:UIImagePNGRepresentation(image) forKey:[id stringByAppendingString:@"-img"]];
    [userDefaults synchronize];
    
    //2. show player in the list
    [self addPlayer:id withName:name andImage:image forDouble:NO];
    [self addPlayer:id withName:name andImage:image forDouble:YES];
    [self setPlayersPoolPosition: ccp(REVERSE_X(20), 0)];
    CCSprite* lastPlayer = (CCSprite*)[personIcons lastObject];
    CGPoint newPosition = playersPool.position;
    newPosition.x = [[CCDirector sharedDirector] winSize].width-lastPlayer.position.x-AVATAR_IMG_WIDTH/2-REVERSE_X(20);
    [self setPlayersPoolPosition: newPosition];

}

-(void) addPlayer: (NSString*) id withName: (NSString*) name andImage: (UIImage*) image forDouble: (BOOL) isDouble {
    if(id.length <= 0 || name.length <= 0) return;
    
    MySprite *icon = [MySprite new];
    MySprite* lastIcon = isDouble ? personIcons2.lastObject : personIcons.lastObject;
    icon.position = ccp(lastIcon ? lastIcon.position.x+IMG_WIDTH+REVERSE_X(20) : IMG_WIDTH/2, IMG_HEIGHT/2);
    icon.id = id;
    icon.name = name;
    [icon showName];
    
    image = [image resizedImage:CGSizeMake(IMG_WIDTH, IMG_HEIGHT) interpolationQuality:kCGInterpolationDefault];
    CCTexture2D *texture = [[CCTexture2D alloc] initWithCGImage: image.CGImage resolutionType: kCCResolutioniPad];
    MySprite *avatar = [MySprite spriteWithTexture: texture];
    avatar.id = id;
    avatar.name = name;
    icon.avatar = avatar;
    
    avatar.isTouchEnabled = YES;
    UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPlayer:)];
    tapGestureRecognizer.delegate = self;
    [avatar addGestureRecognizer:tapGestureRecognizer];
    UILongPressGestureRecognizer *shortPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shortPressePlayer:)];
    shortPressGestureRecognizer.minimumPressDuration = 0;
    shortPressGestureRecognizer.delegate = self;
    [avatar addGestureRecognizer:shortPressGestureRecognizer];
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressePlayer:)];
    longPressGestureRecognizer.minimumPressDuration = 0.6;
    [avatar addGestureRecognizer:longPressGestureRecognizer];
    longPressGestureRecognizer.delegate = self;
    
    [tapGestureRecognizer requireGestureRecognizerToFail:longPressGestureRecognizer];
    
    if(isDouble) {
        [playersPool2 addChild: icon];
        [personIcons2 addObject:icon];
        [personIconsMap2 setObject:icon forKey:icon.id];
    } else {
        [playersPool addChild: icon];
        [personIcons addObject:icon];
        [personIconsMap setObject:icon forKey:icon.id];
    }
}

-(NSArray*) getSelectedPlayerIds {
    NSMutableArray* ids = [NSMutableArray new];
    for (MySprite *p in personIcons) {
        if (p.selected) {
            [ids addObject:p.id];
        }
    }
        
    return ids;
}


#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
