//
//  PhotoPickerViewController.h
//  BobbleFriends
//
//  Created by Peter Kamm on 7/7/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoPickerViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *chooseImageFromCameraRollButton;
@property (weak, nonatomic) IBOutlet UIImageView *sampleChosenImageView;
@property (weak, nonatomic) IBOutlet UIButton *useImageButton;
@property (strong, nonatomic)  UIImage *chosenImage;


@end
