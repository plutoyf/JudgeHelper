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
#import "AppDelegate.h"

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
    
    layoutInited = NO;
    
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

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:.7f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:.7f constant:0.f]];
    
    int n = 0;
    for(NSString* id in ids) {
        NSString* name = [[NSUserDefaults standardUserDefaults] objectForKey:[id stringByAppendingString:@"-name"]];
        NSData* imgData = [[NSUserDefaults standardUserDefaults] dataForKey:[id stringByAppendingString:@"-img"]];
        UIImage* image = [UIImage imageWithData:imgData];
        
        UIPlayer* p = ([global getGameMode] == DOUBLE_HAND) ? [[UIDoubleHandPlayer alloc] init:id andName: name withRole: Citizen] : [[UIPlayer alloc] init:id andName: name withRole: Citizen];
        p.delegate = self;
        PlayerView *pv = [[[NSBundle mainBundle] loadNibNamed:@"PlayerView" owner:self options:nil] objectAtIndex:0];
        pv.delegate = p;
        pv.translatesAutoresizingMaskIntoConstraints = NO;
        [self.playerView addSubview: pv];
        
        [pv addConstraint:[NSLayoutConstraint constraintWithItem:pv attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(80)]];
        [pv addConstraint:[NSLayoutConstraint constraintWithItem:pv attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(80)]];
        [pv.imageView addConstraint:[NSLayoutConstraint constraintWithItem:pv.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(80)]];
        [pv.imageView addConstraint:[NSLayoutConstraint constraintWithItem:pv.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(80)]];
        
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
    
    
    UIButton *undoButton = [UIButton new];
    [undoButton addTarget:self
                      action:@selector(undoButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    [undoButton setImage:[UIImage imageNamed:@"undo.png"] forState:UIControlStateNormal];
    [undoButton setImage:[UIImage imageNamed:@"undo-sel.png"] forState:UIControlStateSelected];
    
    [undoButton addConstraint:[NSLayoutConstraint constraintWithItem:undoButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(80)]];
    [undoButton addConstraint:[NSLayoutConstraint constraintWithItem:undoButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(80)]];
    
    undoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:undoButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:undoButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:undoButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];

    
    UIButton *redoButton = [UIButton new];
    [redoButton addTarget:self
                      action:@selector(redoButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    [redoButton setImage:[UIImage imageNamed:@"redo.png"] forState:UIControlStateNormal];
    [redoButton setImage:[UIImage imageNamed:@"redo-sel.png"] forState:UIControlStateSelected];
    
    [redoButton addConstraint:[NSLayoutConstraint constraintWithItem:redoButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(80)]];
    [redoButton addConstraint:[NSLayoutConstraint constraintWithItem:redoButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(80)]];
    
    redoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:redoButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:redoButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:redoButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:undoButton attribute:NSLayoutAttributeTrailing multiplier:1.f constant:20.f]];

    
    UIButton *quitButton = [UIButton new];
    [quitButton addTarget:self
                      action:@selector(quitButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    [quitButton setImage:[UIImage imageNamed:@"quit.png"] forState:UIControlStateNormal];
    [quitButton setImage:[UIImage imageNamed:@"quit-sel.png"] forState:UIControlStateSelected];
    
    [quitButton addConstraint:[NSLayoutConstraint constraintWithItem:quitButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(80)]];
    [quitButton addConstraint:[NSLayoutConstraint constraintWithItem:quitButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(80)]];
    
    quitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:quitButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:quitButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:quitButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:redoButton attribute:NSLayoutAttributeTrailing multiplier:1.f constant:20.f]];

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    UIPlayer *player = [players firstObject];
    float bWidth = self.playerView.bounds.size.width;
    float bHeight = self.playerView.bounds.size.height;
    float tWidth = self.tableView.frame.size.width;
    float tHeight = self.tableView.frame.size.height;
    float pWidth = player.view.bounds.size.width;
    float pHeight = player.view.bounds.size.height;
    float dx = self.tableView.frame.origin.x;
    float dy = self.tableView.frame.origin.y;
    tableZone = [[TableZone alloc] init:tWidth :tHeight :bWidth :bHeight :pWidth :pHeight];
    
    if(!layoutInited) {
        int n = 0, i = 0, j = 0;
        float m = (tWidth-pWidth)/(pWidth*2);
        
        for(UIPlayer *player in players) {
            if(i >= m) {
                i = 0;
                j++;
            }
            
            [self.playerView addConstraint:[NSLayoutConstraint constraintWithItem:player.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeCenterX multiplier:[self getMultiplier:pWidth*2*i+pWidth :bWidth] constant:dx]];
            [self.playerView addConstraint:[NSLayoutConstraint constraintWithItem:player.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeCenterY multiplier:[self getMultiplier:pHeight*1.5*j+pHeight :bHeight] constant:dy]];
            
            [player.view layoutIfNeeded];
            
            n++;
            i++;
        }
        layoutInited = YES;
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
            
            [dhp hideRoleInfo];
            [dhp showRoleInfo];
        }
    }
    
    [engin setPlayers: newPlayers];
}



-(void) addPlayersStatusWithActorRole: (Role) role andReceiver: (Player*) receiver  andResult: (BOOL) result{
    //[gameStateSprite addNewStatusWithActorRole:role andReceiver:receiver andResult:result];
}

-(void) rollbackPlayersStatus {
    //[gameStateSprite revertStatus];
}

-(void) backupActionIcon {
    for(UIPlayer* p in players) {
        [p backupActionIcons];
    }
}

-(void) restoreBackupActionIcon {
    for(UIPlayer* p in players) {
        [p restoreActionIcons];
    }
}
-(void) addActionIcon: (Role) role to: (Player*) player withResult: (BOOL) result {
    UIPlayer* p = [playersMap objectForKey:player.id];
    [p addActionIcon: role withResult: result];
    
}
-(void) removeActionIconFrom: (Player*) player {
    UIPlayer* p = [playersMap objectForKey:player.id];
    [p removeLastActionIcon];
}

-(void) updatePlayerLabels {
}

-(void) resetPlayerIcons: (NSArray*) players {
    for(UIPlayer* player in players) {
        UIPlayer* p = [playersMap objectForKey:player.id];
        [p updatePlayerIcon];
    }
}

-(void) updatePlayerIcons {
    for(UIPlayer* player in engin.players) {
        UIPlayer* p = [playersMap objectForKey:player.id];
        [p updatePlayerIcon];
    }
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

-(void) updateEligiblePlayers: (NSArray*) players withBypass: (BOOL) showBypass {
    eligiblePlayers = players;
    withBypass = showBypass;
}


-(void) showDebugMessage: (NSString*) message inIncrement: (BOOL) increment {
    /*
     if(showDebugMessageEnable) {
        if(increment) {
            debugLabel.string = [[debugLabel.string stringByAppendingString:@"\n"] stringByAppendingString:message];
        } else {
            debugLabel.string = message;
        }
    }
     */
}

-(void) showPlayerDebugMessage: (Player *) player inIncrement: (BOOL) increment {
    [self showDebugMessage:[player toString] inIncrement: increment];
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
    UIButton *restartButton = [UIButton new];
    [restartButton addTarget:self
                      action:@selector(restartButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    [restartButton setImage:[UIImage imageNamed:@"restart.png"] forState:UIControlStateNormal];
    [restartButton setImage:[UIImage imageNamed:@"restart-sel.png"] forState:UIControlStateSelected];
    
    [restartButton addConstraint:[NSLayoutConstraint constraintWithItem:restartButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(80)]];
    [restartButton addConstraint:[NSLayoutConstraint constraintWithItem:restartButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.f constant:REVERSE(80)]];
    
    restartButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:restartButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:restartButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:restartButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:.8f constant:0.f]];
    
    [self.view layoutIfNeeded];

}

- (IBAction)restartButtonTapped:(id)sender {
    [((AppController*)[[UIApplication sharedApplication] delegate]).navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)undoButtonTapped:(id)sender {
    [engin action: @"UNDO_ACTION"];
}

- (IBAction)redoButtonTapped:(id)sender {
    [engin action: @"REDO_ACTION"];
}

- (IBAction)quitButtonTapped:(id)sender {
    [((AppController*)[[UIApplication sharedApplication] delegate]).navigationController popToRootViewControllerAnimated:YES];
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
