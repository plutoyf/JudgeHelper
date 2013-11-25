//
//  GameViewController.h
//  JudgeHelper
//
//  Created by YANG FAN on 25/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCEngin.h"

@interface GameViewController : UIViewController<CCEnginDisplayDelegate>

@property (weak, nonatomic) IBOutlet UIView *tableView;

@end
