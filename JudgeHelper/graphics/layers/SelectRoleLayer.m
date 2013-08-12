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
#import "GameLayer.h"
#import "GlobalSettings.h"
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
    [self selectRoleForTouch:touchLocation];
    
    return TRUE;
}

-(void) toPreviousScreen : (id) sender {
    GlobalSettings* global = [GlobalSettings globalSettings];
    [global setRoles: roles];
    [global setRoleNumbers: roleNumbers];

    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[SelectPlayerLayer scene] ]];
}

-(void) matchPlayerNumber {
    NSArray* ids = [[GlobalSettings globalSettings] getPlayerIds];
    
    int rNum = 0;
    for(NSNumber* n in roleNumbers.allValues) {
        rNum += n.intValue;
    }
    
    GlobalSettings* global = [GlobalSettings globalSettings];
    int pNum = [global getGameMode] == NORMAL ? ids.count : ids.count*2-1;
    
    
    if(rNum - pNum < 0) {
        startIcon.opacity = 80;
        startIcon.isTouchEnabled = NO;
        messageLabel.string = [NSString stringWithFormat:@"角色数目过少, 请再添加%d个角色", pNum-rNum];
    } else if (rNum - pNum > 0) {
        startIcon.opacity = 80;
        startIcon.isTouchEnabled = NO;
        messageLabel.string = [NSString stringWithFormat:@"角色数目过多, 请再减少%d个角色", rNum-pNum];
    } else {
        startIcon.opacity = 255;
        startIcon.isTouchEnabled = YES;
        messageLabel.string = @"可以开始游戏";
    }
}

-(void) toGameScreen : (id) sender {
    if(startIcon.opacity == 255) {
        [engin initRoles: roleNumbers];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer scene] ]];
    }
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
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    if(selRoleIcon) {
        CGPoint p1 = selRoleIcon.position;
        CGPoint p0 = ((MySprite*)[roleIconsMap objectForKey: selRoleIcon.name]).position;
        float w = 72;
        float h = 72;
        if(p1.x == p0.x && p1.y == p0.y) {
            //role number ++
            [roleNumbers setObject: [self plusplus: [roleNumbers objectForKey:selRoleIcon.name]] forKey: selRoleIcon.name];
            [self updateRoleLable: selRoleIcon];
            [self matchPlayerNumber];
        } else if(p1.x<(p0.x-w) || p1.x>(p0.x+w) || p1.y<(p0.y-h) || p1.y>(p0.y+h)) {
            //role number --
            if(((NSNumber*)[roleNumbers objectForKey:selRoleIcon.name]).intValue > 0) {
                [roleNumbers setObject: [self minusminus: [roleNumbers objectForKey:selRoleIcon.name]] forKey: selRoleIcon.name];
                [self updateRoleLable: selRoleIcon];
                [self matchPlayerNumber];
            }
        }
        
        selRoleIcon.position = ((MySprite*)[roleIconsMap objectForKey: selRoleIcon.name]).position;
        selRoleIcon = nil;
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


CCEngin* engin;
CCLabelTTF* messageLabel;
CCLabelTTF* doubleHandModeLabel;
MySprite* previousIcon;
MySprite* startIcon;
MySprite* selRoleIcon;
NSArray * roles;
NSMutableDictionary * roleNumbers;
NSMutableDictionary * roleIconsMap;
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
        GlobalSettings* global = [GlobalSettings globalSettings];
        
        CCLabelTTF* titleLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"角色设定 (%d名玩家)", ((NSArray*)[global getPlayerIds]).count] fontName:@"Marker Felt" fontSize:32];
        titleLabel.position = ccp( titleLabel.boundingBox.size.width/2+20 , size.height-100 );
        [self addChild: titleLabel];
        
        messageLabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:28];
        messageLabel.anchorPoint = ccp(0,0);
        messageLabel.position = ccp( 20 , size.height-160 );
        [self addChild: messageLabel];
        
        engin = [CCEngin getEngin];
        roles = [global getRoles] ? [global getRoles] : engin.roles;
        roleNumbers = [NSMutableDictionary dictionaryWithDictionary: [global getRoleNumbers] ? [global getRoleNumbers] : engin.roleNumbers];
        
        roleIconsMap = [[NSMutableDictionary alloc] init];
        movableRoleIcons = [[NSMutableArray alloc] init];
        roleLabels = [[NSMutableDictionary alloc] init];
        int i = 0;
        for(NSString* rs in roles) {
            Role r = [Engin getRoleFromString:rs];
            
            UIImage *iconImg = [UIImage imageNamed: [[@"Icon-72-" stringByAppendingString: [CCEngin getRoleCode: r ]] stringByAppendingString: @".png"]];
            MySprite *icon = [MySprite spriteWithTexture: [[CCTexture2D alloc] initWithCGImage: iconImg.CGImage resolutionType: kCCResolutioniPad]];
            icon.position = ccp(60+(100*i), size.height-300);
            icon.name = [Engin getRoleName:r];
            icon.selectable = YES;
            [self addChild: icon];
            [roleIconsMap setObject: icon forKey: icon.name];
            
            CCLabelTTF *iconLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@ (%d)", icon.name, ((NSNumber*)[roleNumbers objectForKey:icon.name]).intValue] fontName:@"Marker Felt" fontSize:12];
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
        gameModeLabel.position = ccp(80, 120);
        [self addChild: gameModeLabel];
        
        doubleHandModeOffItem = [CCMenuItemImage itemFromNormalImage:@"btn_off2_red-40.png" selectedImage:@"btn_off2_red-40.png" target:nil selector:nil];
        doubleHandModeOnItem = [CCMenuItemImage itemFromNormalImage:@"btn_on2_green-40.png" selectedImage:@"btn_on2_green-40.png" target:nil selector:nil];
        CCMenuItemToggle *toggleItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(doubleHandModeButtonTapped:) items:([global getGameMode] == DOUBLE_HAND?doubleHandModeOnItem:doubleHandModeOffItem), ([global getGameMode] == DOUBLE_HAND?doubleHandModeOffItem:doubleHandModeOnItem), nil];
        CCMenu *toggleMenu = [CCMenu menuWithItems:toggleItem, nil];
        toggleMenu.position = ccp(170, 120);
        [self addChild:toggleMenu];
        
        doubleHandModeLabel = [CCLabelTTF labelWithString:[global getGameMode] == DOUBLE_HAND?@"(开启)":@"(关闭)" fontName:@"Marker Felt" fontSize:28];
        doubleHandModeLabel.position = ccp(240, 120);
        [self addChild: doubleHandModeLabel];
        
        previousIcon = [CCSprite spriteWithTexture: [[CCTexture2D alloc] initWithCGImage: [UIImage imageNamed: @"previous.png"].CGImage resolutionType: kCCResolutioniPad]];
        previousIcon.position = ccp(size.width-200, 100);
        previousIcon.isTouchEnabled = YES;
        [previousIcon addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toPreviousScreen:)]];
        [self addChild: previousIcon];
        
        startIcon = [CCSprite spriteWithTexture: [[CCTexture2D alloc] initWithCGImage: [UIImage imageNamed: @"start.png"].CGImage resolutionType: kCCResolutioniPad]];
        startIcon.position = ccp(size.width-100, 100);
        [startIcon addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toGameScreen:)]];
        [self matchPlayerNumber];
        [self addChild: startIcon];
    }
    
	return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void) doubleHandModeButtonTapped: (id) sender
{
    GlobalSettings *globals = [GlobalSettings globalSettings];
    CCMenuItemToggle *toggleItem = (CCMenuItemToggle *)sender;
    if (toggleItem.selectedItem == doubleHandModeOffItem) {
        [globals setGameMode:NORMAL];
        doubleHandModeLabel.string = @"(关闭)";
    } else if (toggleItem.selectedItem == doubleHandModeOnItem) {
        [globals setGameMode:DOUBLE_HAND];
        doubleHandModeLabel.string = @"(开启)";
    }
    [self matchPlayerNumber];
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
