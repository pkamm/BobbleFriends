//
//  PhotoPickerViewController.m
//  BobbleFriends
//
//  Created by Peter Kamm on 7/7/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

#import "PhotoPickerViewController.h"
#import "FaceCroppingViewController.h"

@interface PhotoPickerViewController ()

@end

@implementation PhotoPickerViewController
@synthesize chooseImageFromCameraRollButton;
@synthesize sampleChosenImageView;
@synthesize useImageButton;
@synthesize chosenImage;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)chooseImageFromCameraRollPressed:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:^{
        }];
    }
    
}

- (IBAction)takePhotoButtonPressed:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    self.chosenImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];;
 //   [self.sampleChosenImageView setImage:self.chosenImage];
   // [self.useImageButton setHidden:NO];
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"photocrop" sender:self];
    }];
/*    FaceCroppingViewController *facey = [FaceCroppingViewController new];
    [facey setChosenImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
    [self.navigationController pushViewController:facey animated:YES];
 */
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    [(FaceCroppingViewController*)[segue destinationViewController] setChosenImage:self.chosenImage];
}

 
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidUnload {
    [self setSampleChosenImageView:nil];
    [self setUseImageButton:nil];
    [super viewDidUnload];
}
@end
