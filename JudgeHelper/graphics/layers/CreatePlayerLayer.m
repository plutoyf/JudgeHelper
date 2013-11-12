//
//  CreatePlayerLayer.m
//  JudgeHelper
//
//  Created by YANG FAN on 04/08/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import "CreatePlayerLayer.h"
#import "ClippingSprite.h"
#import "BorderSprite.h"
#import "CCNode+SFGestureRecognizers.h"
#import "UIImage+Resize.h"
#import "AppDelegate.h"
#import "iAdSingleton.h"

@implementation CreatePlayerLayer

+(id) scene {
    CCScene *scene = [CCScene node];
    CreatePlayerLayer *layer = [CreatePlayerLayer node];
    [scene addChild: layer];
    
    return scene;
}

- (void)onEnter
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kCCMenuTouchPriority swallowsTouches:YES];
    [super onEnter];
}

- (void)onExit
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return TRUE;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}


-(id) init
{
    if( (self=[super init]) ) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        size.height -= [iAdSingleton sharedInstance].getBannerHeight;
        
        [self setContentSize: CGSizeMake(size.width, size.height)];
        _position = ccp(size.width/2, size.height/2);
                
        CCLayerColor *layerColer = [CCLayerColor layerWithColor:ccc4(0,0,0,255)];
        layerColer.position = ccp(0, size.height/2-REVERSE_Y(80));
        [self addChild:layerColer];
        
        
        CCMenuItem *returnItem = [CCMenuItemImage
                                  itemFromNormalImage:@"return.png" selectedImage:@"return-sel.png"
                                  target:self selector:@selector(returnButtonTapped:)];
        [returnItem setScaleX: IMG_WIDTH/returnItem.contentSize.width];
        [returnItem setScaleY: IMG_HEIGHT/returnItem.contentSize.height];
        returnItem.position = REVERSE_XY(50, 30);
        CCMenuItem *showAlbumMenuItem = [CCMenuItemImage
                                    itemFromNormalImage:@"album.png" selectedImage:@"album-sel.png"
                                    target:self selector:@selector(showAlbumButtonTapped:)];
        [showAlbumMenuItem setScaleX: IMG_WIDTH/showAlbumMenuItem.contentSize.width];
        [showAlbumMenuItem setScaleY: IMG_HEIGHT/showAlbumMenuItem.contentSize.height];
        showAlbumMenuItem.position = REVERSE_XY(150, 30);
        CCMenuItem *showCameraItem = [CCMenuItemImage
                                     itemFromNormalImage:@"camera.png" selectedImage:@"camera-sel.png"
                                     target:self selector:@selector(showCameraButtonTapped:)];
        [showCameraItem setScaleX: IMG_WIDTH/showCameraItem.contentSize.width];
        [showCameraItem setScaleY: IMG_HEIGHT/showCameraItem.contentSize.height];
        showCameraItem.position = REVERSE_XY(250, 30);
        
        CCMenu *showPickerMenu = [CCMenu menuWithItems: returnItem, showAlbumMenuItem, showCameraItem, nil];
        showPickerMenu.position = ccp(size.width-REVERSE_X(300), size.height-REVERSE_Y(80));
        [self addChild:showPickerMenu z:2];
        
    }
    return self;
}

- (void) saveButtonTapped: (id) sender {
    NSString* name = userNameTextField.text;
    if(name.length > 0) {
        CGSize size = [CCDirector sharedDirector].winSize;
        size.height -= [iAdSingleton sharedInstance].getBannerHeight;
        int w = VALUE(size.height/3, size.height/2), h = VALUE(size.width/3, size.width/2);
        int x = VALUE(size.width-REVERSE(430)-w*2, w/3);
        int y = size.height-h-VALUE(35, 30);
        int bw = w - REVERSE(20);
        int bh = bw;
        CGRect cropRect = CGRectMake(x+w/2-bw/2+2, h/2-bh/2+VALUE(36, 30)+2, bw-4, bh-4);
        
        UIImage *screenshot = [self screenshotWithStartNode: cadre];
        screenshot = [screenshot resizedImage:CGSizeMake(size.width, size.height) interpolationQuality:kCGInterpolationDefault];
        CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], cropRect);
        
        [_delegate createPlayer:name withImage:[UIImage imageWithCGImage:imageRef]];
        
        [self removeChild:cadre];
        [self removeChild:saveMenu];
        [userNameTextField removeFromSuperview];
        cadre = nil;
        saveMenu = nil;
        userNameTextField = nil;
        
        //[self returnButtonTapped:nil];
    }
}

-(void) returnButtonTapped: (id) sender {
    [userNameTextField removeFromSuperview];
    [self removeFromParent];
    [_delegate didFinishCreatingPlayer];
}

-(void) showAlbumButtonTapped: (id) sender {
    [self showPhotoLibrary:UIImagePickerControllerSourceTypePhotoLibrary];
}

-(void) showCameraButtonTapped: (id) sender {
    [self showPhotoLibrary:UIImagePickerControllerSourceTypeCamera];
}

-(void) showPhotoLibrary:(UIImagePickerControllerSourceType) sourceType {
    if (_picker) {
        [_picker dismissModalViewControllerAnimated:NO];
        [_picker.view removeFromSuperview];
    }
    if (_popover) {
        [_popover dismissPopoverAnimated:NO];
    }
    
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    winsize.height -= [iAdSingleton sharedInstance].getBannerHeight;
    
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    _picker.wantsFullScreenLayout = YES;
    //_picker.sourceType = UIImagePickerControllerSourceTypeCamera;//UIImagePickerControllerSourceTypePhotoLibrary;
    if(IS_IPAD()) {
        [_picker setContentSizeForViewInPopover:CGSizeMake(REVERSE_X(340), winsize.height)];
    } else {
    }
    
    if([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        _picker.sourceType = sourceType;
    } else {
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    
    if(IS_IPAD()) {
        _popover = [[UIPopoverController alloc] initWithContentViewController:_picker];
        [_popover setDelegate:self];
        [_popover setPopoverContentSize:CGSizeMake(REVERSE_X(340), winsize.height) animated:NO];
        CGRect r = CGRectMake( _picker.sourceType == UIImagePickerControllerSourceTypeCamera ? winsize.width-REVERSE_X(50) : winsize.width-REVERSE_X(150), winsize.height,10,REVERSE_X(90));
        r.origin = [[CCDirector sharedDirector] convertToGL:r.origin];
        [_popover presentPopoverFromRect:r inView:[[CCDirector sharedDirector] openGLView] permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    } else {
        UIViewController *rootViewController = (UIViewController*)[(AppController*)[[UIApplication sharedApplication] delegate] navController];
        [rootViewController presentModalViewController:_picker animated:NO];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if(IS_IPAD()) {
        [_popover dismissPopoverAnimated:YES];
    } else {
        [_picker dismissModalViewControllerAnimated:YES];
        [_picker.view removeFromSuperview];
        _picker = nil;
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}

//for Ipad UIPopoverController if there is a cancel when the user click outside the popover
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    //[_picker dismissModalViewControllerAnimated:YES];
    //[_picker.view removeFromSuperview];
    //_picker = nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self imagePickerControllerDidCancel: picker];
    
    if(cadre) {
        [self removeChild:cadre];
    }
    CGSize size = [[CCDirector sharedDirector] winSize];
    size.height -= [iAdSingleton sharedInstance].getBannerHeight;
    CGSize cadreSize = CGSizeMake(size.width, size.height);
    cadre = [[ClippingSprite alloc] init];
    cadre.contentSize = cadreSize;
    int w = VALUE(size.height/3, size.height/2), h = VALUE(size.width/3, size.width/2);
    int x = VALUE(size.width-REVERSE(430)-w*2, w/3);
    int y = size.height-h-VALUE(35, 30);
    cadre.openWindowRect = CGRectMake(x,y,w,h);
    cadre.touchRect = CGRectMake(x,y,w,h);
    cadre.position = ccp(cadreSize.width/2, cadreSize.height/2);
    cadre.isTouchEnabled = YES;
    
    UIGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePicturePanGesture:)];
    panGestureRecognizer.delegate = self;
    [cadre addGestureRecognizer:panGestureRecognizer];
    
    UIGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePicturePinchGesture:)];
    pinchGestureRecognizer.delegate = self;
    [cadre addGestureRecognizer:pinchGestureRecognizer];
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(1024, 1024) interpolationQuality:kCGInterpolationHigh];
    picture = [[CCSprite alloc] initWithCGImage:image.CGImage key:nil];
    CGSize textureSize = [picture contentSize];
    [picture setScaleX: w/textureSize.width];
    [picture setScaleY: w*textureSize.height/textureSize.width/textureSize.height];
    picture.position = ccp(x+w/2, y+h/2);
    
    int bw = w - REVERSE(20);
    int bh = bw;
    border = [[BorderSprite alloc] init];
    [border setTextureRect: CGRectMake(0,0,bw,bh)];
    border.borderRect = CGRectMake(0,0,bw,bh);
    border.position = ccp(x+w/2, y+h/2);
    border.opacity = 0;
    
    [cadre addChild:picture];
    [cadre addChild:border];
    [cadre clip];
    [self addChild:cadre];
    
    
    // Create textfield
    if(userNameTextField == nil) {
        userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(VALUE(x+w+20, size.width-w-20),VALUE(35, 60)+[iAdSingleton sharedInstance].getBannerHeight,w,REVERSE(35))];
        userNameTextField.placeholder = @"Enter name here." ;
        userNameTextField.borderStyle = UITextBorderStyleRoundedRect ;
        userNameTextField.autocorrectionType = UITextAutocorrectionTypeNo ;
        userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        userNameTextField.font = [UIFont fontWithName:@"Verdana" size:VALUE(16, 12)];
        userNameTextField.font = [UIFont systemFontOfSize:VALUE(16, 12)];
        userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing ;
        userNameTextField.adjustsFontSizeToFitWidth = YES;
        userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        userNameTextField.returnKeyType = UIReturnKeyDone ;
        userNameTextField.textColor = [UIColor colorWithRed:76.0f/255.0f green:76.0f/255.0f blue:76.0f/255.0f alpha:1.0f];
        
        // Workaround to dismiss keyboard when Done/Return is tapped
        [userNameTextField addTarget:self action:@selector(userNameTextFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        // Add textfield into cocos2d view
        [[[CCDirector sharedDirector] openGLView] addSubview:userNameTextField];
        [userNameTextField becomeFirstResponder];
    }
    
    CCMenuItem *saveItem = [CCMenuItemImage
                            itemFromNormalImage:@"save.png" selectedImage:@"save-sel.png"
                            target:self selector:@selector(saveButtonTapped:)];
    [saveItem setScaleX: IMG_WIDTH/saveItem.contentSize.width];
    [saveItem setScaleY: IMG_HEIGHT/saveItem.contentSize.height];
    saveItem.position = REVERSE_XY(50, 30);
    
    if(!saveMenu) {
        saveMenu = [CCMenu menuWithItems: saveItem, nil];
        saveMenu.position = ccp(size.width-REVERSE_X(400), size.height-REVERSE_Y(80));
        [self addChild:saveMenu z:2];
    }

}

- (UIImage *) imageFromSprite :(CCSprite *)sprite
{
    int tx = sprite.contentSize.width;
    int ty = sprite.contentSize.height;
    
    CCRenderTexture *renderer   = [CCRenderTexture renderTextureWithWidth:tx height:ty];
    
    sprite.anchorPoint  = CGPointZero;
    
    [renderer begin];
    [sprite visit];
    [renderer end];
    
    return [renderer getUIImage];
}

-(UIImage*) screenshotWithStartNode:(CCNode*)startNode
{
    [CCDirector sharedDirector].nextDeltaTimeZero = YES;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    winSize.height -= [iAdSingleton sharedInstance].getBannerHeight;
    CCRenderTexture* rtx = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
    [rtx begin];
    [startNode visit];
    [rtx end];
    
    return [rtx getUIImage];
}


- (void) userNameTextFieldEditingDidEndOnExit:(UITextField*) textField {
}

- (void)handlePicturePanGesture:(UIPanGestureRecognizer*)aPanGestureRecognizer {
    CGPoint translation = [aPanGestureRecognizer translationInView:aPanGestureRecognizer.view];
    translation.y *= -1;
    [aPanGestureRecognizer setTranslation:CGPointZero inView:aPanGestureRecognizer.view];
    float x = border.position.x, y = border.position.y, w = border.borderRect.size.width, h = border.borderRect.size.height;
    float pw = picture.boundingBox.size.width, ph = picture.boundingBox.size.height;
    CGPoint p1 = ccpAdd(picture.position, translation);
    p1.x = p1.x+pw/2<x-w/2 ? x-w/2-pw/2 : p1.x-pw/2>x+w/2 ? x+w/2+pw/2 : p1.x;
    p1.y = p1.y+ph/2<y-h/2 ? y-h/2-ph/2 : p1.y-ph/2>y+h/2 ? y+h/2+ph/2 : p1.y;
    picture.position = p1;
}

- (void)handlePicturePinchGesture:(UIPinchGestureRecognizer*)aPinchGestureRecognizer {
    if (aPinchGestureRecognizer.state == UIGestureRecognizerStateBegan || aPinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        float scale = [aPinchGestureRecognizer scale];
        picture.scaleX *= scale;
        picture.scaleY *= scale;
        aPinchGestureRecognizer.scale = 1;
    }
}

@end
