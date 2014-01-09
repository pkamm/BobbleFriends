//
//  ChooseMouthViewController.h
//  BobbleFriends
//
//  Created by Peter Kamm on 2/27/13.
//  Copyright (c) 2013 Peter Kamm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoomingImageView.h"

@interface ChooseMouthViewController : UIViewController{
    UIImage *_mouthImage;
}

@property (strong, nonatomic) IBOutlet ZoomingImageView *mouthImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UISlider *sizeSlider;

@end
