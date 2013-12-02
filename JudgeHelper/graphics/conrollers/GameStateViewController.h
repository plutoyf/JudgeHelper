//
//  GameStateViewController.h
//  JudgeHelper
//
//  Created by YANG FAN on 01/12/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Role.h"
#import "Player.h"
#import "CCEngin.h"

@interface GameStateViewController : UIViewController {
    CCEngin* engin;
    NSMutableDictionary* playerLines;
    NSMutableDictionary* playerVisibleObjects;
    NSMutableDictionary* playerLifeBoxes;
    NSMutableArray* pIds;
    
    UIView *bodyView;
    BOOL isInitFinished;
}

@property (retain, nonatomic) UIView *bodyView;

@property (weak, nonatomic) IBOutlet UIView *stateView;
@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UIButton *hideStateButton;

-(void) addNewStatusWithActorRole: (Role) role andReceiver: (Player*) receiver andResult: (BOOL) result;
-(void) revertStatus;

@end
