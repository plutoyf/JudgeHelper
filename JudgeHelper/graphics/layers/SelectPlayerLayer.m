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
    /*
    CGPoint location = [sender locationInView:sender.view];
    CGPoint locationInWorldSpace = [[CCDirector sharedDirector] convertToGL:location];
    CGPoint locationInMySpriteSpace = [sender.node convertToNodeSpace:locationInWorldSpace];
    if(!CGRectContainsPoint(CGRectMake(50-20, 0, (IMG_WIDTH+20)*9+20, 400), locationInWorldSpace)) return;
    */
    
    if(playerToRemove != nil) {
        [playerToRemove stopAllActions];
        [playerToRemove setRotation:0];
        [playerToRemove removeDeleteButton];
        playerToRemove = nil;
        return;
    }
    
    selPersonIcon = (MySprite*)sender.node;
    
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
        [personIcons removeObject:playerToRemove];
        [personIconsMap removeObjectForKey:playerToRemove.id];
        
        // remove frome playesPool
        [playersPool removeChild:playerToRemove];
        
        // sort playersPool
        CCSprite* node0;
        int d = (personIcons.count && ((CCSprite*)[personIcons objectAtIndex:0]).position.x < IMG_WIDTH/2 && ((CCSprite*)[personIcons lastObject]).position.x <= IMG_WIDTH/2+(IMG_WIDTH+20)*9) ? 1 : -1;
        for(CCSprite* node in personIcons) {
            if((!node0 && node.position.x > IMG_WIDTH/2) ||
               (node0 && node.position.x - node0.position.x > IMG_WIDTH+20)) {
                node.position = ccpAdd(node.position, ccp((IMG_WIDTH+20)*d, 0));
            }
            node0 = node;
        }
        
        playerToRemove = nil;
    }
    
}


- (void) startGame : (id) sender {
    // init players
    NSArray* playerIds = [self getSelectedPlayerIds];
    GlobalSettings* global = [GlobalSettings globalSettings];
    if([global getGameMode] == DOUBLE_HAND && playerIds.count*2 != [global getTotalRoleNumber]+1) {
        //too many or not enough players in DOUBLE HAND game mode
    } else if([global getGameMode] == NORMAL && playerIds.count != [global getTotalRoleNumber]) {
        //too many or not enough players in NORMAL game mode
    } else {
        [global setPlayerIds: playerIds];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameLayer scene] ]];
    }
}

-(void) toPreviousScreen : (id) sender {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[SelectRoleLayer scene] ]];
}

CreatePlayerLayer* createPlayerLayer;
-(void) showCreatePlayerScreen {
    createPlayerLayer = [[CreatePlayerLayer alloc] init];
    createPlayerLayer.delegate = self;
    [self addChild:createPlayerLayer];
}

CCEngin* engin;
CCSprite* previousIcon;
CCSprite* startIcon;
MySprite* selPersonIcon;
ClippingSprite* playersPool;
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
        
        
        CCMenuItem *leftMenuItem = [CCMenuItemImage
                                    itemFromNormalImage:@"left.png" selectedImage:@"left.png"
                                    target:self selector:@selector(leftButtonTapped:)];
        leftMenuItem.position = ccp(-50, 30);
        CCMenuItem *rightMenuItem = [CCMenuItemImage
                                     itemFromNormalImage:@"right.png" selectedImage:@"right.png"
                                     target:self selector:@selector(rightButtonTapped:)];
        rightMenuItem.position = ccp(50, 30);
        
        CCMenu *playersPoolMenu = [CCMenu menuWithItems:leftMenuItem, rightMenuItem, nil];
        playersPoolMenu.position = ccp(size.width/2, 260);
        [self addChild:playersPoolMenu];
        
        CCMenuItem *addPlayerMenuItem = [CCMenuItemImage
                                    itemFromNormalImage:@"add.png" selectedImage:@"add.png"
                                    target:self selector:@selector(addPlayerButtonTapped:)];
        [addPlayerMenuItem setScaleX: IMG_WIDTH/addPlayerMenuItem.contentSize.width];
        [addPlayerMenuItem setScaleY: IMG_HEIGHT/addPlayerMenuItem.contentSize.height];
        
        CCMenu *playerMenu = [CCMenu menuWithItems:addPlayerMenuItem, nil];
        playerMenu.position = ccp(size.width-100, 208);
        [self addChild:playerMenu];
        

        
        CCLabelTTF* gameModeLabel = [CCLabelTTF labelWithString:@"双手模式" fontName:@"Marker Felt" fontSize:28];
        gameModeLabel.position = ccp(60, 120);
        [self addChild: gameModeLabel];

        GlobalSettings* global = [GlobalSettings globalSettings];
        doubleHandModeOffItem = [CCMenuItemImage itemFromNormalImage:@"btn_off2_red-40.png" selectedImage:@"btn_off2_red-40.png" target:nil selector:nil];
        doubleHandModeOnItem = [CCMenuItemImage itemFromNormalImage:@"btn_on2_green-40.png" selectedImage:@"btn_on2_green-40.png" target:nil selector:nil];
        CCMenuItemToggle *toggleItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(doubleHandModeButtonTapped:) items:([global getGameMode] == DOUBLE_HAND?doubleHandModeOnItem:doubleHandModeOffItem), ([global getGameMode] == DOUBLE_HAND?doubleHandModeOffItem:doubleHandModeOnItem), nil];
        CCMenu *toggleMenu = [CCMenu menuWithItems:toggleItem, nil];
        toggleMenu.position = ccp(150, 120);
        [self addChild:toggleMenu];
        
        previousIcon = [CCSprite spriteWithTexture: [[CCTexture2D alloc] initWithCGImage: [UIImage imageNamed: @"previous.png"].CGImage resolutionType: kCCResolutioniPad]];
        previousIcon.position = ccp(size.width-200, 100);
        previousIcon.isTouchEnabled = YES;
        UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toPreviousScreen:)];
        tapGestureRecognizer.delegate = self;
        [previousIcon addGestureRecognizer:tapGestureRecognizer];
        [self addChild: previousIcon];
        
        startIcon = [CCSprite spriteWithTexture: [[CCTexture2D alloc] initWithCGImage: [UIImage imageNamed: @"start.png"].CGImage resolutionType: kCCResolutioniPad]];
        startIcon.position = ccp(size.width-100, 100);
        startIcon.isTouchEnabled = YES;
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startGame:)];
        tapGestureRecognizer.delegate = self;
        [startIcon addGestureRecognizer:tapGestureRecognizer];
        [self addChild: startIcon];
        
        
        playersPool = [[ClippingSprite alloc] init];
        [playersPool setContentSize:CGSizeMake(size.width-200, 100)];
        playersPool.openWindowRect = CGRectMake(50-20, 0, (IMG_WIDTH+20)*9+20, 400);
        playersPool.position = ccp(50+(size.width-200)/2, 170+100/2);
        
        [self addChild:playersPool];
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

-(BOOL) leftButtonTapped: (id) sender {
    if(!personIcons.count || ((CCSprite*)[personIcons objectAtIndex:0]).position.x >= IMG_WIDTH/2) return NO;
    for(CCSprite* node in personIcons) {
        node.position = ccpAdd(node.position, ccp((IMG_WIDTH+20), 0));
        if(node.position.x > -IMG_WIDTH/2 && node.position.x < IMG_WIDTH/2+(IMG_WIDTH+20)*9) {
            node.touchRect = CGRectMake(node.position.x-IMG_WIDTH/2<0?IMG_WIDTH/2-node.position.x:0, 0, node.position.x+IMG_WIDTH/2>IMG_WIDTH/2+(IMG_WIDTH+20)*9?IMG_WIDTH/2+(IMG_WIDTH+20)*9-node.position.x-IMG_WIDTH/2:IMG_WIDTH, IMG_HEIGHT);
        } else {
            node.touchRect = CGRectMake(0, 0, 0, 0);
        }
    }
    return YES;
}

-(BOOL) rightButtonTapped: (id) sender {
    if(!personIcons.count || ((CCSprite*)[personIcons lastObject]).position.x < IMG_WIDTH/2+(IMG_WIDTH+20)*9) return NO;
    for(CCSprite* node in personIcons) {
        node.position = ccpAdd(node.position, ccp(-(IMG_WIDTH+20), 0));
        if(node.position.x > -IMG_WIDTH/2 && node.position.x < IMG_WIDTH/2+(IMG_WIDTH+20)*9) {
            node.touchRect = CGRectMake(node.position.x-IMG_WIDTH/2<0?IMG_WIDTH/2-node.position.x:0, 0, node.position.x+IMG_WIDTH/2>IMG_WIDTH/2+(IMG_WIDTH+20)*9?IMG_WIDTH/2+(IMG_WIDTH+20)*9-node.position.x-IMG_WIDTH/2:IMG_WIDTH, IMG_HEIGHT);
        } else {
            node.touchRect = CGRectMake(0, 0, 0, 0);
        }
        
    }
    return YES;
}

- (void)handlePlayersPoolPanGesture:(UIPanGestureRecognizer*)aPanGestureRecognizer {
    CGPoint translation = [aPanGestureRecognizer translationInView:aPanGestureRecognizer.view];
    translation.y *= -1;
    [aPanGestureRecognizer setTranslation:CGPointZero inView:aPanGestureRecognizer.view];
}

-(void) doubleHandModeButtonTapped: (id) sender
{
    GlobalSettings *globals = [GlobalSettings globalSettings];
    CCMenuItemToggle *toggleItem = (CCMenuItemToggle *)sender;
    if (toggleItem.selectedItem == doubleHandModeOffItem) {
        [globals setGameMode:NORMAL];
    } else if (toggleItem.selectedItem == doubleHandModeOnItem && [globals getTotalRoleNumber]%2 == 1) {
        [globals setGameMode:DOUBLE_HAND];
    }
}


NSString * const pidsKey = @"pids";
NSMutableArray* pids;
-(void) initPlayers {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    id obj = [userDefaults objectForKey:pidsKey];
    pids = obj==nil ? [NSMutableArray new] : (NSMutableArray*)obj;
    
    personIcons = [NSMutableArray new];
    personIconsMap = [NSMutableDictionary new];
    for(NSString* id in pids) {
        NSString* name = [userDefaults stringForKey:[id stringByAppendingString:@"-name"]];
        NSData* imgData = [userDefaults dataForKey:[id stringByAppendingString:@"-img"]];
        UIImage* image = [UIImage imageWithData:imgData];
        [self addPlayer:id withName:name andImage:image];
    }
    
}

-(void) createPlayer: (NSString*) name withImage: (UIImage*) image {
    if(name.length <= 0) return;
    
    //1. generate player's code
    
    //2. save player's info
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* id = [NSNumber numberWithLong: (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970])].stringValue;
    [pids addObject:id];
    [userDefaults setObject:pids forKey:pidsKey];
    [userDefaults setObject:name forKey:[id stringByAppendingString:@"-name"]];
    [userDefaults setObject:UIImagePNGRepresentation(image) forKey:[id stringByAppendingString:@"-img"]];
    [userDefaults synchronize];
    
    //3. show player in the list
    [self addPlayer:id withName:name andImage:image];
    while([self rightButtonTapped:nil]) {
    };
}

-(void) addPlayer: (NSString*) id withName: (NSString*) name andImage: (UIImage*) image {
    if(id.length <= 0 || name.length <= 0) return;
    
    image = [image resizedImage:CGSizeMake(IMG_WIDTH, IMG_HEIGHT) interpolationQuality:kCGInterpolationDefault];
    
    CCTexture2D *texture = [[CCTexture2D alloc] initWithCGImage: image.CGImage resolutionType: kCCResolutioniPad];
    CGSize textureSize = [texture contentSize];
    MySprite *icon = [MySprite spriteWithTexture: texture];
    
    icon.position = ccp((IMG_WIDTH+20)*personIcons.count+IMG_WIDTH/2, IMG_HEIGHT/2);
    icon.id = id;
    icon.name = name;
    icon.isTouchEnabled = YES;
    if(icon.position.x > -IMG_WIDTH/2 && icon.position.x < IMG_WIDTH/2+(IMG_WIDTH+20)*9) {
        icon.touchRect = CGRectMake(icon.position.x<IMG_WIDTH/2?IMG_WIDTH/2-icon.position.x:0, 0, icon.position.x+IMG_WIDTH/2>IMG_WIDTH/2+(IMG_WIDTH+20)*9?IMG_WIDTH/2+(IMG_WIDTH+20)*9-icon.position.x-IMG_WIDTH/2:IMG_WIDTH, IMG_HEIGHT);
    } else {
        icon.touchRect = CGRectMake(0, 0, 0, 0);
    }
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
