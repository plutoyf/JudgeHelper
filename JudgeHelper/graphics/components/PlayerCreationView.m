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
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        popover.delegate = self;
        [popover presentPopoverFromRect:self.playerImage.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        UINavigationController *navigationController =  ((AppController*)[[UIApplication sharedApplication] delegate]).navigationController;
        [navigationController presentModalViewController:picker animated:NO];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
    } else {
        [self showImagePicker: buttonIndex==1 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary];
    }
}


- (IBAction)playerImageTapped:(id)sender {
     UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"选择照片"
                                                   message:@""
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"照相机", @"相册", nil];

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

        NSString* pid = [NSNumber numberWithLong: (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970])].stringValue;
        [pids addObject:pid];
        [userDefaults setObject:pids forKey:pidsKey];
        [userDefaults setObject:name forKey:[pid stringByAppendingString:@"-name"]];
        [userDefaults setObject:UIImagePNGRepresentation(image) forKey:[pid stringByAppendingString:@"-img"]];
        [userDefaults synchronize];
        
        [self endCreatingPlayerWithId:pid];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}


- (IBAction)cancelButtonTapped:(id)sender {
    [self endCreatingPlayerWithId:nil];
}

- (void) endCreatingPlayerWithId:(NSString *) pid {
    [UIView animateWithDuration:.2 animations:^(void) {
        [self setFrame:CGRectOffset([self frame], 0, -self.bounds.size.height)];
    } completion:^(BOOL Finished) {
        [self removeFromSuperview];
    }];
    [self.shieldView removeFromSuperview];
    
    UINavigationController *navigationController = ((AppController*)[[UIApplication sharedApplication] delegate]).navigationController;
    MainMenuViewController *rootViewController = (MainMenuViewController*)[navigationController.viewControllers objectAtIndex:0];
    [rootViewController didFinishedCreatingPlayerWithId:pid];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [popover dismissPopoverAnimated:YES];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [picker dismissModalViewControllerAnimated:YES];
        [picker.view removeFromSuperview];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.addImageLabel.alpha = 0.0f;
    self.playerImage.image = image;
    [self.playerName becomeFirstResponder];
    
    [self imagePickerControllerDidCancel:picker];
}
@end
