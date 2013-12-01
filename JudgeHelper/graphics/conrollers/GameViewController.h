//
//  GameViewController.h
//  JudgeHelper
//
//  Created by YANG FAN on 25/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCEngin.h"
#import "UIPlayer.h"
#import "TableZone.h"
#import "TableView.h"
#import "GameStateViewController.h"

@interface GameViewController : UIViewController<CCEnginDisplayDelegate, UIPlayerControleDelegate> {
    BOOL layoutInited;
    TableZone *tableZone;
    UIPlayer* selPlayer;
    BOOL selPlayerInMove;
    NSMutableDictionary* playersMap;
    NSMutableArray* players;
    NSArray* eligiblePlayers;
    Role rolePlayerToDefine;
    BOOL defineRolePlayerBegin;
    BOOL withBypass;
    
    CCEngin* engin;
    GameStateViewController *gameStateViewController;
}

@property (weak, nonatomic) IBOutlet TableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UILabel *nightLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *showStateButton;

- (IBAction)emptyClick:(id)sender;
- (IBAction)showStateButtonTapped:(id)sender;

@end
