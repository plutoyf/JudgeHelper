//
//  MainMenuViewController.h
//  JudgeHelper
//
//  Created by fyang on 14/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuViewController : UIViewController <UITableViewDataSource> {
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *tweetsArray;

- (IBAction)nextButtonTapped:(id)sender;

@end
