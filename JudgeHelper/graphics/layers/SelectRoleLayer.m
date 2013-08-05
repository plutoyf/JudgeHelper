//
//  SelectRoleScene.m
//  JudgeHelper
//
//  Created by YANG FAN on 28/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "SelectRoleLayer.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCEngin.h"
#import "MySprite.h"
#import "SelectPlayerLayer.h"
#import "GlobalSettings.h"
#import "GameStateSprite.h"
#import "CCNode+SFGestureRecognizers.h"

static NSString * const UIGestureRecognizerNodeKey = @"UIGestureRecognizerNodeKey";

@implementation SelectRoleLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SelectRoleLayer *layer = [SelectRoleLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kCCMenuTouchPriority swallowsTouches:NO];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    if (CGRectContainsPoint(nextIcon.boundingBox, touchLocation)) {
        [self toNextScreen];
    } else {
        [self selectRoleForTouch:touchLocation];
    }
    
    return TRUE;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    [self panForTranslation:translation];
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if(selRoleIcon) {
        CGPoint p1 = selRoleIcon.position;
        CGPoint p0 = ((MySprite*)[roleIcons objectForKey: selRoleIcon.name]).position;
        float w = 72;
        float h = 72;
        if(p1.x == p0.x && p1.y == p0.y) {
            //role number ++
            [roleNumbers setObject: [self plusplus: [roleNumbers objectForKey:selRoleIcon.name]] forKey: selRoleIcon.name];
            [self updateRoleLable: selRoleIcon];
        } else if(p1.x<(p0.x-w) || p1.x>(p0.x+w) || p1.y<(p0.y-h) || p1.y>(p0.y+h)) {
            //role number --
            if(((NSNumber*)[roleNumbers objectForKey:selRoleIcon.name]).intValue > 0) {
                [roleNumbers setObject: [self minusminus: [roleNumbers objectForKey:selRoleIcon.name]] forKey: selRoleIcon.name];
                [self updateRoleLable: selRoleIcon];
            }
        }
        
        selRoleIcon.position = ((MySprite*)[roleIcons objectForKey: selRoleIcon.name]).position;
    }
}

-(void) updateRoleLable: (MySprite*) icon {
    ((CCLabelTTF*)[roleLabels objectForKey:selRoleIcon.name]).string = [NSString stringWithFormat:@"%@ (%d)", icon.name, ((NSNumber*)[roleNumbers objectForKey:icon.name]).intValue];
}

-(NSNumber*) plusplus : (NSNumber*) n {
    return [NSNumber numberWithInt: n.intValue+1 ];
}

-(NSNumber*) minusminus : (NSNumber*) n {
    return [NSNumber numberWithInt: n.intValue-1 ];
}

-(void)panForTranslation:(CGPoint)translation {
    if (selRoleIcon) {
        if(((NSNumber*)[roleNumbers objectForKey:selRoleIcon.name]).intValue > 0) {
            CGPoint newPos = ccpAdd(selRoleIcon.position, translation);
            selRoleIcon.position = newPos;
        } else {
            selRoleIcon = nil;
        }
    }
}

-(void) toNextScreen {
    int total = 0;
    for(NSNumber* n in roleNumbers.allValues) {
        total += n.intValue;
    }
    
    if([[GlobalSettings globalSettings] getGameMode] == DOUBLE_HAND && total%2 == 0) {
        // need one person more/less in double hand mode
    } else {
        [[GlobalSettings globalSettings] setTotalRoleNumber: total];
        [engin initRoles: roleNumbers];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[SelectPlayerLayer scene] ]];
    }
}


CCEngin* engin;
MySprite* nextIcon;
MySprite* selRoleIcon;
CCSprite* gameStateSprite;
NSMutableDictionary * roleIcons;
NSMutableDictionary * roleNumbers;
NSMutableArray * movableRoleIcons;
NSMutableDictionary* roleLabels;
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        self.isTouchEnabled = YES;

        // ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF* messageLabel = [CCLabelTTF labelWithString:@"角色设定" fontName:@"Marker Felt" fontSize:32];
        messageLabel.position = ccp( 100 , size.height-100 );
		messageLabel.tag = 13;
        [self addChild: messageLabel];

		engin = [CCEngin getEngin];
        roleIcons = [[NSMutableDictionary alloc] init];
        roleNumbers = [[NSMutableDictionary alloc] init];
        movableRoleIcons = [[NSMutableArray alloc] init];
        roleLabels = [[NSMutableDictionary alloc] init];
        int i = 0;
        for(NSString* rs in engin.roles) {
            Role r = [Engin getRoleFromString:rs];
            
            UIImage *iconImg = [UIImage imageNamed: [[@"Icon-72-" stringByAppendingString: [CCEngin getRoleCode: r ]] stringByAppendingString: @".png"]];
            MySprite *icon = [MySprite spriteWithTexture: [[CCTexture2D alloc] initWithCGImage: iconImg.CGImage resolutionType: kCCResolutioniPad]];
            icon.position = ccp(60+(100*i), size.height-300);
            icon.name = [Engin getRoleName:r];
            icon.selectable = YES;
            [self addChild: icon];
            [roleIcons setObject: icon forKey: icon.name];
            
            [roleNumbers setObject:[engin.roleNumbers objectForKey:icon.name] forKey:icon.name];
            CCLabelTTF *iconLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@ (%d)", icon.name, ((NSNumber*)[engin.roleNumbers objectForKey:icon.name]).intValue] fontName:@"Marker Felt" fontSize:12];
            iconLabel.position = ccp(60+(100*i), size.height-350);
            [self addChild: iconLabel];
            [roleLabels setObject:iconLabel forKey:icon.name];
            
            if(r != Judge) {
                MySprite *movableIcon = [MySprite spriteWithTexture: [[CCTexture2D alloc] initWithCGImage: iconImg.CGImage resolutionType: kCCResolutioniPad]];
                movableIcon.position = ccp(60+(100*i), size.height-300);
                movableIcon.name = [Engin getRoleName:r];
                [self addChild: movableIcon];
                [movableRoleIcons addObject:movableIcon];
            }
            
            i++;
        }
        
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
        
        nextIcon = [CCSprite spriteWithTexture: [[CCTexture2D alloc] initWithCGImage: [UIImage imageNamed: @"next.png"].CGImage resolutionType: kCCResolutioniPad]];
        nextIcon.position = ccp(size.width-100, 100);
        [self addChild: nextIcon];
        
        gameStateSprite = [[GameStateSprite alloc] init];
        gameStateSprite.isTouchEnabled = YES;
        UIGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        panGestureRecognizer.delegate = self;
        [gameStateSprite addGestureRecognizer:panGestureRecognizer];

        [self addChild: gameStateSprite];
        
    }
    
	return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)aPanGestureRecognizer
{
    CCNode *node = aPanGestureRecognizer.node;
    CGPoint translation = [aPanGestureRecognizer translationInView:aPanGestureRecognizer.view];
    translation.y *= -1;
    [aPanGestureRecognizer setTranslation:CGPointZero inView:aPanGestureRecognizer.view];
    
    node.position = ccpAdd(node.position, translation);
}

-(void) doubleHandModeButtonTapped: (id) sender
{
    GlobalSettings *globals = [GlobalSettings globalSettings];
    CCMenuItemToggle *toggleItem = (CCMenuItemToggle *)sender;
    if (toggleItem.selectedItem == doubleHandModeOffItem) {
        [globals setGameMode:NORMAL];
    } else if (toggleItem.selectedItem == doubleHandModeOnItem) {
        [globals setGameMode:DOUBLE_HAND];
    }
}


#pragma mark - GestureRecognizer delegate
- (void)selectRoleForTouch:(CGPoint)touchLocation {
    CCSprite * newSprite = nil;
    for (CCSprite *sprite in movableRoleIcons) {
        if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {
            newSprite = sprite;
            break;
        }
    }
    selRoleIcon = newSprite;
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
