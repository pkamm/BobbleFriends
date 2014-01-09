//
//  SavedBobbleViewController.m
//  BobbleFriends
//
//  Created by Peter Kamm on 6/3/13.
//  Copyright (c) 2013 Peter Kamm. All rights reserved.
//

#import "SavedBobbleViewController.h"
#import "AppDelegate.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface SavedBobbleTableCell ()

@end

@implementation SavedBobbleTableCell
- (IBAction)shareButtonPressed:(id)sender {

    [APP_DELEGATE setShareController:self.delegate];
    [APP_DELEGATE setOutputFileName:[self filePath]];
    
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

@end

@interface SavedBobbleViewController ()

@end

@implementation SavedBobbleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [_dateFormatter setDateFormat:@"MMM dd hh:mm a"];
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[NSUserDefaults standardUserDefaults] arrayForKey:@"bobbleArray"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSString *bobbleId = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"bobbleArray"] objectAtIndex:indexPath.row];
    SavedBobbleTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *mediaDisplayImagePath = [NSString stringWithFormat:@"%@/%@.png",documentsDirectory, bobbleId];
    
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* attrs = [fm attributesOfItemAtPath:mediaDisplayImagePath error:nil];
    
    if (attrs != nil) {
        NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
    //    NSLog(@"Date Created: %@", [[date description]);
        [[cell bobbleTitle] setText:[NSString stringWithFormat:@"Date Created: %@", [date description]]];

    }
    else {
        NSLog(@"Not found");
    }
    
    UIImage* image = [UIImage imageWithContentsOfFile:mediaDisplayImagePath];
    cell.filePath = bobbleId;
    cell.delegate = self;
  //  [[cell bobbleTitle] setText:bobbleId];
    [[cell bobbleImage] setImage:image];

    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0] ;

    NSURL *movPath = [NSURL fileURLWithPath:[[documents stringByAppendingPathComponent:[[[NSUserDefaults standardUserDefaults] arrayForKey:@"bobbleArray"] objectAtIndex:indexPath.row]] stringByAppendingString:@".mov"]];
    
 //   if ( [[NSFileManager defaultManager] isReadableFileAtPath:movPath] ){

    self.player = [[MPMoviePlayerViewController alloc] initWithContentURL:movPath];
    
    [self presentMoviePlayerViewControllerAnimated:self.player];
 //   }
    //[[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[[[NSUserDefaults standardUserDefaults] arrayForKey:@"bobbleArray"] objectAtIndex:indexPath.row]]];
    //[self.player prepareToPlay];
   // [self.player.view setFrame: self.view.bounds];  // player's frame must match parent's
   // [self.view addSubview: self.player.view];
   // [self.player play];
}
- (IBAction)backButtonPushed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)uploadiOS5Plus:(id<FBGraphUser>)user{
    UIActivityIndicatorView *newInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [newInd setCenter:self.view.center];
    [self.view addSubview:newInd];
    [newInd setHidden:NO];
    [newInd startAnimating];
    
    if (FBSession.activeSession.isOpen) {
        NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
        NSString* filePath = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[APP_DELEGATE outputFileName]]];
        NSLog(@"path: %@",filePath);
        NSURL*    outputFileUrl = [NSURL fileURLWithPath:filePath];
        NSData *videoData = [NSData dataWithContentsOfFile:filePath];
        
        NSDictionary* videoObject = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"BobbleFriend",@"title",
                                     @"description", @"description",
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done!" message:@"Your bobble has been posted to your friend's wall" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            else
                NSLog(@"Error: %@", error.localizedDescription);
        }];
    }
}

- (IBAction)selectFriendsButtonAction:(id)sender {
    
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Select Friends";
        self.friendPickerController.delegate = self;
    }
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    if (![self.friendPickerController presentedViewController]) {
        [self presentViewController:self.friendPickerController animated:YES completion:nil];
    }
}

- (void)facebookViewControllerCancelWasPressed:(id)sender{
    NSLog(@"Friend selection cancelled.");
    [self handlePickerDone];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:^{
        for (id<FBGraphUser> user in self.friendPickerController.selection) {
            NSLog(@"Friend selected: %@", user.name);
            [self uploadiOS5Plus:user];
        }
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        [APP_DELEGATE openSessionWithAllowLoginUI:YES];
    }
}

- (void) handlePickerDone{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
    [self setSavedBobbleTableView:nil];
    [super viewDidUnload];
}
@end
