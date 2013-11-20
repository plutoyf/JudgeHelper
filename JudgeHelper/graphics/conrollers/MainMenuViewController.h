//
//  MainMenuViewController.h
//  JudgeHelper
//
//  Created by fyang on 14/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Engin.h"

@interface MainMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    
    Engin *engin;
    
    NSMutableArray* selectedPIds;
    NSMutableArray* pids;
    
    NSArray *roles;
    NSMutableDictionary *roleNumbers;
    int maxRoleNumber;
    int staticRoleNumber;
}

@property (weak, nonatomic) IBOutlet UITableView *playerTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *playerCollectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *roleCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *roleImageView;
@property (weak, nonatomic) IBOutlet UIPickerView *roleNumberPicker;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *createPlayerButton;
@property (weak, nonatomic) IBOutlet UISwitch *doubleHandModeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *doubleHandModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UIView *bottomBarView;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UIView *leftPlayerView;
@property (weak, nonatomic) IBOutlet UIView *rightPlayerView;
@property (weak, nonatomic) IBOutlet UIView *leftRoleView;
@property (weak, nonatomic) IBOutlet UIView *rightRoleView;

- (void) didFinishedCreatingPlayerWithId:(NSString *)pid;
- (IBAction)nextButtonTapped:(id)sender;
- (IBAction)createPlayerButtonTapped:(id)sender;
- (IBAction)doubleHandModeSwitchChanged:(id)sender;

@end
