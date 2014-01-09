//
//  AppDelegate.h
//  BobbleFriends
//
//  Created by Peter Kamm on 7/7/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ShareViewController.h"

extern NSString *const FBSessionStateChangedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIImage *bobbleFaceImage;
@property (strong, nonatomic) NSString *soundFilePath;
@property (assign, nonatomic) float soundPitchValue;
@property (strong, nonatomic) NSString *outputFileName;
@property (strong, nonatomic) NSDictionary *bobbleFontDict;
@property (strong, nonatomic) NSArray *bobbleBackgroundArray;
@property (strong, nonatomic) NSArray *bobbleBodyArray;
@property (strong, nonatomic) ShareViewController *shareController;
@property (assign, nonatomic) int bobbleBGIndex;
@property (assign, nonatomic) int bobbleBodyIndex;
@property (assign, nonatomic) int mouthType;
@property (assign, nonatomic) float mouthScale;
@property (assign, nonatomic) CGAffineTransform mouthTransform;

@property (assign, nonatomic) float percentLoaded;


- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)initializeBackgroundImageArray;


@end
