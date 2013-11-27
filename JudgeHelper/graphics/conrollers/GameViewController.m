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
#import "UIDoubleHandPlayer.h"

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
    
    engin = [CCEngin getEngin];
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
        p.delegate = self;
        PlayerView *pv = [[[NSBundle mainBundle] loadNibNamed:@"PlayerView" owner:self options:nil] objectAtIndex:0];
        pv.delegate = p;
        pv.translatesAutoresizingMaskIntoConstraints = NO;
        [self.tableView addSubview: pv];
        
        [pv addConstraint:[NSLayoutConstraint constraintWithItem:pv attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:80.f]];
        [pv addConstraint:[NSLayoutConstraint constraintWithItem:pv attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:80.f]];
        [pv.imageView addConstraint:[NSLayoutConstraint constraintWithItem:pv.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:80.f]];
        [pv.imageView addConstraint:[NSLayoutConstraint constraintWithItem:pv.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:80.f]];
        [pv layoutIfNeeded];
        
        // test
        CGRect rect = pv.frame;
        rect.origin.x += 100*n;
        pv.frame = rect;
        
        p.view = pv;
        p.view.name.text = name;
        p.view.imageView.image = image;
        [players addObject:p];
        [playersMap setObject:p forKey:id];
        
        n++;
    }
    [engin setPlayers: players];
    
    [engin run];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) initPlayersWithJudge: (NSString*) judgeId {
    NSMutableArray* newPlayers = [NSMutableArray new];
    for(int i = 0; i < engin.players.count; i++) {
        UIPlayer* p = [engin.players objectAtIndex:i];
        
        if([p class] == [UIPlayer class] || [p.id isEqualToString:judgeId]) {
            p.role = [p.id isEqualToString:judgeId]?Judge:Citizen;
            [newPlayers addObject:p];
        } else if([p class] == [UIDoubleHandPlayer class]){
            UIDoubleHandPlayer* dhp = ((UIDoubleHandPlayer*)p);
            dhp.leftHandPlayer = [[UIHandPlayer alloc] init: [p.id stringByAppendingString:@"l"] andName: [p.name stringByAppendingString:@"左手"] withRole: Citizen];
            dhp.leftHandPlayer.delegate = self;
            
            dhp.rightHandPlayer = [[UIHandPlayer alloc] init: [p.id stringByAppendingString:@"r"] andName: [p.name stringByAppendingString:@"右手"] withRole: Citizen];
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
}

-(BOOL) isEligiblePlayer: (NSString*) id {
    if(!id) {
        return NO;
    }
    
    if(withBypass && id == [Engin getRoleName:Game]) {
        return YES;
    }
    
    if(eligiblePlayers) {
        for(Player* p in eligiblePlayers) {
            if(p.id == id) {
                return YES;
            }
        }
    } else {
        return YES;
    }
    
    return NO;
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
    UIPlayer* p = [playersMap objectForKey:player.id];
    [p addActionIcon: role withResult: result];
    
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
    self.messageLabel.text = message;
    NSLog(@"%@", message);
}

-(void) showNightMessage: (long) i {
    self.nightLabel.text = [NSString stringWithFormat:@"第%li%@", i, @"夜"];
}

-(void) definePlayerForRole: (Role) r {
    rolePlayerToDefine = r;
    defineRolePlayerBegin = NO;
}

-(void) gameFinished {
    
}


- (IBAction)emptyClick:(id)sender {
    [self selectPlayerById: nil];
}


- (void) selectPlayerById: (NSString*) id {
    UIPlayer* selPlayer = (UIPlayer*)[playersMap objectForKey:id];
    
    id = (selPlayer.role == Judge) ? (withBypass ? [Engin getRoleName:Game] : nil) : selPlayer.id;
    
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
                
                if([engin didFinishedSettingPlayerForRole: rolePlayerToDefine]) {
                    rolePlayerToDefine = 0;
                    defineRolePlayerBegin = NO;
                    [engin action: id];
                }
            }
        }
    } else {
        if(id == nil || [self isEligiblePlayer : id]) {
            [engin action: id];
        }
    }
}

-(void) selectAllPlayersToMove {
    
}
-(void) playerPositionChanged : (UIPlayer*) player {
    
}
-(void) superLongPressPlayer : (UIPlayer*) player {
    
}
-(void) movePlayer: (UIPlayer*) player toPosition: (CGPoint) point {
    
}

@end
