//
//  GameViewController.m
//  JudgeHelper
//
//  Created by YANG FAN on 25/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "GameViewController.h"
#import "GlobalSettings.h"
#import "CCEngin.h"
#import "UIPlayer.h"

@interface GameViewController ()

@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

NSMutableDictionary *playersMap;
NSMutableArray *players;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CCEngin *engin = [CCEngin getEngin];
    engin.displayDelegate = self;
    
    // init players without role
    GlobalSettings* global = [GlobalSettings globalSettings];
    playersMap = [[NSMutableDictionary alloc] init];
    players = [[NSMutableArray alloc] init];
    NSArray* ids = [global getPlayerIds];

    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    id obj = [userDefaults objectForKey:@"pids"];
    ids = obj==nil ? [NSMutableArray new] : [NSMutableArray arrayWithArray:obj];

    int n = 0;
    for(NSString* id in ids) {
        NSString* name = [[NSUserDefaults standardUserDefaults] objectForKey:[id stringByAppendingString:@"-name"]];
        NSData* imgData = [[NSUserDefaults standardUserDefaults] dataForKey:[id stringByAppendingString:@"-img"]];
        UIImage* image = [UIImage imageWithData:imgData];
        
        UIPlayer *p = [[UIPlayer alloc] init: id andName: name withRole: Citizen];
        PlayerView *pv = [[[NSBundle mainBundle] loadNibNamed:@"PlayerView" owner:self options:nil] objectAtIndex:0];
        p.view = pv;
        p.view.name.text = name;
        //p.view.imageView.image = image;
        [self.tableView addSubview: pv];
        [players addObject:p];
        [playersMap setObject:p forKey:id];
    }
    [engin setPlayers: players];
    
    [engin run];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addPlayersStatusWithActorRole: (Role) role andReceiver: (Player*) receiver andResult: (BOOL) result {
    
}
-(void) rollbackPlayersStatus {
    
}
-(void) backupActionIcon {
    
}
-(void) restoreBackupActionIcon {
    
}
-(void) addActionIcon: (Role) role to: (Player*) player withResult: (BOOL) result {
    
}
-(void) removeActionIconFrom: (Player*) player {
    
}
-(void) updatePlayerLabels {
    
}
-(void) resetPlayerIcons: (NSArray*) players {
    
}
-(void) updatePlayerIcons {
    
}
-(void) updateEligiblePlayers: (NSArray*) players withBypass: (BOOL) showBypass {
    
}
-(void) showDebugMessage: (NSString*) message inIncrement: (BOOL) increment {
    
}
-(void) showPlayerDebugMessage: (Player *) player inIncrement: (BOOL) increment {
    
}
-(void) showMessage: (NSString *) message {
    
}
-(void) showNightMessage: (long) i {
    
}
-(void) definePlayerForRole: (Role) r {
    
}
-(void) gameFinished {
    
}

@end
