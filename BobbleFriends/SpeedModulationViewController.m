//
//  SpeedModulationViewController.m
//  BobbleFriends
//
//  Created by Peter Kamm on 1/6/13.
//  Copyright (c) 2013 Peter Kamm. All rights reserved.
//

#import "SpeedModulationViewController.h"

@interface SpeedModulationViewController ()

@end

@implementation SpeedModulationViewController

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

- (void)viewDidUnload {
    [self setSpeedSlider:nil];
    [self setBobbleSlider:nil];
    [super viewDidUnload];
}
@end
