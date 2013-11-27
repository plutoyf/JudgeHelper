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
    playersMap = [[NSMutableDictionary alloc] init];
    players = [[NSMutableArray alloc] init];
    
    GlobalSettings* global = [GlobalSettings globalSettings];
    NSArray* ids = [global getPlayerIds];

    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    id obj = [userDefaults objectForKey:@"pids"];
    ids = obj==nil ? [NSMutableArray new] : [NSMutableArray arrayWithArray:obj];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:.8f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:.8f constant:0.f]];
    
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
        [self.playerView addSubview: pv];
        
        [pv addConstraint:[NSLayoutConstraint constraintWithItem:pv attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:80.f]];
        [pv addConstraint:[NSLayoutConstraint constraintWithItem:pv attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:80.f]];
        [pv.imageView addConstraint:[NSLayoutConstraint constraintWithItem:pv.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:80.f]];
        [pv.imageView addConstraint:[NSLayoutConstraint constraintWithItem:pv.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:80.f]];
        
        [pv layoutIfNeeded];
        
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    UIPlayer *player = [players firstObject];
    float bWidth = self.playerView.bounds.size.width;
    float bHeight = self.playerView.bounds.size.height;
    tableZone = [[TableZone alloc] init:self.tableView.frame.size.width :self.tableView.frame.size.height :bWidth :bHeight :player.view.bounds.size.width :player.view.bounds.size.height];
    
    int n = 0;
    for(UIPlayer *player in players) {
        if([self findConstraintWithItem:player.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeCenterX from:self.playerView.constraints] == nil) {
            [self.playerView addConstraint:[NSLayoutConstraint constraintWithItem:player.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeCenterX multiplier:[self getMultiplier:(player.view.frame.size.width*1.5)*n+player.view.frame.size.width/2 :bWidth] constant:0]];
        }
        if([self findConstraintWithItem:player.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeCenterY from:self.playerView.constraints] == nil) {
            [self.playerView addConstraint:[NSLayoutConstraint constraintWithItem:player.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeCenterY multiplier:[self getMultiplier:player.view.frame.size.height/2 :bHeight]  constant:0.f]];
        }
        
        [player.view layoutIfNeeded];
        
        n++;
    }
}

- (NSLayoutConstraint*)findConstraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 from:(NSArray*)contraints {
    for(NSLayoutConstraint *c in contraints) {
        if(c.firstItem == view1 && c.firstAttribute == attr1 && c.relation == relation && c.secondItem == view2 && c.secondAttribute == attr2) {
            return c;
        }
    }
    return nil;
}

- (float)getMultiplier:(float)d :(float)b {
    return 2*d/b;
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
    CGPoint point = player.view.frame.origin;
    point.x += player.view.frame.size.width/2;
    point.y += player.view.frame.size.height/2;
    if([tableZone isInside:point]) {
        point = [tableZone getBestPosition:point];
        point.x -= player.view.frame.size.width/2;
        point.y -= player.view.frame.size.height/2;
        
        if(point.x != player.view.frame.origin.x || point.y != player.view.frame.origin.y) {
            [UIView animateWithDuration:0.25 animations:^{
                CGRect rect = player.view.frame;
                rect.origin.x = point.x;
                rect.origin.y = point.y;
                player.view.frame = rect;
            }];
        }
        //player.settled = YES;
    } else {
        //player.settled = NO;
    }
    //player.readyToMove = NO;
    //player.position = [tableZone getPlayerPosition:point];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%f,%f", point.x, point.y] forKey:[player.id stringByAppendingString:@"-pos"]];

    
    float bWidth = self.playerView.bounds.size.width;
    float bHeight = self.playerView.bounds.size.height;
    
    [self.playerView removeConstraint:[self findConstraintWithItem:player.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeCenterX from:self.playerView.constraints]];
    [self.playerView removeConstraint:[self findConstraintWithItem:player.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeCenterY from:self.playerView.constraints]];
    
    [self.playerView addConstraint:[NSLayoutConstraint constraintWithItem:player.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeCenterX multiplier:[self getMultiplier:player.view.frame.origin.x+player.view.frame.size.width/2 :bWidth] constant:0.f]];
    [self.playerView addConstraint:[NSLayoutConstraint constraintWithItem:player.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeCenterY multiplier:[self getMultiplier:player.view.frame.origin.y+player.view.frame.size.height/2 :bHeight]  constant:0.f]];
    
    [player.view layoutIfNeeded];
}

-(void) superLongPressPlayer : (UIPlayer*) player {
    
}
-(void) movePlayer: (UIPlayer*) player toPosition: (CGPoint) point {
    
}

@end
