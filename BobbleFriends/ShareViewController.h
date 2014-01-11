//
//  ShareViewController.h
//  BobbleFriends
//
//  Created by Peter Kamm on 1/14/13.
//  Copyright (c) 2013 Peter Kamm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h> 
#import <MessageUI/MFMessageComposeViewController.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController : UIViewController <FBFriendPickerDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) NSTimer *progTimer;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@property (weak, nonatomic) IBOutlet UIButton *shareFBButton;
@property (weak, nonatomic) IBOutlet UIButton *shareEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *shareTextButton;

@property (weak, nonatomic) id delegate;

- (IBAction)shareButtonPressed:(id)sender;
- (void)updateProgress;
- (IBAction)selectFriendsButtonAction:(id)sender;
-(void)finishedCreatingVideo;

@property (weak, nonatomic) IBOutlet UIProgressView *progressLoadingInidicator;

@end
