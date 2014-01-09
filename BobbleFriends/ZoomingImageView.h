//
//  ImageZoomingViewController.h
//  BobbleFriends
//
//  Created by Peter Kamm on 8/5/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface ZoomingImageView : UIImageView {
    CGAffineTransform originalTransform;
    CFMutableDictionaryRef touchBeginPoints;
}

@end