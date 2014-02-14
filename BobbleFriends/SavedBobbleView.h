//
//  SavedBobbleView.h
//  BobbleFriends
//
//  Created by Peter Kamm on 2/13/14.
//  Copyright (c) 2014 Peter Kamm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface SavedBobbleView : UIView
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *viewBobbleButton;
@property (strong, nonatomic) NSString* bobbleID;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

@property (weak, nonatomic) id delegate;

@end
