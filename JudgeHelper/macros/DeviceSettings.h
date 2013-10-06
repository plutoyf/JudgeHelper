//
//  DeviceSettings.h
//  JudgeHelper
//
//  Created by fyang on 10/4/13.
//  Copyright (c) 2013 YANG FAN. All rights reserved.
//

#import <UIKit/UIDevice.h>

/*  DETERMINE THE DEVICE USED  */
#ifdef UI_USER_INTERFACE_IDIOM()
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD() (NO)
#endif

/*  NORMAL DETAILS */
#define kScreenHeight       480
#define kScreenWidth        320

/* OFFSETS TO ACCOMMODATE IPAD */
#define kOffsetiPad         0
#define kXoffsetiPad        0
#define kYoffsetiPad        0


#define kRate               1.8
#define kXrate              2.13
#define kYrate              2.4

#define SD_PNG      @".png"
#define HD_PNG      @"-hd.png"

#define ADJUST_CCP(__p__)       \
(IS_IPAD() == YES ?             \
ccp( ( __p__.x * kXrate ) + kXoffsetiPad, ( __p__.y * kYrate ) + kYoffsetiPad ) : \
__p__)

#define REVERSE_CCP(__p__)      \
(IS_IPAD() == NO ?                       \
ccp( ( __p__.x - kXoffsetiPad ) / kXrate, ( __p__.y - kYoffsetiPad ) / kYrate ) : \
__p__)

#define ADJUST_XY(__x__, __y__)      \
(IS_IPAD() == YES ?                      \
ccp( ( __x__ * kXrate ) + kXoffsetiPad, ( __y__ * kYrate ) + kYoffsetiPad ) : \
ccp(__x__, __y__))

#define REVERSE_XY(__x__, __y__)     \
(IS_IPAD() == NO ?                       \
ccp( ( __x__ - kXoffsetiPad) / kXrate, ( __y__ - kYoffsetiPad ) / kYrate ) : \
ccp(__x__, __y__))

#define VALUE(__x__, __y__)     \
(IS_IPAD() == YES ?                      \
__x__ : \
__y__)

#define ADJUST(__x__)         \
(IS_IPAD() == YES ?             \
( __x__ * kRate ) + kOffsetiPad :      \
__x__)

#define REVERSE(__x__)         \
(IS_IPAD() == NO ?             \
( __x__ - kOffsetiPad ) / kRate :      \
__x__)

#define ADJUST_X(__x__)         \
(IS_IPAD() == YES ?             \
( __x__ * kXrate ) + kXoffsetiPad :      \
__x__)

#define REVERSE_X(__x__)         \
(IS_IPAD() == NO ?             \
( __x__ - kXoffsetiPad ) / kXrate :      \
__x__)

#define ADJUST_Y(__y__)         \
(IS_IPAD() == YES ?             \
( __y__ * kYrate ) + kYoffsetiPad :      \
__y__)

#define REVERSE_Y(__y__)         \
(IS_IPAD() == NO ?             \
( __y__ - kYoffsetiPad ) / kYrate :      \
__y__)

#define HD_PIXELS(__pixels__)       \
(IS_IPAD() == YES ?             \
( __pixels__ * kXrate ) :                \
__pixels__)

#define HD_TEXT(__size__)   \
(IS_IPAD() == YES ?         \
( __size__ * 1.5 ) :            \
__size__)

#define SD_OR_HD(__filename__)  \
(IS_IPAD() == YES ?             \
[__filename__ stringByReplacingOccurrencesOfString:SD_PNG withString:HD_PNG] :  \
__filename__)

