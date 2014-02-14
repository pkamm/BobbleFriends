//
//  SavedBobbleViewController.m
//  BobbleFriends
//
//  Created by Peter Kamm on 6/3/13.
//  Copyright (c) 2013 Peter Kamm. All rights reserved.
//

#import "SavedBobbleViewController.h"
#import "SavedBobbleView.h"
#import "AppDelegate.h"

#define BOBBLE_BORDER 15

@interface SavedBobbleTableCell ()

@end

@implementation SavedBobbleTableCell

@end

@interface SavedBobbleViewController ()

@end

@implementation SavedBobbleViewController

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
    return MAX([[[NSUserDefaults standardUserDefaults] arrayForKey:@"bobbleArray"] count],3);
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SavedBobbleTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    NSInteger bobbleIndex = indexPath.row*2;
    
    [self addBobbleToCell:cell atIndex:bobbleIndex];
    [self addBobbleToCell:cell atIndex:bobbleIndex+1];
    
    return cell;
}

-(void)addBobbleToCell:(UITableViewCell*)cell atIndex:(NSInteger)index{
    
    if ([[[NSUserDefaults standardUserDefaults] arrayForKey:@"bobbleArray"] count] > index) {
        
        NSString *bobbleId = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"bobbleArray"] objectAtIndex:index];
        
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *mediaDisplayImagePath = [NSString stringWithFormat:@"%@/%@.png",documentsDirectory, bobbleId];
        
        NSFileManager* fm = [NSFileManager defaultManager];
        
        if ([fm fileExistsAtPath:mediaDisplayImagePath]) {
            //            NSDictionary* attrs = [fm attributesOfItemAtPath:mediaDisplayImagePath error:nil];
            
            SavedBobbleView *bobbleView = [[SavedBobbleView alloc] init];
            [bobbleView setDelegate:self];
            [bobbleView.viewBobbleButton setBackgroundImage:[UIImage imageWithContentsOfFile:mediaDisplayImagePath] forState:UIControlStateNormal];
            
            [bobbleView setBobbleID:bobbleId];
            
            CGRect frame = bobbleView.frame;
            
            if (index % 2 == 1) {
                frame.origin.x = cell.bounds.size.width - frame.size.width - BOBBLE_BORDER;
            }else{
                frame.origin.x = BOBBLE_BORDER;
            }
            
            [bobbleView setFrame:frame];
            [cell addSubview:bobbleView];
        }
    }
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}
- (IBAction)backButtonPushed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setSavedBobbleTableView:nil];
    [super viewDidUnload];
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

-(void)playBobbleMovie:(NSString*)bobbleID{
    
    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0] ;
    
    NSURL *movPath = [NSURL fileURLWithPath:[[documents stringByAppendingPathComponent:bobbleID] stringByAppendingString:@".mov"]];
    
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


@end
