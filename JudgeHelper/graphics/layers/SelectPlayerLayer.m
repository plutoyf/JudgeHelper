//
//  SelectRoleScene.m
//  JudgeHelper
//
//  Created by YANG FAN on 28/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "SelectPlayerLayer.h"

#import "AppDelegate.h"
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

- (void) selectPlayer: (UITapGestureRecognizer*) sender {
    if(isIgnorePresse) return;
    [self selectPlayerById: ((MySprite*)sender.node).id];
}

-(void) selectPlayerById:(NSString*) id {
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
    
    if (selPersonIcon.selected) {
        selPersonIcon.selected = NO;
        [selPersonIcon stopAllActions];
        [selPersonIcon setRotation:0];
        selPersonIcon2.selected = NO;
        [selPersonIcon2 stopAllActions];
        [selPersonIcon2 setRotation:0];
    } else {
        selPersonIcon.selected = YES;
        selPersonIcon2.selected = YES;
        
        [selPersonIcon runAction:[CCRepeatForever actionWithAction:[CCSequence actions: [CCRotateBy actionWithDuration:0.1 angle:-4.0], [CCRotateBy actionWithDuration:0.1 angle:0.0], [CCRotateBy actionWithDuration:0.1 angle:4.0], [CCRotateBy actionWithDuration:0.1 angle:0.0], nil]]];
        [selPersonIcon2 runAction:[CCRepeatForever actionWithAction:[CCSequence actions: [CCRotateBy actionWithDuration:0.1 angle:-4.0], [CCRotateBy actionWithDuration:0.1 angle:0.0], [CCRotateBy actionWithDuration:0.1 angle:4.0], [CCRotateBy actionWithDuration:0.1 angle:0.0], nil]]];

    }
}

BOOL isIgnorePresse = NO;
- (void) shortPressePlayer: (UILongPressGestureRecognizer*) sender {
    if(sender.state == UIGestureRecognizerStateBegan) {
        isIgnorePresse = speed != 0;
    }
}

- (void) longPressePlayer: (UILongPressGestureRecognizer*) sender {
    if(playerToRemove || isIgnorePresse) return;
    
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
            node.position = ccpSub(node.position, ccp(IMG_WIDTH+20, 0));
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


int IMG_WIDTH = 72;
int IMG_HEIGHT = 72;
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        engin = [CCEngin getEngin];
        
        // ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF* titleLabel = [CCLabelTTF labelWithString:@"玩家设定" fontName:@"Marker Felt" fontSize:32];
        titleLabel.position = ccp( titleLabel.boundingBox.size.width/2+20 , size.height-100 );
        [self addChild: titleLabel];
        
        
        CCMenuItem *addPlayerMenuItem = [CCMenuItemImage
                                    itemFromNormalImage:@"add.png" selectedImage:@"add.png"
                                    target:self selector:@selector(addPlayerButtonTapped:)];
        [addPlayerMenuItem setScaleX: IMG_WIDTH/addPlayerMenuItem.contentSize.width];
        [addPlayerMenuItem setScaleY: IMG_HEIGHT/addPlayerMenuItem.contentSize.height];
        
        CCMenu *playerMenu = [CCMenu menuWithItems:addPlayerMenuItem, nil];
        playerMenu.position = ccp(size.width-200, 100);
        [self addChild:playerMenu];
        
        
        nextIcon = [CCSprite spriteWithTexture: [[CCTexture2D alloc] initWithCGImage: [UIImage imageNamed: @"next.png"].CGImage resolutionType: kCCResolutioniPad]];
        nextIcon.position = ccp(size.width-100, 100);
        nextIcon.isTouchEnabled = YES;
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toNextScreen:)];
        [nextIcon addGestureRecognizer:tapGestureRecognizer];
        [self addChild: nextIcon];
        
        
        CCSprite* playersPoolCadre = [[CCSprite alloc] init];
        [playersPoolCadre setContentSize:CGSizeMake(size.width, 100)];
        playersPoolCadre.position = ccp(size.width/2, 170+100/2);
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
    BOOL cycleMode = lastPlayer.position.x+lastPlayer.boundingBox.size.width/2+20 > width;
    
    if(!cycleMode) {
        if(lastPlayer.position.x+lastPlayer.boundingBox.size.width/2+20+newPosition.x < width) {
            newPosition.x = width-lastPlayer.position.x-lastPlayer.boundingBox.size.width/2-20;
        }
        if(newPosition.x > 20) {
            newPosition.x = 20;
        }
        playersPool.position = newPosition;
        playersPool2.position = ccp(width+100, newPosition.y);
    } else {
        playersPool.position = newPosition.x > 20 ? ccp(newPosition.x-lastPlayer.position.x-lastPlayer.boundingBox.size.width/2-20, playersPool.position.y) : newPosition;
        CGPoint position2 = ccp(playersPool.position.x+lastPlayer.position.x+lastPlayer.boundingBox.size.width/2+20, playersPool.position.y);
        if(position2.x < 20) {
            playersPool.position = position2;
        }
        playersPool2.position = ccp(lastPlayer.position.x+lastPlayer.boundingBox.size.width/2+playersPool.position.x+20, playersPool.position.y);
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
    [self setPlayersPoolPosition: ccp(20, 0)];
    
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
    [self setPlayersPoolPosition: ccp(20, 0)];
    CCSprite* lastPlayer = (CCSprite*)[personIcons lastObject];
    CGPoint newPosition = playersPool.position;
    newPosition.x = [[CCDirector sharedDirector] winSize].width-lastPlayer.position.x-lastPlayer.boundingBox.size.width/2-20;
    [self setPlayersPoolPosition: newPosition];

}

-(void) addPlayer: (NSString*) id withName: (NSString*) name andImage: (UIImage*) image forDouble: (BOOL) isDouble {
    if(id.length <= 0 || name.length <= 0) return;
    
    image = [image resizedImage:CGSizeMake(IMG_WIDTH, IMG_HEIGHT) interpolationQuality:kCGInterpolationDefault];
    
    CCTexture2D *texture = [[CCTexture2D alloc] initWithCGImage: image.CGImage resolutionType: kCCResolutioniPad];
    MySprite *icon = [MySprite spriteWithTexture: texture];
    
    MySprite* lastIcon = isDouble ? personIcons2.lastObject : personIcons.lastObject;
    icon.position = ccp(lastIcon ? lastIcon.position.x+IMG_WIDTH+20 : IMG_WIDTH/2, IMG_HEIGHT/2);
    icon.id = id;
    icon.name = name;
    icon.isTouchEnabled = YES;
    [icon showName];
    
    UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPlayer:)];
    tapGestureRecognizer.delegate = self;
    [icon addGestureRecognizer:tapGestureRecognizer];
    UILongPressGestureRecognizer *shortPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shortPressePlayer:)];
    shortPressGestureRecognizer.minimumPressDuration = 0;
    shortPressGestureRecognizer.delegate = self;
    [icon addGestureRecognizer:shortPressGestureRecognizer];
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressePlayer:)];
    [icon addGestureRecognizer:longPressGestureRecognizer];
    longPressGestureRecognizer.delegate = self;
    
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
