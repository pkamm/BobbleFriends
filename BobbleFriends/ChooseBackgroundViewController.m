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
#import "BobbleIAPHelper.h"
#import <StoreKit/StoreKit.h>

#define NUM_FREE_BG 2

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    /**
     * We will show banner and interstitial integrations here. *
     */
    // Register yourself as a delegate for ad callbacks
    [FlurryAds setAdDelegate:self]; // 1. Fetch and display banner ads
    [FlurryAds fetchAndDisplayAdForSpace:@"BANNER_MAIN_VC" view:self.view size:BANNER_BOTTOM];
    // 2. Fetch fullscreen ads for later display
    //[FlurryAds fetchAdForSpace:@”INTERSTITIAL_MAIN_VC” frame:self.view.frame size:FULLSCREEN];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[BobbleIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            //NSLog(@"%@",[(SKProduct *)[products objectAtIndex:0] localizedTitle]);
        }
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    // Remove Banner Ads and reset delegate
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [FlurryAds removeAdFromSpace:@"BANNER_MAIN_VC"];
    [FlurryAds setAdDelegate:nil];
    [super viewWillDisappear:animated];
}

/*
 * Itisrecommendedtopauseappactivitieswhenaninterstitialisshown. * Listentoshoulddisplaydelegate.
 */
-(BOOL)spaceShouldDisplay:(NSString*)adSpace interstitial:(BOOL) interstitial {
    if (interstitial) {
        // Pause app state here
    }
    // Continue ad display
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"com.blankworldwide.bobbleFriends.purchase"]) {
        return YES;
    }else{
        return NO;
    }
}

- (void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial { if (interstitial) {
    // Resume app state here
} }

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[APP_DELEGATE bobbleBackgroundArray] count]/2;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 180)];
    [cell setBackgroundColor:[UIColor clearColor]];
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
    [backgroundView setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *picture = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[bg imageName]]];
    [cell addSubview:backgroundView];
    [backgroundView addSubview:picture];
    [picture setContentMode:UIViewContentModeScaleToFill];
    [picture setFrame:CGRectMake(8, 10, 114, 120)];

    [cell addSubview:backgroundView];
    
    if (isSecond) {
        [backgroundView setCenter:CGPointMake(cell.frame.size.width*3/4, cell.frame.size.height/2+72)];
    }else{
        [backgroundView setCenter:CGPointMake(cell.frame.size.width/4, cell.frame.size.height/2+72)];
    }
    if (bgIndex >= NUM_FREE_BG && ![[NSUserDefaults standardUserDefaults] boolForKey:@"com.blankworldwide.bobbleFriends.purchase"]) {
        [self addPurchaseLock:backgroundView];
    }else{
        [backgroundView addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)addPurchaseLock:(UIButton*)button{
    
    UIImageView *lockImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"locked_overlay.png"]];
    [lockImage setAlpha:.8];
    [lockImage setFrame:button.bounds];
    [button addSubview:lockImage];
    [button addTarget:self action:@selector(makePurchase:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)makePurchase:(id)sender{
    
    [[BobbleIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success && products && [products count] > 0) {
            
            SKProduct *product = [products objectAtIndex:0];
            NSLog(@"Buying %@...", product.productIdentifier);
            [[BobbleIAPHelper sharedInstance] buyProduct:product];
        }
    }];
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

- (void)productPurchased:(NSNotification *)notification {
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
