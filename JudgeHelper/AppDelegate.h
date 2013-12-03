//
//  AppDelegate.h
//  JudgeHelper
//
//  Created by YANG FAN on 05/08/13.
//  Copyright YANG FAN 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "RootViewController.h"

@interface AppController : NSObject <UIApplicationDelegate, UINavigationControllerDelegate, CCDirectorDelegate>
{
	UIWindow *window_;

	CCDirectorIOS	*__unsafe_unretained director_;							// weak ref
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (weak, nonatomic) IBOutlet UINavigationController *navigationController;

@property (nonatomic, strong) UIViewController *rootViewController;
@property (unsafe_unretained, readonly) CCDirectorIOS *director;

@end
