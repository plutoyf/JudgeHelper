//
//  RoleCollectionViewCell.h
//  JudgeHelper
//
//  Created by YANG FAN on 16/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Role.h"

@interface RoleCollectionViewCell : UICollectionViewCell

@property (nonatomic) Role role;
@property (strong, nonatomic) IBOutlet UIImageView *roleImage;
@property (strong, nonatomic) IBOutlet UILabel *roleLabel;
@property (strong, nonatomic) IBOutlet UILabel *roleNumber;

@end
