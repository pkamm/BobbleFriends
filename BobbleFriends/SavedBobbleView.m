//
//  SavedBobbleView.m
//  BobbleFriends
//
//  Created by Peter Kamm on 2/13/14.
//  Copyright (c) 2014 Peter Kamm. All rights reserved.
//

#import "SavedBobbleView.h"
#import "AppDelegate.h"
#import "SavedBobbleViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>


@implementation SavedBobbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"SavedBobbleView" owner:self options:nil] objectAtIndex:0];
       // [self addSubview:self.view];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // CUSTOM INITIALIZATION HERE
    }
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"SavedBobbleView" owner:self options:nil] objectAtIndex:0];
    }
    return self;
    
}
- (IBAction)shareButtonPressed:(id)sender {
    [APP_DELEGATE setShareController:self.delegate];
    [APP_DELEGATE setOutputFileName:[self bobbleID]];
    
    NSLog(@"path: %@", [APP_DELEGATE outputFileName]);
    
    if (FBSession.activeSession.isOpen){
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_stream"] != NSNotFound) {
            [self.delegate selectFriendsButtonAction:sender];
        }else{
            [FBSession.activeSession
             reauthorizeWithPublishPermissions: [NSArray arrayWithObjects:@"publish_stream", nil]
             defaultAudience:FBSessionDefaultAudienceFriends
             completionHandler:^(FBSession *session, NSError *error) {
                 if (!error) {
                     [self.delegate selectFriendsButtonAction:nil];
                 }
             }];
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please log in to Facebook" message:@"In order to post to Facebook you must first log in." delegate:self.delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log in", nil];
        [alertView show];
    }
}
- (IBAction)viewBobbleButtonPressed:(id)sender {
    [self.delegate playBobbleMovie:self.bobbleID];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
