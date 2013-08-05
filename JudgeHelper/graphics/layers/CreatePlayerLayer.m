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
        
        [self setContentSize: CGSizeMake(size.width, size.height)];
        _position = ccp(size.width/2, size.height/2);
                
        CCLayerColor *layerColer = [CCLayerColor layerWithColor:ccc4(0,0,0,255)];
        layerColer.position = ccp(0, size.height/2-120);
        [self addChild:layerColer];
        
        
        CCMenuItem *saveItem = [CCMenuItemImage
                                  itemFromNormalImage:@"save.png" selectedImage:@"save.png"
                                target:self selector:@selector(saveButtonTapped:)];
        saveItem.position = ccp(50, 30);
        CCMenuItem *returnItem = [CCMenuItemImage
                                  itemFromNormalImage:@"return.png" selectedImage:@"return.png"
                                  target:self selector:@selector(returnButtonTapped:)];
        returnItem.position = ccp(150, 30);
        CCMenuItem *showAlbumMenuItem = [CCMenuItemImage
                                    itemFromNormalImage:@"album.png" selectedImage:@"album.png"
                                    target:self selector:@selector(showAlbumButtonTapped:)];
        showAlbumMenuItem.position = ccp(250, 30);
        CCMenuItem *showCameraItem = [CCMenuItemImage
                                     itemFromNormalImage:@"camera.png" selectedImage:@"camera.png"
                                     target:self selector:@selector(showCameraButtonTapped:)];
        showCameraItem.position = ccp(350, 30);
        
        CCMenu *showPickerMenu = [CCMenu menuWithItems: saveItem, returnItem, showAlbumMenuItem, showCameraItem, nil];
        showPickerMenu.position = ccp(size.width-400, size.height-80);
        [self addChild:showPickerMenu];
    }
    return self;
}

- (void) saveButtonTapped: (id) sender {
    NSString* name = userNameTextField.text;
    if(name.length > 0) {
        CGSize size = [CCDirector sharedDirector].winSize;
        int w = 768/3, h = 1024/3;//256 341.3   236   404
        int x = size.width-450-w;
        int y = size.height/2+20;
        int bw = w - 20;
        int bh = bw;
        CGRect cropRect = CGRectMake(x+w/2-bw/2+1, h/2-bh/2+24+1, bw-2, bh-2);
        
        UIImage *screenshot = [self screenshotWithStartNode: cadre];
        CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], cropRect);
        
        [_delegate createPlayer:name withImage:[UIImage imageWithCGImage:imageRef]];
        
        [self returnButtonTapped:nil];
    }
}

-(void) returnButtonTapped: (id) sender {
    [userNameTextField removeFromSuperview];
    userNameTextField = nil;
    [self removeFromParent];
}

-(void) showAlbumButtonTapped: (id) sender {
    [self showPhotoLibrary:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
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
    
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    //_picker.sourceType = UIImagePickerControllerSourceTypeCamera;//UIImagePickerControllerSourceTypePhotoLibrary;
    _picker.wantsFullScreenLayout = YES;
    [_picker setContentSizeForViewInPopover:CGSizeMake(340, winsize.height)];
    
    if([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        _picker.sourceType = sourceType;
    } else {
        _picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:_picker];
    [_popover setDelegate:self];
    [_popover setPopoverContentSize:CGSizeMake(340, winsize.height) animated:NO];
    CGRect r = CGRectMake( _picker.sourceType == UIImagePickerControllerSourceTypeCamera ? winsize.width-50 : winsize.width-150, winsize.height,0,90);
    r.origin = [[CCDirector sharedDirector] convertToGL:r.origin];
    [_popover presentPopoverFromRect:r inView:[[CCDirector sharedDirector] openGLView] permittedArrowDirections:UIPopoverArrowDirectionDown animated:NO];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //[_picker dismissModalViewControllerAnimated:YES];
    //[_picker.view removeFromSuperview];
    //_picker = nil;
    //[_popover dismissPopoverAnimated:YES];
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

ClippingSprite* cadre;
CCSprite* picture;
UITextField* userNameTextField;
UIImage* selectedImage;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissModalViewControllerAnimated:YES];
    [_popover dismissPopoverAnimated:YES];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    CGSize cadreSize = CGSizeMake(size.width, size.height);
    cadre = [[ClippingSprite alloc] init];
    GLubyte *buffer = malloc(sizeof(GLubyte)*4);
    for (int i=0;i<4;i++) {buffer[i]=255;}
    CCTexture2D *cadreBkgTex = [[CCTexture2D alloc] initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_RGB5A1 pixelsWide:1 pixelsHigh:1 contentSize:cadreSize];
    [cadre setTexture:cadreBkgTex];
    [cadre setTextureRect:CGRectMake(0, 0, cadreSize.width, cadreSize.height)];
    free(buffer);
    int w = 768/3, h = 1024/3;
    int x = size.width-450-w;
    int y = size.height/2+20;
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
    
    selectedImage = image;
    CCTexture2D *pictureTexture = [[CCTexture2D alloc] initWithCGImage: image.CGImage resolutionType: kCCResolutioniPad];
    picture = [[CCSprite alloc] initWithTexture:pictureTexture];
    CGSize textureSize = [pictureTexture contentSize];
    [picture setScaleX: w/textureSize.width];
    [picture setScaleY: w*textureSize.height/textureSize.width/textureSize.height];
    picture.position = ccp(x+w/2, y+h/2);
    
    int bw = w - 20;
    int bh = bw;
    BorderSprite* border = [[BorderSprite alloc] init];
    [border setTextureRect: CGRectMake(0,0,bw,bh)];
    border.borderRect = CGRectMake(0,0,bw,bh);
    border.position = ccp(x+w/2, y+h/2);
    border.opacity = 0;
    
    [cadre addChild:picture];
    [cadre addChild:border];
    [self addChild:cadre];
    
    
    // Create textfield
    if(userNameTextField == nil) {
        userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(x,size.height-y,w,35)];
        userNameTextField.placeholder = @"Enter name here." ;
        userNameTextField.borderStyle = UITextBorderStyleRoundedRect ;
        userNameTextField.autocorrectionType = UITextAutocorrectionTypeNo ;
        userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        userNameTextField.font = [UIFont fontWithName:@"Verdana" size:16.0f];
        userNameTextField.font = [UIFont systemFontOfSize:16.0];
        userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing ;
        userNameTextField.adjustsFontSizeToFitWidth = YES;
        userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        userNameTextField.returnKeyType = UIReturnKeyDone ;
        userNameTextField.textColor = [UIColor colorWithRed:76.0f/255.0f green:76.0f/255.0f blue:76.0f/255.0f alpha:1.0f];
        
        // Workaround to dismiss keyboard when Done/Return is tapped
        [userNameTextField addTarget:self action:@selector(userNameTextFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        // Add textfield into cocos2d view
        [[[CCDirector sharedDirector] openGLView] addSubview:userNameTextField];
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
    
    picture.position = ccpAdd(picture.position, translation);
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
