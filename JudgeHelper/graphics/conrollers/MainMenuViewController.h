//
//  MainMenuViewController.h
//  JudgeHelper
//
//  Created by fyang on 14/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource> {
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)nextButtonTapped:(id)sender;

@end
