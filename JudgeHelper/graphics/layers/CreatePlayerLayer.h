//
//  CreatePlayerLayer.h
//  JudgeHelper
//
//  Created by YANG FAN on 04/08/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "CCSprite.h"
#import "ClippingSprite.h"

@protocol CreatePlayerDelegate;

@interface CreatePlayerLayer : CCSprite<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>
{
    UIWindow *window;
    UIImage *newImage;
    UIImagePickerController* _picker;
    UIPopoverController* _popover;
    ClippingSprite* cadre;
    CCSprite* picture;
    CCMenu* saveMenu;
    UITextField* userNameTextField;
    UIImage* selectedImage;
}

@property (nonatomic, assign) id<CreatePlayerDelegate> delegate;

+(id) scene;

@end

@protocol CreatePlayerDelegate
@required
-(void) createPlayer: (NSString*) name withImage: (UIImage*) image;
@end