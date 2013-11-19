//
//  PlayerCreationView.h
//  JudgeHelper
//
//  Created by fyang on 18/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerCreationView : UIView <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate> {
}

@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) UIView *shieldView;

@property (weak, nonatomic) IBOutlet UILabel *addImageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *playerImage;
@property (weak, nonatomic) IBOutlet UITextField *playerName;

- (IBAction)playerImageTapped:(id)sender;
- (IBAction)createButtonTapped:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;

@end
