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

@interface GameViewController : UIViewController<CCEnginDisplayDelegate, UIPlayerControleDelegate> {
    
    UIPlayer* selPlayer;
    BOOL selPlayerInMove;
    NSMutableDictionary* playersMap;
    NSMutableArray* players;
    NSArray* eligiblePlayers;
    Role rolePlayerToDefine;
    BOOL defineRolePlayerBegin;
    BOOL withBypass;
    
    CCEngin* engin;
}

@property (weak, nonatomic) IBOutlet UIView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *nightLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (IBAction)emptyClick:(id)sender;

@end
