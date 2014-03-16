//
//  AppDelegate.m
//  BobbleFriends
//
//  Created by Peter Kamm on 7/7/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

#import "AppDelegate.h"
#import "TestFlight.h"
#import "Background.h"
#import "Body.h"
#import "Flurry.h"
#import "FlurryAds.h"
#import "BobbleIAPHelper.h"

NSString *const FBSessionStateChangedNotification = @"com.blankworldwide.bobblefriends.Login:FBSessionStateChangedNotification";
#define TESTING 1

@implementation AppDelegate

@synthesize window;
@synthesize soundFilePath;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [BobbleIAPHelper sharedInstance];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
#ifdef TESTING
 //   [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];

    
    [Flurry startSession:@"NXYM7TZFYTR9RTHHQCKC"];
    [FlurryAds initialize:window.rootViewController];
    [Flurry logEvent:@"OPEN_APP_FRESH"];

    // Override point for customization after application launch.
    @try {
        [TestFlight takeOff:@"090797b3-e31e-40dd-8788-4777ea439f83"];
    }
    @catch (NSException *exception) {
        NSLog(@"testflight sucks");
    }
    @finally {
        
    }
    
    NSLog(@"PLEASE WORK");
    [self initializeBobbleFontDict];
    [self initializeBackgroundImageArray];
    //self.mouthCenter = CGPointMake(20,20);
    
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.soundFilePath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"bobbleSound.caf"]];

    self.percentLoaded = 0;
    self.bobbleBGIndex = 0;
    self.bobbleBodyIndex = 0;
    self.mouthType = 0;
    self.mouthScale = .4;
    return YES;
}

-(void)initializeBobbleFontDict{
    
    self.bobbleFontDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Unkempt-Bold", @"1000",
                           @"Unkempt-Bold", @"1001",
                           nil];
   
}


-(void)initializeBackgroundImageArray{

    Background *bg = [Background new];
    [bg setImageName:@"bg_beach"];
    [bg setName:@"Beach"];
    
    Background *bg1 = [Background new];
    [bg1 setImageName:@"bg_bar"];
    [bg1 setName:@"Dive Bar"];
    
    Background *bg2 = [Background new];
    [bg2 setImageName:@"bg_city"];
    [bg2 setName:@"City"];
    
    Background *bg3 = [Background new];
    [bg3 setImageName:@"bg_park"];
    [bg3 setName:@"Park"];
    
    self.bobbleBackgroundArray = [NSArray arrayWithObjects:bg, bg1, bg2, bg3,  nil];
    
    Body *bd1 = [Body new];
    [bd1 setImageName:@"bobble_surfer"];
    [bd1 setName:@"Surfer"];
    
    Body *bd2 = [Body new];
    [bd2 setImageName:@"bobble_female_cheerleader"];
    [bd2 setName:@"Surfer"];
    
    Body *bd3 = [Body new];
    [bd3 setImageName:@"bobble_female_cheerleader_dark"];
    [bd3 setName:@"Surfer"];
    
    Body *bd4 = [Body new];
    [bd4 setImageName:@"bobble_female_cowgirl"];
    [bd4 setName:@"Surfer"];
    
    Body *bd5 = [Body new];
    [bd5 setImageName:@"bobble_female_cowgirl_dark"];
    [bd5 setName:@"Surfer"];
    
    Body *bd6 = [Body new];
    [bd6 setImageName:@"bobble_female_soccer"];
    [bd6 setName:@"Surfer"];
    
    Body *bd7 = [Body new];
    [bd7 setImageName:@"bobble_female_soccer_dark"];
    [bd7 setName:@"Surfer"];
    
    Body *bd8 = [Body new];
    [bd8 setImageName:@"bobble_female_surfer"];
    [bd8 setName:@"Surfer"];
    
    Body *bd9 = [Body new];
    [bd9 setImageName:@"bobble_female_surfer_dark"];
    [bd9 setName:@"Surfer"];
    
    Body *bd10 = [Body new];
    [bd10 setImageName:@"bobble_surfer"];
    [bd10 setName:@"Surfer"];
    
    Body *bd11 = [Body new];
    [bd11 setImageName:@"bobble_male_hipster"];
    [bd11 setName:@"Surfer"];
    
    Body *bd12 = [Body new];
    [bd12 setImageName:@"bobble_male_hipster_dark"];
    [bd12 setName:@"Surfer"];
    
    Body *bd13 = [Body new];
    [bd13 setImageName:@"bobble_male_surfer"];
    [bd13 setName:@"Surfer"];
    
    Body *bd14 = [Body new];
    [bd14 setImageName:@"bobble_male_surfer_dark"];
    [bd14 setName:@"Surfer"];
    
    Body *bd15 = [Body new];
    [bd15 setImageName:@"bobble_male_tuxtee"];
    [bd15 setName:@"Surfer"];
    
    Body *bd16 = [Body new];
    [bd16 setImageName:@"bobble_male_tuxtee_dark"];
    [bd16 setName:@"Surfer"];
    
    Body *bd17 = [Body new];
    [bd17 setImageName:@"bobble_male_wrestler"];
    [bd17 setName:@"Surfer"];
    
    Body *bd18 = [Body new];
    [bd18 setImageName:@"bobble_male_wrestler_dark"];
    [bd18 setName:@"Surfer"];
    
    Body *bd19 = [Body new];
    [bd19 setImageName:@"bobble_female_surfer_dark"];
    [bd19 setName:@"Surfer"];
    
    self.bobbleBodyArray = [NSArray arrayWithObjects:bd2, bd3, bd4, bd5, bd6, bd7, bd8, bd9, bd11, bd12, bd13, bd14, bd15, bd16, bd17, bd18, bd19, nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // We need to properly handle activation of the application with regards to SSO
    // (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        
        [FBSession.activeSession reauthorizeWithPublishPermissions: [NSArray arrayWithObject:@"publish_actions"]
                                                   defaultAudience:FBSessionDefaultAudienceFriends
                                                 completionHandler:^(FBSession *session, NSError *error) {
                                                     if (!error) {
                                                         [self.shareController selectFriendsButtonAction:nil];
                                                         // If permissions granted, publish the story
                                                     }
                                                 }];
    }
}

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {

                // We have a valid session
                NSLog(@"User session found");
                
                if ([FBSession.activeSession.permissions
                     indexOfObject:@"publish_actions"] == NSNotFound) {
                    // No permissions found in session, ask for it

                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Successfully logged into Facebook."     message:@"You will now able to post to Facebook after granting us post permissions." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Allow Post", nil];
                    [alertView show];
                    
                    
                } else {
                     //If permissions present, publish the story
                    [self.shareController selectFriendsButtonAction:nil];
                }
            }
            break;
   //     case FBSessionStateOpenTokenExtended:{
           /* if (!error) {
                
                // We have a valid session
                NSLog(@"User session found");
                
                if ([FBSession.activeSession.permissions indexOfObject:@"publish_stream"] == NSNotFound) {
                    // No permissions found in session, ask for it
                    [FBSession.activeSession reauthorizeWithPublishPermissions: [NSArray arrayWithObjects:@"publish_stream", @"upload_video", nil]
                                                               defaultAudience:FBSessionDefaultAudienceFriends
                                                             completionHandler:^(FBSession *session, NSError *error) {
                                                                 if (!error) {
                                                                     [self.shareController selectFriendsButtonAction:nil];
                                                                     // If permissions granted, publish the story
                                                                 }
                                                             }];
                } else {
                    // If permissions present, publish the story
                    [self.shareController selectFriendsButtonAction:nil];
                }
            }
            break;
            */

    //    }
        case FBSessionStateOpenTokenExtended:
         /*   if (!error && [FBSession.activeSession.permissions
                     indexOfObject:@"publish_actions"] != NSNotFound) { 
                [self.shareController selectFriendsButtonAction:nil];
            }
          */
            break;
          
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateChangedNotification object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    return [FBSession openActiveSessionWithReadPermissions:nil
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}

@end
