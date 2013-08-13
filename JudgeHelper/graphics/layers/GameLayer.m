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
#import "GlobalSettings.h"
#import "RuleResolver.h"
#import "CCNode+SFGestureRecognizers.h"

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

- (void) selectPlayerById: (NSString*) id {
    CCPlayer* selPlayer = (CCPlayer*)[playersMap objectForKey:id];
    
    id = (selPlayer.role == Judge) ? nil : selPlayer.id;
    
    if(rolePlayerToDefine > 0) {
        if(!defineRolePlayerBegin) {
            [self showMessage: [NSString stringWithFormat:@"请设定“%@”角色玩家", [engin getRoleLabel: rolePlayerToDefine]]];
            defineRolePlayerBegin = YES;
        } else {
            if(selPlayer && (selPlayer.role == 0 || selPlayer.role == Citizen)) {
                // select this player as role
                [engin getPlayerById:selPlayer.id].role = rolePlayerToDefine;
                if(rolePlayerToDefine == Judge) {
                    [self initPlayersWithJudge: id];
                }
                
                if([engin getRoleNumber:rolePlayerToDefine] == [engin getPlayersByRole:rolePlayerToDefine].count) {
                    rolePlayerToDefine = 0;
                    defineRolePlayerBegin = NO;
                    [engin action: id];
                }
            }
        }
    } else {
        [engin action: id];
    }
}


BOOL showDebugMessageEnable = NO;
// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        
        self.isTouchEnabled = YES;
        UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emptyClick:)];
        tapGestureRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapGestureRecognizer];
		
        engin = [CCEngin getEngin];
        engin.displayDelegate = self;
        
        // ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];

        nightLabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:28];
        nightLabel.position = ccp(60 , size.height-100 );
        [self addChild: nightLabel];
        
		// create and initialize a Label
		// position the label on the center of the screen
		messageLabel = [CCLabelTTF labelWithString:@"Killer" fontName:@"Marker Felt" fontSize:64];
        messageLabel.position = ccp( size.width /2 , size.height/2-(showDebugMessageEnable?200:0) );
        [self addChild: messageLabel z:1];
        
        if(showDebugMessageEnable) {
            debugLabel = [CCLabelTTF labelWithString:@"debug : " fontName:@"Marker Felt" fontSize:13];
            debugLabel.position = ccp(600 , size.height-280 );
            debugLabel.tag = 11;
            [self addChild: debugLabel];
        }
        
        // init players without role
        GlobalSettings* global = [GlobalSettings globalSettings];
        playersMap = [[NSMutableDictionary alloc] init];
        players = [[NSMutableArray alloc] init];
        NSArray* ids = [global getPlayerIds];
        int pNum = ids.count;
        for(int i = 0; i < pNum; i++) {
            CCPlayer* p = ([global getGameMode] == DOUBLE_HAND) ? [[CCDoubleHandPlayer alloc] init:(NSString*)[ids objectAtIndex:i]] : [[CCPlayer alloc] init:(NSString*)[ids objectAtIndex:i]];
            
            int line = (int)((i+6)/6);
            p.sprite.position = ccp(80+(170*(i%6)), 120*line);
            p.delegate = self;
            
            [self addChild: p.sprite];
            [players addObject:p];
            [playersMap setObject:p forKey:p.id];
        }
        [engin setPlayers: players];
        
        [engin run];
	}
    
	return self;
}

-(void) emptyClick: (UITapGestureRecognizer*) sender {
    [self selectPlayerById: nil];
}

-(void) initPlayersWithJudge: (NSString*) judgeId {
    NSMutableArray* newPlayers = [NSMutableArray new];
    for(int i = 0; i < engin.players.count; i++) {
        CCPlayer* p = [engin.players objectAtIndex:i];
        
        if([p class] == [CCPlayer class] || [p.id isEqualToString:judgeId]) {
            p.role = [p.id isEqualToString:judgeId]?Judge:Citizen;
            [newPlayers addObject:p];
        } else if([p class] == [CCDoubleHandPlayer class]){
            CCDoubleHandPlayer* dhp = ((CCDoubleHandPlayer*)p);
            dhp.leftHandPlayer = [[CCHandPlayer alloc] init: [p.id stringByAppendingString:@"l"] andName: [p.name stringByAppendingString:@"左手"] withRole: Citizen];
            dhp.leftHandPlayer.delegate = self;
            
            dhp.rightHandPlayer = [[CCHandPlayer alloc] init: [p.id stringByAppendingString:@"r"] andName: [p.name stringByAppendingString:@"右手"] withRole: Citizen];
            dhp.rightHandPlayer.delegate = self;
            
            [playersMap setObject:dhp.leftHandPlayer forKey: dhp.leftHandPlayer.id];
            [playersMap setObject:dhp.rightHandPlayer forKey: dhp.rightHandPlayer.id];
            
            [players addObject:dhp.leftHandPlayer];
            [players addObject:dhp.rightHandPlayer];
            [newPlayers addObject:dhp.leftHandPlayer];
            [newPlayers addObject:dhp.rightHandPlayer];
        }
    }
    
    [engin setPlayers: newPlayers];
    
    gameStateSprite = [[GameStateSprite alloc] init];
    [self addChild: gameStateSprite z:2];
    
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

-(void) addActionIcon: (Role) role to: (Player*) player withResult:(BOOL)result{
    CCPlayer* p = [playersMap objectForKey:player.id];
    [p addActionIcon: role withResult: result];
}

-(void) removeActionIconFrom: (Player*) player {
    CCPlayer* p = [playersMap objectForKey:player.id];
    [p removeLastActionIcon];
}

-(void) updatePlayerLabels {
}

-(void) resetPlayerIcons: (NSArray*) players {
    for(CCPlayer* player in players) {
        CCPlayer* p = [playersMap objectForKey:player.id];
        [p updatePlayerIcon];
    }
}

-(void) updatePlayerIcons {
    for(CCPlayer* player in engin.players) {
        CCPlayer* p = [playersMap objectForKey:player.id];
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
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[SelectPlayerLayer scene] ]];
        }];
    CGSize size = [[CCDirector sharedDirector] winSize];
    restarMenuItem.position = ccp(size.width/2, size.height/2+100);
    CCMenu *restarMenu = [CCMenu menuWithItems:restarMenuItem, nil];
    restarMenu.position = CGPointZero;
    [self addChild:restarMenu];
}

-(void) addPlayersStatusWithActorRole: (Role) role andReceiver: (Player*) receiver  andResult: (BOOL) result{
    [gameStateSprite addNewStatusWithActorRole:role andReceiver:receiver andResult:result];
}

-(void) rollbackPlayersStatus {
    [gameStateSprite revertStatus];
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
