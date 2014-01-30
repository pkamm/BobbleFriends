//
//  CopOverlayViewController.m
//  BobbleFriends
//
//  Created by Peter Kamm on 11/11/13.
//  Copyright (c) 2013 Peter Kamm. All rights reserved.
//

#import "CopOverlayViewController.h"

@interface CopOverlayViewController ()

@end

@implementation CopOverlayViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)okButtonPressed:(id)sender {
    [self.delegate performSelector:@selector(hideOverlay) withObject:nil];

}
- (IBAction)dontShowAgainButtonPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldShowCropInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.delegate performSelector:@selector(hideOverlay) withObject:nil];
}

@end
