//
//  ShareViewController.m
//  BobbleFriends
//
//  Created by Peter Kamm on 1/14/13.
//  Copyright (c) 2013 Peter Kamm. All rights reserved.
//

#import "ShareViewController.h"
#import "AppDelegate.h"
#import "FlurryAdDelegate.h"
#import "FlurryAds.h"
#import "MainBobbleViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>



@interface ShareViewController ()

@end

@implementation ShareViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.friendPickerController = nil;
    self.descriptionTextView.delegate = self;
    [self.delegate performSelectorInBackground:@selector(saveBobble) withObject:nil];
    [self.loadingIndicator setHidden:NO];
    [self.loadingIndicator startAnimating];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


-(void)viewDidAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableShare) name:@"VIDEO_SAVED" object:nil];
    self.progTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:.25 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.progTimer forMode:NSRunLoopCommonModes];
    
    [self.delegate showInterstitialAd];
    
}


-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updateProgress{
    
    [self.progressLoadingInidicator setProgress:[APP_DELEGATE percentLoaded] animated:YES];
    if ([APP_DELEGATE percentLoaded] >= 1) {
        [self enableShare];
    }
}

-(void)finishedCreatingVideo{
    [self.loadingIndicator setHidden:YES];
    [self.checkmarkImageView setHidden:NO];
}

-(void)enableShare{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        [self.loadingIndicator setHidesWhenStopped:YES];
//        [self.loadingIndicator stopAnimating];
//        [self.loadingIndicator setHidden:YES];
        [self.shareButton setEnabled:YES];
        [self.progressLoadingInidicator setProgressTintColor:[UIColor greenColor]];
    }];
}


- (IBAction)selectFriendsButtonAction:(id)sender {
    
    [self.shareButton setEnabled:NO];
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Select Friends";
        self.friendPickerController.delegate = self;
    }
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    if (![self.friendPickerController presentedViewController]) {
        [self.delegate presentViewController:self.friendPickerController animated:YES completion:nil];
    }
}

- (void)facebookViewControllerCancelWasPressed:(id)sender{
    NSLog(@"Friend selection cancelled.");
    [self handlePickerDone];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender{

    [self.delegate dismissViewControllerAnimated:YES completion:^{
        for (id<FBGraphUser> user in self.friendPickerController.selection) {
            NSLog(@"Friend selected: %@", user.name);
            [self uploadiOS5Plus:user];
        }
    }];
}

- (void) handlePickerDone{
    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareButtonPressed:(id)sender{
    [APP_DELEGATE setShareController:self];
    
    if (FBSession.activeSession.isOpen){
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_stream"] != NSNotFound) {
            [self selectFriendsButtonAction:sender];
        }else{
            [FBSession.activeSession
             reauthorizeWithPublishPermissions: [NSArray arrayWithObjects:@"publish_stream", nil]
             defaultAudience:FBSessionDefaultAudienceFriends
             completionHandler:^(FBSession *session, NSError *error) {
                 if (!error) {
                     [self selectFriendsButtonAction:nil];
                 }
             }];
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please log in to Facebook" message:@"In order to post to Facebook you must first log in." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log in", nil];
        [alertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        [APP_DELEGATE openSessionWithAllowLoginUI:YES];
    }
}

-(void)uploadiOS5Plus:(id<FBGraphUser>)user{
    UIActivityIndicatorView *newInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [newInd setCenter:self.view.center];
    [self.view addSubview:newInd];
    [newInd setHidden:NO];
    [newInd startAnimating];
    [self.shareButton setEnabled:NO];

    if (FBSession.activeSession.isOpen) {
        
        NSString* filePath = [APP_DELEGATE outputFileName];
        NSURL*    outputFileUrl = [NSURL fileURLWithPath:filePath];
        NSData *videoData = [NSData dataWithContentsOfFile:filePath];
        
        NSDictionary* videoObject = [NSDictionary dictionaryWithObjectsAndKeys:
                                                @"BobbleFriend",@"title",
                                                self.descriptionTextView.text, @"description",
                                                @"video/quicktime", @"contentType",
                                                videoData, [outputFileUrl absoluteString],
                                            nil];
        

        FBRequest *uploadRequest = [FBRequest requestWithGraphPath:[NSString stringWithFormat:@"%@/videos",[user id]]
                                                        parameters:videoObject
                                                        HTTPMethod:@"POST"];
        
        
        [uploadRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error){
                NSLog(@"Done: %@", result);
                [newInd removeFromSuperview];
                [self enableShare];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done!" message:@"Your bobble has been posted to your friend's wall" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            else
                NSLog(@"Error: %@", error.localizedDescription);
        }];
    }
}




- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
/*    CGRect keyboardEndFrame;
    [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    //CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame fromView:nil];
    
    if (CGRectIntersectsRect(keyboardEndFrame, [[self delegate] view].frame)) {
        [self keyboardWillShow:notification];
    } else {
        [self keyboardWillHide:notification];
    }
 */
}


- (void)keyboardWillShow:(NSNotification*)aNotification{
    
    NSDictionary* info = [aNotification userInfo];
    
    NSValue *keyboardEndFrameValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [keyboardEndFrameValue CGRectValue];
    NSNumber *animationDurationNumber = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = [animationDurationNumber doubleValue];

    UIViewAnimationCurve animationCurve;
    [[[aNotification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];

    UIViewAnimationOptions animationOptions = animationCurve << 16;   
    
    [UIView animateWithDuration:animationDuration delay:0 options:animationOptions animations:^{
        
        [self.controlView setCenter:CGPointMake(self.controlView.frame.size.width/2, self.view.frame.size.height-keyboardEndFrame.origin.y - 20)];
        
        
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification*)aNotification{
    
    NSDictionary* info = [aNotification userInfo];
    NSNumber *animationDurationNumber = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = [animationDurationNumber doubleValue];    
    UIViewAnimationCurve animationCurve;
    [[[aNotification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    UIViewAnimationOptions animationOptions = animationCurve << 16;
    
    [UIView animateWithDuration:animationDuration delay:0 options:animationOptions animations:^{
        
        [self.controlView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - (self.controlView.frame.size.height/2))];
        
        
    } completion:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ( [text isEqualToString:@"\n"] ) {
        [textView resignFirstResponder];
    }
    
    return YES;
}
- (IBAction)SMSShareButtonPressed:(id)sender {
    MFMessageComposeViewController *tempMailCompose = [[MFMessageComposeViewController alloc] init];
	
	tempMailCompose.messageComposeDelegate = self;
	[tempMailCompose setSubject:@"Bobble Friend"];
	[tempMailCompose setBody:@"Here's your bobble"];
    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSString* filePath = [[documents stringByAppendingPathComponent:[APP_DELEGATE outputFileName]] stringByAppendingString:@".mov"];
    NSData *vidData = [NSData dataWithContentsOfFile:filePath];
    [tempMailCompose addAttachmentData:vidData typeIdentifier:(NSString*)kUTTypeMovie filename:@"BobbleFriend.mov"];
    [self.delegate presentViewController:tempMailCompose animated:YES
                              completion:^{
                                  
                              }];
}
- (IBAction)emailSharebuttonPressed:(id)sender {
    [self displayComposerSheet:@"Send ya bobble"];
}

// Displays an email composition interface inside the application. Populates all the Mail fields.
- (void) displayComposerSheet:(NSString *)body {
	
	MFMailComposeViewController *tempMailCompose = [[MFMailComposeViewController alloc] init];
	
	tempMailCompose.mailComposeDelegate = self;
	[tempMailCompose setSubject:@"Bobble Friend"];
	[tempMailCompose setMessageBody:body isHTML:NO];
    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSString* filePath = [[documents stringByAppendingPathComponent:[APP_DELEGATE outputFileName]] stringByAppendingString:@".mov"];
    NSData *vidData = [NSData dataWithContentsOfFile:filePath];
    [tempMailCompose addAttachmentData:vidData mimeType:@"video/quicktime" fileName:@"BobbleFriend"];
	
    [self.delegate presentViewController:tempMailCompose animated:YES
                     completion:^{
                         
                     }];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Result: canceled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Result: saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Result: sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Result: failed");
			break;
		default:
			NSLog(@"Result: not sent");
			break;
	}
	[self.delegate dismissViewControllerAnimated:YES completion:^{
        
    }];
}

// Launches the Mail application on the device. Workaround
-(void)launchMailAppOnDevice:(NSString *)body{
	NSString *recipients = [NSString stringWithFormat:@"mailto:%@?subject=%@", @"test@mail.com", @"iPhone App recommendation"];
	NSString *mailBody = [NSString stringWithFormat:@"&body=%@", body];
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, mailBody];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

// Call this method and pass parameters
-(void) showComposer:(id)sender{
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil){
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail]){
			[self displayComposerSheet:sender];
		}else{
			[self launchMailAppOnDevice:sender];
		}
	}else{
		[self launchMailAppOnDevice:sender];
	}
}


-(void)textViewDidBeginEditing:(UITextView *)textView{
    textView.text = @"";
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    
    
    
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLoadingIndicator:nil];
    [self setShareButton:nil];
    [self setProgressLoadingInidicator:nil];
    [self setDescriptionTextView:nil];
    [self setControlView:nil];
    [super viewDidUnload];
}
@end
