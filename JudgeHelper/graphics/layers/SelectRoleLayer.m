//
//  SelectRoleScene.m
//  JudgeHelper
//
//  Created by YANG FAN on 28/07/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "SelectRoleLayer.h"
#import "AppDelegate.h"
#import "GlobalSettings.h"
#import "CCNode+SFGestureRecognizers.h"

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
        startMenu.opacity = 80;
        startMenu.isTouchEnabled = NO;
        messageLabel.string = [NSString stringWithFormat:@"角色数目过少, 请再添加%d个角色", pNum-rNum];
        messageLabel.position = ccp( messageLabel.boundingBox.size.width/2+REVERSE_X(20) , messageLabel.position.y);
    } else if (rNum - pNum > 0) {
        startMenu.opacity = 80;
        startMenu.isTouchEnabled = NO;
        messageLabel.string = [NSString stringWithFormat:@"角色数目过多, 请再减少%d个角色", rNum-pNum];
        messageLabel.position = ccp( messageLabel.boundingBox.size.width/2+REVERSE_X(20) , messageLabel.position.y);
    } else {
        startMenu.opacity = 255;
        startMenu.isTouchEnabled = YES;
        messageLabel.string = @"可以开始游戏";
        messageLabel.position = ccp( messageLabel.boundingBox.size.width/2+REVERSE_X(20) , messageLabel.position.y);
    }
}

-(void) toGameScreen : (id) sender {
    if(startMenu.opacity == 255) {
        [engin initRoles: roleNumbers];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer scene] ]];
    }
}

-(void) addRole: (id) sender {
    NSString* name = [CCEngin getRoleName:((CCMenuItem*)sender).tag];
    NSString* label = [CCEngin getRoleLabel:((CCMenuItem*)sender).tag];
    [roleNumbers setObject: [NSNumber numberWithInt: ((NSNumber*)[roleNumbers objectForKey: name]).intValue+1] forKey: name];
    [self updateRole: name withLable: label];
    [self matchPlayerNumber];
}

-(void) removeRole: (id) sender {
    NSString* name = [CCEngin getRoleName:((CCMenuItem*)sender).tag];
    NSString* label = [CCEngin getRoleLabel:((CCMenuItem*)sender).tag];
    if(((NSNumber*)[roleNumbers objectForKey: name]).intValue > 0) {
        [roleNumbers setObject: [NSNumber numberWithInt: ((NSNumber*)[roleNumbers objectForKey: name]).intValue-1] forKey: name];
        [self updateRole: name withLable: label];
        [self matchPlayerNumber];
    }
}

-(void) updateRole: (NSString*) name withLable: (NSString*) label {
    ((CCLabelTTF*)[roleLabels objectForKey:name]).string = [NSString stringWithFormat:@"%@ (%d)", label, ((NSNumber*)[roleNumbers objectForKey:name]).intValue];
}


-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        // ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        GlobalSettings* global = [GlobalSettings globalSettings];
        
        CCLabelTTF* titleLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"角色设定 (%d名玩家)", ((NSArray*)[global getPlayerIds]).count] fontName:@"Marker Felt" fontSize:REVERSE_X(32)];
        titleLabel.position = ccp( titleLabel.boundingBox.size.width/2+REVERSE_X(20), size.height-REVERSE_Y(40) );
        [self addChild: titleLabel];
        
        messageLabel = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:REVERSE_X(28)];
        messageLabel.position = ccp( REVERSE_X(20) , size.height-REVERSE_Y(100));
        [self addChild: messageLabel];
        
        
        CCLabelTTF* gameModeLabel = [CCLabelTTF labelWithString:@"双手模式" fontName:@"Marker Felt" fontSize:REVERSE_X(28)];
        gameModeLabel.position = REVERSE_XY(80, 120);
        [self addChild: gameModeLabel];
        
        doubleHandModeOffItem = [CCMenuItemImage itemFromNormalImage:@"btn_off2_red-40.png" selectedImage:@"btn_off2_red-40-sel.png" target:nil selector:nil];
        doubleHandModeOnItem = [CCMenuItemImage itemFromNormalImage:@"btn_on2_green-40.png" selectedImage:@"btn_on2_green-40-sel.png" target:nil selector:nil];
        [doubleHandModeOffItem setScaleX: REVERSE(40)/doubleHandModeOffItem.contentSize.width];
        [doubleHandModeOffItem setScaleY: REVERSE(40)/doubleHandModeOffItem.contentSize.height];
        [doubleHandModeOnItem setScaleX: REVERSE(40)/doubleHandModeOnItem.contentSize.width];
        [doubleHandModeOnItem setScaleY: REVERSE(40)/doubleHandModeOnItem.contentSize.height];
        
        CCMenuItemToggle *toggleItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(doubleHandModeButtonTapped:) items:([global getGameMode] == DOUBLE_HAND?doubleHandModeOnItem:doubleHandModeOffItem), ([global getGameMode] == DOUBLE_HAND?doubleHandModeOffItem:doubleHandModeOnItem), nil];
        CCMenu *toggleMenu = [CCMenu menuWithItems:toggleItem, nil];
        toggleMenu.position = REVERSE_XY(170, 120);
        [self addChild:toggleMenu];
        
        doubleHandModeLabel = [CCLabelTTF labelWithString:[global getGameMode] == DOUBLE_HAND?@"(开启)":@"(关闭)" fontName:@"Marker Felt" fontSize:REVERSE_X(28)];
        doubleHandModeLabel.position = REVERSE_XY(240, 120);
        [self addChild: doubleHandModeLabel];

        
        engin = [CCEngin getEngin];
        roles = [global getRoles] ? [global getRoles] : engin.roles;
        roleNumbers = [NSMutableDictionary dictionaryWithDictionary: [global getRoleNumbers] ? [global getRoleNumbers] : engin.roleNumbers];
        
        roleIconsMap = [[NSMutableDictionary alloc] init];
        roleLabels = [[NSMutableDictionary alloc] init];
        int i = 0;
        for(NSString* rs in roles) {
            Role r = [Engin getRoleFromString:rs];
            
            UIImage *iconImg = [UIImage imageNamed: [[@"Icon-72-" stringByAppendingString: [CCEngin getRoleCode: r ]] stringByAppendingString: @".png"]];
            MySprite *icon = [MySprite spriteWithTexture: [[CCTexture2D alloc] initWithCGImage: iconImg.CGImage resolutionType: kCCResolutioniPad]];
            [icon setScaleX: IMG_WIDTH/icon.contentSize.width];
            [icon setScaleY: IMG_HEIGHT/icon.contentSize.height];
            icon.position = ccp(REVERSE_X(60)+(REVERSE_X(100)*i), size.height-REVERSE_Y(300));
            icon.id = [CCEngin getRoleName:r];
            icon.name = [CCEngin getRoleLabel:r];
            [self addChild: icon];
            [roleIconsMap setObject: icon forKey: icon.id];
            
            CCLabelTTF *iconLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@ (%d)", icon.name, ((NSNumber*)[roleNumbers objectForKey:icon.id]).intValue] fontName:@"Marker Felt" fontSize:VALUE(12, 10)];
            iconLabel.position = ccp(REVERSE_X(60)+(REVERSE_X(100)*i), size.height-REVERSE_Y(370));
            [self addChild: iconLabel];
            [roleLabels setObject:iconLabel forKey:icon.id];
            
            if(r != Judge) {
                CCMenuItem* increaseRoleNumberMenuItem = [CCMenuItemImage itemFromNormalImage:@"up.png" selectedImage:@"up-sel.png" target:self selector:@selector(addRole:)];
                [increaseRoleNumberMenuItem setScaleX: VALUE(30, 22)/increaseRoleNumberMenuItem.contentSize.width];
                [increaseRoleNumberMenuItem setScaleY: VALUE(20, 16)/increaseRoleNumberMenuItem.contentSize.height];
                increaseRoleNumberMenuItem.tag = r;
                CCMenu *increaseRoleNumberMenu = [CCMenu menuWithItems:increaseRoleNumberMenuItem, nil];
                increaseRoleNumberMenu.position = ccp(REVERSE_X(60)+(REVERSE_X(100)*i), size.height-REVERSE_Y(300)+REVERSE_Y(75));
                [self addChild: increaseRoleNumberMenu];
                
                CCMenuItem* decreaseRoleNumberMenuItem = [CCMenuItemImage itemFromNormalImage:@"down.png" selectedImage:@"down-sel.png" target:self selector:@selector(removeRole:)];
                [decreaseRoleNumberMenuItem setScaleX: VALUE(30, 22)/decreaseRoleNumberMenuItem.contentSize.width];
                [decreaseRoleNumberMenuItem setScaleY: VALUE(20, 16)/decreaseRoleNumberMenuItem.contentSize.height];
                decreaseRoleNumberMenuItem.tag = r;
                CCMenu *decreaseRoleNumberMenu = [CCMenu menuWithItems:decreaseRoleNumberMenuItem, nil];
                decreaseRoleNumberMenu.position = ccp(REVERSE_X(60)+(REVERSE_X(100)*i), size.height-REVERSE_Y(410));
                [self addChild: decreaseRoleNumberMenu];
            }
            
            i++;
        }
        
        CCMenuItem *previousMenuItem = [CCMenuItemImage itemFromNormalImage:@"previous.png" selectedImage:@"previous-sel.png" target:self selector:@selector(toPreviousScreen:)];
        [previousMenuItem setScaleX: IMG_WIDTH/previousMenuItem.contentSize.width];
        [previousMenuItem setScaleY: IMG_HEIGHT/previousMenuItem.contentSize.height];
        previousMenu = [CCMenu menuWithItems:previousMenuItem, nil];
        previousMenu.position = ccp(size.width-REVERSE_X(200), REVERSE_Y(100));
        [self addChild:previousMenu];
        
        CCMenuItem *startMenuItem = [CCMenuItemImage itemFromNormalImage:@"start.png" selectedImage:@"start-sel.png" target:self selector:@selector(toGameScreen:)];
        [startMenuItem setScaleX: IMG_WIDTH/startMenuItem.contentSize.width];
        [startMenuItem setScaleY: IMG_HEIGHT/startMenuItem.contentSize.height];
        startMenu = [CCMenu menuWithItems:startMenuItem, nil];
        startMenu.position = ccp(size.width-REVERSE_X(100), REVERSE_Y(100));
        [self addChild:startMenu];
        
        [self matchPlayerNumber];
    }
    
	return self;
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

@end
