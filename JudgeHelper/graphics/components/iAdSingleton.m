//
//  iAdSingleton.m
//  JudgeHelper
//
//  Created by fyang on 12/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "iAdSingleton.h"
#import "AppDelegate.h"

@implementation iAdSingleton

+ (iAdSingleton *) sharedInstance
{
    static iAdSingleton *sharedHelper;
    
    if (!sharedHelper)
    {
        sharedHelper = [[self alloc] init];
    }
    return sharedHelper;
}

-(void) createAdView //Main method to create a view
{
    static NSString * const kADBannerViewClass = @"ADBannerView";
    
    if (NSClassFromString(kADBannerViewClass) != nil)
    {
        AppController *app =  (AppController*)[[UIApplication sharedApplication] delegate];
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        NSString *contentSize;
        if (&ADBannerContentSizeIdentifierPortrait != nil)
        {
            contentSize = UIInterfaceOrientationIsPortrait(orientation) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
        }
        else
        {
            // user the older sizes
            contentSize = UIInterfaceOrientationIsPortrait(orientation) ? ADBannerContentSizeIdentifier320x50 : ADBannerContentSizeIdentifier480x32;
        }
        
        // Calculate the intial location for the banner.
        // We want this banner to be at the bottom of the view controller, but placed
        // offscreen to ensure that the user won't see the banner until its ready.
        // We'll be informed when we have an ad to show because -bannerViewDidLoadAd: will be called.
        frame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:contentSize];
        frame.origin = CGPointMake(0.0f, CGRectGetMaxY(app.viewController.view.bounds));
        
        // Now to create and configure the banner view
        self.bannerView = [[ADBannerView alloc] initWithFrame:frame];
        // Set the delegate to self, so that we are notified of ad responses.
        self.bannerView.delegate = self;
        // Set the autoresizing mask so that the banner is pinned to the bottom
        self.bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
        // Since we support all orientations in this view controller, support portrait and landscape content sizes.
        // If you only supported landscape or portrait, you could remove the other from this set.
        
        self.bannerView.requiredContentSizeIdentifiers = (&ADBannerContentSizeIdentifierPortrait != nil) ?
        [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil] :
        [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil];
        
        // At this point the ad banner is now be visible and looking for an ad.
        
        [navController.view addSubview:self.bannerView];
        
        //[self moveBannerOffScreen];
    }
}

- (int)getBannerHeight:(UIDeviceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return 32;
    } else {
        return 50;
    }
}

- (int)getBannerHeight {
    return frame.size.height;
    return [self getBannerHeight:[UIDevice currentDevice].orientation];
}

//Will be called after Banner is loaded succesfully ( check moveBannerOffScreen)
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self moveBannerOnScreen];
}

//First move the banner out of the screen until it is loaded fully (apple required, no white banner space)
-(void) moveBannerOffScreen
{
    if (self.bannerView)
    {
        CGSize s = [[CCDirector sharedDirector] winSize];
        
        CGRect frame = self.bannerView.frame;
        frame.origin.y = 0.0f;
        frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
        
        self.bannerView.frame = frame;
        
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             CGSize s = [[CCDirector sharedDirector] winSize];
             
             CGRect frame = self.bannerView.frame;
             frame.origin.y = - frame.size.height;// frame.origin.y +  frame.size.height;
             frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
         }
                         completion:^(BOOL finished)
         {
         }];
    }
    NSLog(@"Banner moved out of the screen");
}

//Move the banner on to the screen
-(void) moveBannerOnScreen
{
    _adBannerViewIsVisible = true;
    AppController * myDelegate = (((AppController*) [UIApplication sharedApplication].delegate));
    [myDelegate.viewController.view addSubview:self.bannerView];
    
    if (self.bannerView)
    {
        CGSize s = [[CCDirector sharedDirector] winSize];
        
        CGRect frame = self.bannerView.frame;
        frame.origin.y = - frame.size.height;
        frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
        
        self.bannerView.frame = frame;
        
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             
             CGRect frame = self.bannerView.frame;
             frame.origin.y = 0.0f;//s.height - frame.size.height;
             frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
             
             self.bannerView.frame = frame;
         }
         completion:^(BOOL finished)
         {
         }];
    }
    NSLog(@"Banner is moved to the screen");
    
}

//When user pressed the banner then this method will be fired
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"banner is full screen");
    return YES;
}

//After banner is closed (you should restore any services paused by your application/banner)
-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    return;
    if (self.bannerView)
    {
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             CGSize s = [[CCDirector sharedDirector] winSize];
             
             CGRect frame = self.bannerView.frame;
             frame.origin.y = -frame.size.height; //frame.origin.y + frame.size.height ;
             frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
             self.bannerView.frame = frame;
         }
         completion:^(BOOL finished)
         {
             [self.bannerView removeFromSuperview];
             self.bannerView.delegate = nil;
             self.bannerView = nil;
             
         }];
    }
    NSLog(@"iAd banner is closed");
}

//Could not load banner, we need to move that banner to off screen (apple required)
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"banner got error");
    //[UIView beginAnimations:@"animateAdBannerOff" context:NULL];
    //[self moveBannerOffScreen];
}
// NO need of delloc (using ARC)
@end