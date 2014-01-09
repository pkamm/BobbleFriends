//
//  ChooseBackgroundViewController.m
//  BobbleFriends
//
//  Created by Peter Kamm on 12/18/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

#import "ChooseBackgroundViewController.h"
#import "AppDelegate.h"
#import "Background.h"
#import "Flurry.h"
#import "FlurryAds.h"


@interface ChooseBackgroundViewController ()

@end

@implementation ChooseBackgroundViewController

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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    /**
     * We will show banner and interstitial integrations here. *
     */
    // Register yourself as a delegate for ad callbacks
    [FlurryAds setAdDelegate:self]; // 1. Fetch and display banner ads
    [FlurryAds fetchAndDisplayAdForSpace:@"BANNER_MAIN_VC" view:self.view size:BANNER_BOTTOM];
    // 2. Fetch fullscreen ads for later display
    //[FlurryAds fetchAdForSpace:@”INTERSTITIAL_MAIN_VC” frame:self.view.frame size:FULLSCREEN];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // Remove Banner Ads and reset delegate
    [FlurryAds removeAdFromSpace:@"BANNER_MAIN_VC"];
    [FlurryAds setAdDelegate:nil];
}

/*
 * Itisrecommendedtopauseappactivitieswhenaninterstitialisshown. * Listentoshoulddisplaydelegate.
 */
-(BOOL)spaceShouldDisplay:(NSString*)adSpace interstitial:(BOOL) interstitial {
    if (interstitial) {
        // Pause app state here
    }
    // Continue ad display
    return YES;
}

- (void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial { if (interstitial) {
    // Resume app state here
} }

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[APP_DELEGATE bobbleBackgroundArray] count]/2;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 180)];
    
    [self addBackgroundIndex:indexPath.row*2
                secondInCell:NO
                      toCell:cell];
    
    if ([[APP_DELEGATE bobbleBodyArray] objectAtIndex:indexPath.row*2+1]) {
        [self addBackgroundIndex:indexPath.row*2+1
                    secondInCell:YES
                          toCell:cell];
    }
    return cell;
}

-(void)addBackgroundIndex:(int)bgIndex secondInCell:(BOOL)isSecond toCell:(UITableViewCell*)cell{
    
    UIButton *backgroundView = [[UIButton alloc] initWithFrame:CGRectMake(20, 12, 130, 162)];
    [backgroundView setTag:bgIndex];
    Background* bg =  [[APP_DELEGATE bobbleBackgroundArray] objectAtIndex:bgIndex];
    
    [backgroundView setShowsTouchWhenHighlighted:YES];
    [backgroundView addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *picture = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[bg imageName]]];
    [cell addSubview:backgroundView];
    [backgroundView addSubview:picture];
    [picture setContentMode:UIViewContentModeScaleToFill];
    [picture setFrame:CGRectMake(8, 10, 114, 120)];

//    [cell setBackgroundColor:[UIColor redColor]];
    [cell addSubview:backgroundView];
    if (isSecond) {
        [backgroundView setCenter:CGPointMake(cell.frame.size.width*3/4, cell.frame.size.height/2+72)];
    }else{
        [backgroundView setCenter:CGPointMake(cell.frame.size.width/4, cell.frame.size.height/2+72)];
    }
    
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 180;
}


- (IBAction)backButtonPressed:(id)sender {
    
    if (sender) {
        [APP_DELEGATE setBobbleBGIndex:[sender tag]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
