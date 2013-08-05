//
//  GameLayer.m
//  JudgeHelper
//
//  Created by YANG FAN on 20/07/13.
//  Copyright YANG FAN 2013. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "RuleResolver.h"
#import "CCHandPlayer.h"
#import "CCDoubleHandPlayer.h"
#import "SelectPlayerLayer.h"

#pragma mark - GameLayer

// HelloWorldLayer implementation
@implementation GameLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kCCMenuTouchPriority swallowsTouches:NO];
}


-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    selPlayer = nil;
    for (CCPlayer* p in players) {
        if (p.selectable && [p isInside: touchLocation]) {
            selPlayer = p;
            break;
        }
    }
    
    return TRUE;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    if (selPlayer) {
        CGPoint newPos = ccpAdd(selPlayer.sprite.position, translation);
        selPlayer.sprite.position = newPos;
        selPlayerInMove = YES;
    }
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    NSString* name = nil;
    if (CGRectContainsPoint(undoIcon.boundingBox, touchLocation)) {
        name = @"UNDO_ACTION";
    } else if (CGRectContainsPoint(redoIcon.boundingBox, touchLocation)) {
        name = @"REDO_ACTION";
    } else if (selPlayer) {
        if(selPlayer.role == Judge) {
            name = nil;
        } else if(rolePlayerToDefine == Judge) {
            name = selPlayer.name;
        } else {
            name = selPlayer.name;
        }
        if(!selPlayerInMove) {
            [selPlayer hideRoleInfo];
            [selPlayer showRoleInfo];
        }
    }
    
    if(!selPlayerInMove) {
        if(rolePlayerToDefine > 0) {
            if(!defineRolePlayerBegin) {
                [self showMessage: [NSString stringWithFormat:@"请设定“%@”角色玩家", [engin getRoleLabel: rolePlayerToDefine]]];
                defineRolePlayerBegin = YES;
            } else {
                if(selPlayer && (selPlayer.role == 0 || selPlayer.role == Citizen)) {
                    // select this player as role
                    [engin getPlayerByName:selPlayer.name].role = rolePlayerToDefine;
                    if(rolePlayerToDefine == Judge) {
                        [self initPlayersWithJudge: name];
                    }
                
                    if([engin getRoleNumber:rolePlayerToDefine] == [engin getPlayersByRole:rolePlayerToDefine].count) {
                        rolePlayerToDefine = 0;
                        defineRolePlayerBegin = NO;
                        [engin action: name];
                    }
                }
            }
        } else {
            [engin action: name];
        }
    }
    
    selPlayerInMove = NO;
}


BOOL showDebugMessageEnable = NO;

CCLabelTTF* debugLabel;
CCLabelTTF* nightLabel;
CCLabelTTF* messageLabel;
CCSprite* undoIcon;
CCSprite* redoIcon;
CCMenu* restarMenu;
CCPlayer* selPlayer;
BOOL selPlayerInMove;
NSMutableDictionary* playersMap;
NSMutableArray* players;
Role rolePlayerToDefine;
BOOL defineRolePlayerBegin;

//NSMutableArray* playerBackupStateIcons;
CCEngin* engin;
// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        self.isTouchEnabled = YES;
		
        engin = [CCEngin getEngin];
        engin.displayDelegate = self;
        
        // ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        undoIcon = [CCSprite spriteWithTexture: [[CCTexture2D alloc] initWithCGImage: [UIImage imageNamed: @"undo.png"].CGImage resolutionType: kCCResolutioniPad]];
        undoIcon.position = ccp(60, size.height-200);
        [self addChild: undoIcon];
        
        redoIcon = [CCSprite spriteWithTexture: [[CCTexture2D alloc] initWithCGImage: [UIImage imageNamed: @"redo.png"].CGImage resolutionType: kCCResolutioniPad]];
        redoIcon.position = ccp(160, size.height-200);
        [self addChild: redoIcon];
        
        
        nightLabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:28];
        nightLabel.position = ccp(60 , size.height-100 );
		nightLabel.tag = 12;
        [self addChild: nightLabel];
        
		// create and initialize a Label
		// position the label on the center of the screen
		messageLabel = [CCLabelTTF labelWithString:@"Killer" fontName:@"Marker Felt" fontSize:64];
        messageLabel.position = ccp( size.width /2 , size.height/2-(showDebugMessageEnable?200:0) );
		messageLabel.tag = 13;
        [self addChild: messageLabel];
        
        if(showDebugMessageEnable) {
            debugLabel = [CCLabelTTF labelWithString:@"debug : " fontName:@"Marker Felt" fontSize:13];
            debugLabel.position = ccp(600 , size.height-280 );
            debugLabel.tag = 11;
            [self addChild: debugLabel];
        }
        
        // init players without role
        playersMap = [[NSMutableDictionary alloc] init];
        players = [[NSMutableArray alloc] init];
        for(int i = 0; i < engin.players.count; i++) {
            CCPlayer* p = [engin.players objectAtIndex:i];
            int line = (int)((i+6)/6);
            p.sprite.position = ccp(80+(170*(i%6)), 120*line);
            
            [self addChild: p.sprite];
            [players addObject:p];
            [playersMap setObject:p forKey:p.name];
        }
        
        [engin run];
	}
    
	return self;
}

-(void) initPlayersWithJudge: (NSString*) judgeName {
    NSMutableArray* newPlayers = [NSMutableArray new];
    for(int i = 0; i < engin.players.count; i++) {
        CCPlayer* p = [engin.players objectAtIndex:i];
        
        if([p class] == [CCPlayer class] || [p.name isEqualToString:judgeName]) {
            p.role = [p.name isEqualToString:judgeName]?Judge:Citizen;
            [newPlayers addObject:p];
        } else if([p class] == [CCDoubleHandPlayer class]){
            CCDoubleHandPlayer* dhp = ((CCDoubleHandPlayer*)p);
            dhp.leftHandPlayer = [[CCHandPlayer alloc] init: [p.name stringByAppendingString:@"左手"] withRole: Citizen];
            dhp.rightHandPlayer = [[CCHandPlayer alloc] init: [p.name stringByAppendingString:@"右手"] withRole: Citizen];
            
            [playersMap setObject:dhp.leftHandPlayer forKey: dhp.leftHandPlayer.name];
            [playersMap setObject:dhp.rightHandPlayer forKey: dhp.rightHandPlayer.name];
            
            [players addObject:dhp.leftHandPlayer];
            [players addObject:dhp.rightHandPlayer];
            [newPlayers addObject:dhp.leftHandPlayer];
            [newPlayers addObject:dhp.rightHandPlayer];
        }
    }
    
    [engin setPlayers: newPlayers];
}

#pragma mark CCEnginDisplayDelegate
-(void) backupActionIcon {
    for(CCPlayer* p in players) {
        [p backupActionIcons];
    }
}

-(void) restoreBackupActionIcon {
    for(CCPlayer* p in players) {
        [p restoreActionIcons];
    }
}

-(void) addActionIcon: (Role) role to: (Player*) player {
    CCPlayer* p = [playersMap objectForKey:player.name];
    [p addActionIcon: role];
}

-(void) removeActionIconFrom: (Player*) player {
    CCPlayer* p = [playersMap objectForKey:player.name];
    [p removeLastActionIcon];
}

-(void) updatePlayerLabels {
}

-(void) resetPlayerIcons: (NSArray*) players {
    for(CCPlayer* player in players) {
        CCPlayer* p = [playersMap objectForKey:player.name];
        [p updatePlayerIcon];
    }
}

-(void) updatePlayerIcons {
    for(CCPlayer* player in engin.players) {
        CCPlayer* p = [playersMap objectForKey:player.name];
        [p updatePlayerIcon];
    }
}

-(void) showPlayerDebugMessage: (Player *) player inIncrement: (BOOL) increment {
    [self showDebugMessage:[player toString] inIncrement: increment];
}

-(void) showDebugMessage: (NSString *) message inIncrement: (BOOL) increment {
    if(showDebugMessageEnable) {
        if(increment) {
            debugLabel.string = [[debugLabel.string stringByAppendingString:@"\n"] stringByAppendingString:message];
        } else {
            debugLabel.string = message;
        }
    }
}


-(void) showMessage: (NSString *) message {
    messageLabel.string = message;
    NSLog(@"%@", message);
}

-(void) showNightMessage: (long) i {
    nightLabel.string = [NSString stringWithFormat:@"第%li%@", i, @"夜"];
}


-(void) definePlayerForRole: (Role) r {
    rolePlayerToDefine = r;
}

-(void) gameFinished {
    CCMenuItem *restarMenuItem = [CCMenuItemImage itemFromNormalImage:@"restart.png" selectedImage:@"restart.png"
        block:^(id sender){
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[SelectPlayerLayer scene] ]];
        }];
    restarMenuItem.position = ccp(260, [[CCDirector sharedDirector] winSize].height-200);
    CCMenu *restarMenu = [CCMenu menuWithItems:restarMenuItem, nil];
    restarMenu.position = CGPointZero;
    [self addChild:restarMenu];
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
