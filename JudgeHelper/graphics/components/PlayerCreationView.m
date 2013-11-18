//
//  PlayerCreationView.m
//  JudgeHelper
//
//  Created by fyang on 18/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PlayerCreationView.h"
#import "MainMenuViewController.h"
#import "AppDelegate.h"

@implementation PlayerCreationView

static CGFloat const kDashedBorderWidth     = (2.0f);
static CGFloat const kDashedPhase           = (0.0f);
static CGFloat const kDashedLinesLength[]   = {4.0f, 2.0f};
static size_t const kDashedCount            = (2.0f);

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, kDashedBorderWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextSetLineDash(context, kDashedPhase, kDashedLinesLength, kDashedCount) ;
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)showImagePicker: (UIImagePickerControllerSourceType) sourceType {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.wantsFullScreenLayout = YES;
    if([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        picker.sourceType = sourceType;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    UINavigationController *navigationController =  ((AppController*)[[UIApplication sharedApplication] delegate]).navigationController;
    [navigationController presentModalViewController:picker animated:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
    } else {
        [self showImagePicker: buttonIndex==1 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary];
    }
}


- (IBAction)playerImageTapped:(id)sender {
     UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Choose photo"
                                                   message:@""
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Use Camera", @"Use Album", nil];

     [alert show];
}

- (IBAction)createButtonTapped:(id)sender {
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Player"
                                                    message:@"This functionality is being develepped."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
     */
    UIImage *image = self.playerImage.image;
    NSString *name = self.playerName.text;
    if(image!=nil && name.length > 0) {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * const pidsKey = @"pids";
        id obj = [userDefaults objectForKey:pidsKey];
        NSMutableArray* pids = obj==nil ? [NSMutableArray new] : [NSMutableArray arrayWithArray:obj];

        NSString* id = [NSNumber numberWithLong: (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970])].stringValue;
        [pids addObject:id];
        [userDefaults setObject:pids forKey:pidsKey];
        [userDefaults setObject:name forKey:[id stringByAppendingString:@"-name"]];
        [userDefaults setObject:UIImagePNGRepresentation(image) forKey:[id stringByAppendingString:@"-img"]];
        [userDefaults synchronize];
        
        UINavigationController *navigationController = ((AppController*)[[UIApplication sharedApplication] delegate]).navigationController;
        MainMenuViewController *rootViewController = (MainMenuViewController*)[navigationController.viewControllers objectAtIndex:0];
        [rootViewController reloadPlayers];
        
        [self cancelButtonTapped:nil];
    }

}

- (IBAction)cancelButtonTapped:(id)sender {
    [UIView animateWithDuration:.2 animations:^(void) {
        [self setFrame:CGRectOffset([self frame], 0, -self.bounds.size.height)];
    } completion:^(BOOL Finished) {
        [self removeFromSuperview];
    }];
    [self.shieldView removeFromSuperview];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [picker dismissModalViewControllerAnimated:YES];
    [picker.view removeFromSuperview];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.addImageLabel.alpha = 0.0f;
    self.playerImage.image = image;
    [self.playerName becomeFirstResponder];
    
    [self imagePickerControllerDidCancel:picker];
}
@end
