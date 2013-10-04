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
        int w = size.height/3, h = size.width/3;
        int x = size.width-REVERSE_X(430)-w*2;
        int y = size.height-h-REVERSE_Y(35);
        int bw = w - REVERSE_X(20);
        int bh = bw;
        CGRect cropRect = CGRectMake(x+w/2-bw/2+1, h/2-bh/2+REVERSE_Y(36)+1, bw-2, bh-2);
        
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
    [_picker setContentSizeForViewInPopover:CGSizeMake(REVERSE_X(340), winsize.height)];
    
    if([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        _picker.sourceType = sourceType;
    } else {
        _picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    
    _popover = [[UIPopoverController alloc] initWithContentViewController:_picker];
    [_popover setDelegate:self];
    [_popover setPopoverContentSize:CGSizeMake(REVERSE_X(340), winsize.height) animated:NO];
    CGRect r = CGRectMake( _picker.sourceType == UIImagePickerControllerSourceTypeCamera ? winsize.width-REVERSE_X(50) : winsize.width-REVERSE_X(150), winsize.height,0,REVERSE_X(90));
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissModalViewControllerAnimated:YES];
    [_popover dismissPopoverAnimated:YES];
    
    if(cadre) {
        [self removeChild:cadre];
    }
    CGSize size = [[CCDirector sharedDirector] winSize];
    CGSize cadreSize = CGSizeMake(size.width, size.height);
    cadre = [[ClippingSprite alloc] init];
    cadre.contentSize = cadreSize;
    //GLubyte *buffer = malloc(sizeof(GLubyte)*4);
    //for (int i=0;i<4;i++) {buffer[i]=255;}
    //CCTexture2D *cadreBkgTex = [[CCTexture2D alloc] initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_RGB5A1 pixelsWide:1 pixelsHigh:1 contentSize:cadreSize];
    //[cadre setTexture:cadreBkgTex];
    //[cadre setTextureRect:CGRectMake(0, 0, cadreSize.width, cadreSize.height)];
    //free(buffer);
    int w = size.height/3, h = size.width/3;
    int x = size.width-REVERSE_X(430)-w*2;
    int y = size.height-h-REVERSE_Y(35);
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
    
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:image.size interpolationQuality:kCGInterpolationHigh];
    selectedImage = image;
    CCTexture2D *pictureTexture = [[CCTexture2D alloc] initWithCGImage: image.CGImage resolutionType: kCCResolutioniPad];
    picture = [[CCSprite alloc] initWithTexture:pictureTexture];
    CGSize textureSize = [pictureTexture contentSize];
    [picture setScaleX: w/textureSize.width];
    [picture setScaleY: w*textureSize.height/textureSize.width/textureSize.height];
    picture.position = ccp(x+w/2, y+h/2);
    
    int bw = w - REVERSE_X(20);
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
        userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(x+w+REVERSE_X(20),REVERSE_Y(35),w,REVERSE_X(35))];
        userNameTextField.placeholder = @"Enter name here." ;
        userNameTextField.borderStyle = UITextBorderStyleRoundedRect ;
        userNameTextField.autocorrectionType = UITextAutocorrectionTypeNo ;
        userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        userNameTextField.font = [UIFont fontWithName:@"Verdana" size:REVERSE_X(16.0)];
        userNameTextField.font = [UIFont systemFontOfSize:REVERSE_X(16.0)];
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
