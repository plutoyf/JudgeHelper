//
//  RootViewController.m
//  JudgeHelper
//
//  Created by fyang on 14/11/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "RootViewController.h"
#import "IntroLayer.h"
#import "SelectPlayerLayer.h"

@interface RootViewController ()

@end

@implementation RootViewController

-(CGRect)currentScreenBoundsDependOnOrientation
{
    CGRect screenBounds = [UIScreen mainScreen].bounds ;
    CGFloat width = CGRectGetWidth(screenBounds)  ;
    CGFloat height = CGRectGetHeight(screenBounds) ;
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        screenBounds.size = CGSizeMake(width, height);
    }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        screenBounds.size = CGSizeMake(height, width);
    }
    return screenBounds ;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CCGLView *glView = [CCGLView viewWithFrame:[self currentScreenBoundsDependOnOrientation]
                                   pixelFormat:kEAGLColorFormatRGB565
                                   depthFormat:0
                            preserveBackbuffer:NO
                                    sharegroup:nil
                                 multiSampling:NO
                               numberOfSamples:0];
    
    CCDirector *director = [CCDirector sharedDirector];
    if([director isViewLoaded] == NO) {
        //glView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        director.view = glView;
    }
    
    // Add the director as a child view controller of this view controller.
    [self addChildViewController:director];
    
    // Add the director's OpenGL view as a subview so we can see it.
    [self.view insertSubview:director.view atIndex:0];
    //[self.view addSubview:director.view];
    //[self.view sendSubviewToBack:director.view];
    
    // Finish up our view controller containment responsibilities.
    //[director didMoveToParentViewController:self];
    
    // Run whatever scene we'd like to run here.
    [director runWithScene:[IntroLayer scene]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[CCDirector sharedDirector] setDelegate:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
