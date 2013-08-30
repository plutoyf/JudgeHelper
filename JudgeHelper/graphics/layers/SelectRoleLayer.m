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

-(void) addRole: (UITapGestureRecognizer*) sender {
    NSString* name = [Engin getRoleName:sender.node.tag];
    [roleNumbers setObject: [NSNumber numberWithInt: ((NSNumber*)[roleNumbers objectForKey: name]).intValue+1] forKey: name];
    [self updateRoleLable: name];
    [self matchPlayerNumber];
}

-(void) removeRole: (UITapGestureRecognizer*) sender {
    NSString* name = [Engin getRoleName:sender.node.tag];
    if(((NSNumber*)[roleNumbers objectForKey: name]).intValue > 0) {
        [roleNumbers setObject: [NSNumber numberWithInt: ((NSNumber*)[roleNumbers objectForKey: name]).intValue-1] forKey: name];
        [self updateRoleLable: name];
        [self matchPlayerNumber];
    }
}

-(void) updateRoleLable: (NSString*) name {
    ((CCLabelTTF*)[roleLabels objectForKey:name]).string = [NSString stringWithFormat:@"%@ (%d)", name, ((NSNumber*)[roleNumbers objectForKey:name]).intValue];
}


-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
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
            icon.position = ccp(60+(100*i), size.height-300);
            icon.name = [Engin getRoleName:r];
            [self addChild: icon];
            [roleIconsMap setObject: icon forKey: icon.name];
            
            CCLabelTTF *iconLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@ (%d)", icon.name, ((NSNumber*)[roleNumbers objectForKey:icon.name]).intValue] fontName:@"Marker Felt" fontSize:12];
            iconLabel.position = ccp(60+(100*i), size.height-350);
            [self addChild: iconLabel];
            [roleLabels setObject:iconLabel forKey:icon.name];
            
            if(r != Judge) {
                CCSprite *upIcon = [CCSprite spriteWithTexture: [[CCTexture2D alloc] initWithCGImage: [UIImage imageNamed: @"up.png"].CGImage resolutionType: kCCResolutioniPad]];
                upIcon.position = ccp(60+(100*i), size.height-300+65);
                upIcon.tag = r;
                upIcon.isTouchEnabled = YES;
                [upIcon addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addRole:)]];
                [self addChild: upIcon];
                                
                CCSprite *downIcon = [CCSprite spriteWithTexture: [[CCTexture2D alloc] initWithCGImage: [UIImage imageNamed: @"down.png"].CGImage resolutionType: kCCResolutioniPad]];
                downIcon.position = ccp(60+(100*i), size.height-300-80);
                downIcon.tag = r;
                downIcon.isTouchEnabled = YES;
                [downIcon addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeRole:)]];
                [self addChild: downIcon];
            }
            
            i++;
        }
        
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
