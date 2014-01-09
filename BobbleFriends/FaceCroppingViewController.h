//
//  FaceCroppingViewController.h
//  BobbleFriends
//
//  Created by Peter Kamm on 8/6/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoomingImageView.h"
#import "CopOverlayViewController.h"


@interface FaceCroppingViewController : UIViewController
@property (strong, nonatomic) ZoomingImageView *zoomingImageView;
@property (strong, nonatomic) UIImage *chosenImage;

@property (weak, nonatomic) IBOutlet UIButton *cropFaceButton;

//- (UIImage*)createWhiteMaskBackground;
- (UIImage*)createWhiteMaskBackgroundOfSize:(CGSize)imageSize;
@property (weak, nonatomic) IBOutlet UIImageView *faceCropOutlineImageView;
@property (strong, nonatomic) CopOverlayViewController *overlay;
@property (weak, nonatomic) IBOutlet UIView *faceHolderView;


-(void)hideOverlay;

@end
