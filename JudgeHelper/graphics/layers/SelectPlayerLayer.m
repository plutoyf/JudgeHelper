//
//  SelectRoleScene.m
//  JudgeHelper
//
//  Created by YANG FAN on 28/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "SelectPlayerLayer.h"

#import "AppDelegate.h"
#import "CCEngin.h"
#import "MySprite.h"
#import "GlobalSettings.h"
#import "SelectRoleLayer.h"
#import "CreatePlayerLayer.h"
#import "CCDoubleHandPlayer.h"
#import "GameLayer.h"
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
    [self selectPlayerByNode: (MySprite*)sender.node];
}

-(void) selectPlayerByNode:(MySprite*) node {
    if(playerToRemove != nil) {
        [playerToRemove stopAllActions];
        [playerToRemove setRotation:0];
        [playerToRemove removeDeleteButton];
        playerToRemove = nil;
        return;
    }
    
    selPersonIcon = node;
    
    if (selPersonIcon.selected) {
        selPersonIcon.selected = NO;
        [selPersonIcon stopAllActions];
        [selPersonIcon setRotation:0];
    } else {
        selPersonIcon.selected = YES;
        CCRotateTo * rotLeft = [CCRotateBy actionWithDuration:0.1 angle:-4.0];
        CCRotateTo * rotCenter = [CCRotateBy actionWithDuration:0.1 angle:0.0];
        CCRotateTo * rotRight = [CCRotateBy actionWithDuration:0.1 angle:4.0];
        CCSequence * rotSeq = [CCSequence actions:rotLeft, rotCenter, rotRight, rotCenter, nil];
        CCRepeatForever* action = [CCRepeatForever actionWithAction:rotSeq];
        [selPersonIcon runAction:action];
    }
}

MySprite* playerToRemove;
- (void) longPressePlayer: (UILongPressGestureRecognizer*) sender {
    if(playerToRemove) return;
    
    playerToRemove = (MySprite*)sender.node;
    
    [playerToRemove showDeleteButtonWithTarget:self action:@selector(removePlayer:)];
    
    CCRotateTo * rotLeft = [CCRotateBy actionWithDuration:0.05 angle:-4.0];
    CCRotateTo * rotCenter = [CCRotateBy actionWithDuration:0.05 angle:4.0];
    CCRotateTo * rotRight = [CCRotateBy actionWithDuration:0.05 angle:4.0];
    CCRotateTo * rotCenter2 = [CCRotateBy actionWithDuration:0.05 angle:-4.0];
    CCSequence * rotSeq = [CCSequence actions:rotLeft, rotCenter, rotRight, rotCenter2, nil];
    [playerToRemove runAction:[CCRepeatForever actionWithAction:rotSeq]];
}


- (void) removePlayer: (UITapGestureRecognizer*) sender {
    if(playerToRemove != nil) {
        // stop animation
        [playerToRemove stopAllActions];
        [playerToRemove setRotation: 0.0f];
        
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
        [personIconsMap removeObjectForKey:playerToRemove.id];
        
        // remove from playesPool
        [playersPool removeChild:playerToRemove];
        
        // sort playersPool
        for(; i < personIcons.count; i++) {
            CCSprite* node = [personIcons objectAtIndex:i];
            node.position = ccpSub(node.position, ccp(IMG_WIDTH+20, 0));
        }
        [self setPlayersPoolPosition: playersPool.position];
        
        playerToRemove = nil;
    }
    
}

- (void) toNextScreen : (id) sender {
    // init players
    NSArray* playerIds = [self getSelectedPlayerIds];
    if(playerIds.count >= 2) {
        GlobalSettings* global = [GlobalSettings globalSettings];
        [global setPlayerIds: playerIds];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[SelectRoleLayer scene] ]];
    }
}

CreatePlayerLayer* createPlayerLayer;
-(void) showCreatePlayerScreen {
    createPlayerLayer = [[CreatePlayerLayer alloc] init];
    createPlayerLayer.delegate = self;
    [self addChild:createPlayerLayer];
}

CCEngin* engin;
CCSprite* nextIcon;
MySprite* selPersonIcon;
CCSprite* playersPool;
NSMutableArray* persons;
NSMutableArray* personNames;
NSMutableArray* personIcons;
NSMutableDictionary* personIconsMap;
int IMG_WIDTH = 72;
int IMG_HEIGHT = 72;
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        //persons = [NSMutableArray arrayWithObjects:@"yangfan", @"yangwen", @"zhengzhong", @"duwenwen", @"xiewei", @"yuanchenjun", @"zhangwen", @"lizheng", @"qinfeng", @"qiaoqing", @"qiaozhe", @"chenweijia", nil];
        //personNames = [NSMutableArray arrayWithObjects:@"杨帆", @"杨雯", @"郑重", @"杜雯雯", @"谢维", @"袁辰君", @"张雯", @"李政", @"覃枫", @"乔青", @"乔哲", @"陈伟嘉", nil];
        
		engin = [CCEngin getEngin];
        
        // ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF* messageLabel = [CCLabelTTF labelWithString:@"玩家设定" fontName:@"Marker Felt" fontSize:32];
        messageLabel.position = ccp( 100 , size.height-100 );
		messageLabel.tag = 13;
        [self addChild: messageLabel];
        
        
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
        tapGestureRecognizer.delegate = self;
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
        //[playersPool setContentSize:CGSizeMake(size.width-200, 100)];
        //playersPool.openWindowRect = CGRectMake(50-20, 0, (IMG_WIDTH+20)*9+20, 400);
        playersPool.position = ccp(0, 0);
        [playersPoolCadre addChild:playersPool];
        

        
        [self addChild:playersPoolCadre];
        [self initPlayers];
    }
    
	return self;
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
    if(lastPlayer.position.x+lastPlayer.boundingBox.size.width/2+20+newPosition.x < [[CCDirector sharedDirector] winSize].width) {
        newPosition.x = [[CCDirector sharedDirector] winSize].width-lastPlayer.position.x-lastPlayer.boundingBox.size.width/2-20;
    }
    if(newPosition.x > 20) {
        newPosition.x = 20;
    }
    
    playersPool.position = newPosition;
}

CGPoint originalPoint;
-(BOOL) movePlayersByPanGesture: (UIPanGestureRecognizer*) sender {
    CGPoint location = [sender locationInView:sender.view];
    CGPoint locationInWorldSpace = [[CCDirector sharedDirector] convertToGL:location];
    CGPoint locationInMySpriteSpace = [playersPool convertToNodeSpace:locationInWorldSpace];
    
    if(sender.state == UIGestureRecognizerStateBegan) {
        originalPoint = locationInMySpriteSpace;
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
    pids = obj==nil ? [NSMutableArray new] : (NSMutableArray*)obj;
    
    GlobalSettings* global = [GlobalSettings globalSettings];
    NSArray* selPlayerIds = [global getPlayerIds];
    
    personIcons = [NSMutableArray new];
    personIconsMap = [NSMutableDictionary new];
    for(NSString* id in pids) {
        NSString* name = [userDefaults stringForKey:[id stringByAppendingString:@"-name"]];
        NSData* imgData = [userDefaults dataForKey:[id stringByAppendingString:@"-img"]];
        UIImage* image = [UIImage imageWithData:imgData];
        [self addPlayer:id withName:name andImage:image];
        if([selPlayerIds containsObject:id]) {
            [self selectPlayerByNode: [personIconsMap objectForKey: id]];
        }
    }
    
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
    [self addPlayer:id withName:name andImage:image];
    CCSprite* lastPlayer = (CCSprite*)[personIcons lastObject];
    CGPoint newPosition = playersPool.position;
    newPosition.x = [[CCDirector sharedDirector] winSize].width-lastPlayer.position.x-lastPlayer.boundingBox.size.width/2-20;
    [self setPlayersPoolPosition: newPosition];

}

-(void) addPlayer: (NSString*) id withName: (NSString*) name andImage: (UIImage*) image {
    if(id.length <= 0 || name.length <= 0) return;
    
    image = [image resizedImage:CGSizeMake(IMG_WIDTH, IMG_HEIGHT) interpolationQuality:kCGInterpolationDefault];
    
    CCTexture2D *texture = [[CCTexture2D alloc] initWithCGImage: image.CGImage resolutionType: kCCResolutioniPad];
    CGSize textureSize = [texture contentSize];
    MySprite *icon = [MySprite spriteWithTexture: texture];
    
    MySprite* lastIcon = personIcons.lastObject;
    icon.position = ccp(lastIcon ? lastIcon.position.x+IMG_WIDTH+20 : IMG_WIDTH/2, IMG_HEIGHT/2);
    icon.id = id;
    icon.name = name;
    icon.isTouchEnabled = YES;
    [icon showName];
    
    UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPlayer:)];
    tapGestureRecognizer.delegate = self;
    [icon addGestureRecognizer:tapGestureRecognizer];
    
    UIGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressePlayer:)];
    longPressGestureRecognizer.delegate = self;
    [icon addGestureRecognizer:longPressGestureRecognizer];
    
    [playersPool addChild: icon];
    [personIcons addObject:icon];
    [personIconsMap setObject:icon forKey:icon.id];
    [self setPlayersPoolPosition: ccp(20, 0)];
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
