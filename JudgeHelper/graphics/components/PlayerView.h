//
//  PlayerView.h
//  JudgeHelper
//
//  Created by YANG FAN on 25/11/2013.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayerViewDelegate;

@interface PlayerView : UIView {
    CGFloat firstX, firstY;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (nonatomic, assign) id<PlayerViewDelegate> delegate;

- (IBAction)movePlayer:(id)sender;
- (IBAction)selectPlayer:(id)sender;

@end

@protocol PlayerViewDelegate
@required
-(void) selectPlayer;
@end
