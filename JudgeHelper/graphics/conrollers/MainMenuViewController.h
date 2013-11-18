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

@property (strong, nonatomic) IBOutlet UICollectionView *roleCollectionView;
@property (strong, nonatomic) IBOutlet UIImageView *roleImageView;
@property (strong, nonatomic) IBOutlet UIPickerView *roleNumberPicker;

@property (weak, nonatomic) IBOutlet UIButton *modifyPlayerButton;
@property (weak, nonatomic) IBOutlet UIButton *modifyRoleButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIView *leftBodyView;
@property (weak, nonatomic) IBOutlet UIView *rightBodyView;

@property (strong, nonatomic) IBOutlet UIView *leftPlayerView;
@property (strong, nonatomic) IBOutlet UIView *rightPlayerView;
@property (strong, nonatomic) IBOutlet UIView *leftRoleView;
@property (strong, nonatomic) IBOutlet UIView *rightRoleView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftPlayerViewSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightPlayerViewSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftRoleViewSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightRoleViewSpace;

- (IBAction)nextButtonTapped:(id)sender;
- (IBAction)modifyPlayerButtonTapped:(id)sender;
- (IBAction)ModifyRoleButtonTapped:(id)sender;

@end
