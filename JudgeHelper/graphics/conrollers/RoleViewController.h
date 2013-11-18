//
//  RoleViewController.h
//  JudgeHelper
//
//  Created by YANG FAN on 16/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    
}

@property (strong, nonatomic) IBOutlet UICollectionView *roleCollectionView;
@property (strong, nonatomic) IBOutlet UIImageView *roleImageView;
@property (strong, nonatomic) IBOutlet UIPickerView *roleNumberPicker;
@property (strong, nonatomic) IBOutlet UITableView *roleTableView;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)actionButtonTapped:(id)sender;
- (IBAction)backButtonTapped:(id)sender;

@end
