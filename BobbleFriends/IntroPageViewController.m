//
//  IntroPageViewController.m
//  BobbleFriends
//
//  Created by Peter Kamm on 7/10/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

#import "IntroPageViewController.h"

@interface IntroPageViewController ()

@end

@implementation IntroPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];


    UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [t setText:@"BobbleFriends"];
    [t setFont:[UIFont fontWithName:@"Foco-Bold" size:20]];
    [t setTextColor:[UIColor whiteColor]];
    [t setBackgroundColor:[UIColor clearColor]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_bar"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];

    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Foco-Bold" size:20] forKey:UITextAttributeFont];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
