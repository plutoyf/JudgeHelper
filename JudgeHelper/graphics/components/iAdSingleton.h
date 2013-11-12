//
//  iAdSingleton.h
//  JudgeHelper
//
//  Created by fyang on 12/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>
#import "iAd/ADBannerView.h"

@interface iAdSingleton :NSObject  <ADBannerViewDelegate>
{
    ADBannerView *bannerView;
    UINavigationController *navController;
    BOOL _adBannerViewIsVisible;
}

@property (nonatomic,retain) ADBannerView *bannerView;

+ (iAdSingleton *)sharedInstance;
- (void)createAdView;
- (int)getBannerHeight;

@end