//
//  ChooseMouthViewController.m
//  BobbleFriends
//
//  Created by Peter Kamm on 2/27/13.
//  Copyright (c) 2013 Peter Kamm. All rights reserved.
//

#import "ChooseMouthViewController.h"
#import "MainBobbleViewController.h"
#import "AppDelegate.h"

@interface ChooseMouthViewController ()

@end

@implementation ChooseMouthViewController

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
    [self.headImageView setImage:[(AppDelegate*)[[UIApplication sharedApplication] delegate] bobbleFaceImage]];
	// Do any additional setup after loading the view.
    [self.sizeSlider setValue:[APP_DELEGATE mouthScale] animated:NO];
    
   // self.mouthImageView = [[ZoomingImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - width/2, self.view.frame.size.height/2 - height/2, width, height)];
    self.mouthImageView = [[ZoomingImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
  //  [self.mouthImageView setCenter:CGPointMake(self.headImageView.frame.size.width/2, 100)];
    [self.mouthImageView setContentMode:UIViewContentModeScaleToFill];
    [self.mouthImageView setBackgroundColor:[UIColor clearColor]];
    [self.headImageView setClipsToBounds:YES];
    [self.headImageView addSubview:self.mouthImageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)maleMouthPressed:(id)sender {
    [APP_DELEGATE setMouthType:1];
     _mouthImage = [UIImage imageNamed:@"mouth_male_01"];
    [self.mouthImageView setImage:_mouthImage];
    [self setMouthView];
}

- (IBAction)femaleMouthPressed:(id)sender {
    [APP_DELEGATE setMouthType:2];
    _mouthImage = [UIImage imageNamed:@"female_mouth_01"];
    [self.mouthImageView setImage:_mouthImage];
    [self setMouthView];
}

-(void)setMouthView{
    [self.mouthImageView setHidden:NO];
    CGSize mouthSize = _mouthImage.size;
    [self.mouthImageView setFrame:CGRectMake(0,0, mouthSize.width*self.sizeSlider.value, mouthSize.height*self.sizeSlider.value)];
    [self.mouthImageView setCenter:CGPointMake(self.headImageView.frame.size.width/2, self.headImageView.frame.size.height/2+60)];
}

- (IBAction)noMouthPressed:(id)sender {
    [APP_DELEGATE setMouthType:0];
    [self.mouthImageView setHidden:YES];
}

- (IBAction)sizeSliderSlid:(id)sender {
    [self setMouthView];
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSMutableSet *currentTouches = [[event touchesForView:self.view] mutableCopy];
//    [currentTouches minusSet:touches];
//    if ([currentTouches count] > 0) {
//        
//        
//    }
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self touchesEnded:touches withEvent:event];
//}
//
//


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

//    [APP_DELEGATE setMouthTransform:self.mouthImageView.transform];
//    [APP_DELEGATE setMouthScale:self.sizeSlider.value];
    [(MainBobbleViewController*)[segue destinationViewController] setHeadWithMouthImages:[self createHeadWithMouthImages]];
}

-(NSArray*)createHeadWithMouthImages{
    
    NSMutableArray *tempImageArray = [NSMutableArray arrayWithCapacity:3];
    NSLog(@"%f %f %f %f",self.mouthImageView.frame.origin.x,self.mouthImageView.frame.origin.x, self.mouthImageView.frame.size.width, self.mouthImageView.frame.size.height);
    for (int i = 0; i <= 7; i++) {
        UIGraphicsBeginImageContextWithOptions(self.headImageView.frame.size, NO, 0.0f);
//        [self.headImageView.image drawInRect:self.headImageView.frame];
        [self.headImageView.image drawInRect:CGRectMake(0, 0, self.headImageView.frame.size.width, self.headImageView.frame.size.height)];

        [[self mouthAtLevel:i] drawInRect:self.mouthImageView.frame];

        [tempImageArray addObject:UIGraphicsGetImageFromCurrentImageContext()];
        UIGraphicsEndImageContext();
    }
    return tempImageArray;
}
//
//-(void)setupMouthImage{
//    
//
//    CGSize mouthSize = self.mouthImageView.image.size;
//    [self.mouthImageView setFrame:CGRectMake(0,0, mouthSize.width*[APP_DELEGATE mouthScale], mouthSize.height*[APP_DELEGATE mouthScale])];
//    
//    [self.mouthImageView setCenter:CGPointMake(self.headImageView.frame.size.width/2, self.headImageView.frame.size.height/2+60)];
//    [self.mouthImageView setTransform:[APP_DELEGATE mouthTransform]];
//    
//    [self createHeadWithMouthImages];
//    [self setMouth:0];
//}

-(UIImage*)mouthAtLevel:(int)mouthLevel{
    UIImage *mouthImage = nil;
    switch ([APP_DELEGATE mouthType]) {
        case 0:break;
            
        case 1:{
            switch (mouthLevel) {
                case 0:
                    mouthImage = [UIImage imageNamed:@"mouth_male_01"];
                    break;
                case 1:
                    mouthImage = [UIImage imageNamed:@"mouth_male_02"];
                    break;
                case 2:
                    mouthImage = [UIImage imageNamed:@"mouth_male_03"];
                    break;
                case 3:
                    mouthImage = [UIImage imageNamed:@"mouth_male_04"];
                    break;
                case 4:
                    mouthImage = [UIImage imageNamed:@"mouth_male_05"];
                    break;
                case 5:
                    mouthImage = [UIImage imageNamed:@"mouth_male_06"];
                    break;
                case 6:
                    mouthImage = [UIImage imageNamed:@"mouth_male_07"];
                    break;
                default:
                    break;
            }
        }
            break;
            
        case 2:{
            switch (mouthLevel) {
                case 0:
                    mouthImage = [UIImage imageNamed:@"female_mouth_01"];
                    break;
                case 1:
                    mouthImage = [UIImage imageNamed:@"female_mouth_02"];
                    break;
                case 2:
                    mouthImage = [UIImage imageNamed:@"female_mouth_03"];
                    break;
                case 3:
                    mouthImage = [UIImage imageNamed:@"female_mouth_04"];
                    break;
                case 4:
                    mouthImage = [UIImage imageNamed:@"female_mouth_05"];
                    break;
                case 5:
                    mouthImage = [UIImage imageNamed:@"female_mouth_06"];
                    break;
                case 6:
                    mouthImage = [UIImage imageNamed:@"female_mouth_07"];
                    break;
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    return mouthImage;
}

- (IBAction)goBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidUnload {
    [self setHeadImageView:nil];
    [self setMouthImageView:nil];
    [self setSizeSlider:nil];
    [super viewDidUnload];
}
@end
