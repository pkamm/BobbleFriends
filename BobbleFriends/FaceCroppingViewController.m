//
//  FaceCroppingViewController.m
//  BobbleFriends
//
//  Created by Peter Kamm on 8/6/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

#import "FaceCroppingViewController.h"
#import "AppDelegate.h"

@interface FaceCroppingViewController ()

@end

@implementation FaceCroppingViewController
@synthesize zoomingImageView;
@synthesize chosenImage;
@synthesize cropFaceButton;

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

-(void)viewDidAppear:(BOOL)animated{


    self.chosenImage = [self scaleAndRotateImage:self.chosenImage];

    CGImageRef imgRef = self.chosenImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    NSLog(@"w: %f, h: %f",width,height);
        
    self.zoomingImageView = [[ZoomingImageView alloc] initWithFrame:CGRectMake(self.faceHolderView.frame.size.width/2 - width/2, self.faceHolderView.frame.size.height/2 - height/2, width, height)];
    [self.zoomingImageView setImage:self.chosenImage];
    [self.zoomingImageView setContentMode:UIViewContentModeCenter];
    [self.zoomingImageView setBackgroundColor:[UIColor clearColor]];
    [self.faceHolderView insertSubview:self.zoomingImageView belowSubview:self.faceCropOutlineImageView];
    self.overlay = [[CopOverlayViewController alloc] init];
    [self.overlay setDelegate:self];
    [self.view addSubview:self.overlay.view];
    
}

-(void)hideOverlay{
    [self.overlay.view removeFromSuperview];
    self.overlay = nil;
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)viewDidUnload {
    [self setZoomingImageView:nil];
    [self setCropFaceButton:nil];
    [self setFaceCropOutlineImageView:nil];
    [super viewDidUnload];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
    [self cropFaceButtonPressed:sender];
}

- (IBAction)cropFaceButtonPressed:(id)sender {
    
    UIImage *tt = [self createWhiteMaskBackgroundOfSize:self.chosenImage.size];
    
    UIImage *masked = [self maskImage:tt withMask:[UIImage imageNamed:@"face_mask.png"]];
    
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setBobbleFaceImage:masked];
    
    [self.zoomingImageView removeFromSuperview];

}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
	CGImageRef maskRef = maskImage.CGImage;
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
	return [UIImage imageWithCGImage:masked];
}

- (UIImage*)createWhiteMaskBackgroundOfSize:(CGSize)imageSize
{
    CGFloat imageScale = (CGFloat)1.0;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGRect rect = CGRectMake(0, 0,  width * imageScale, height * imageScale);
    CGRect screenRect =  CGRectMake(0,0,self.faceHolderView.frame.size.width,self.faceHolderView.frame.size.height);//suspect
    
    // Begin the drawing
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Clear whole thing
    CGContextClearRect(ctx, rect);
    
    // Transform the image (as the image view has been transformed)
    CGContextTranslateCTM(ctx, rect.size.width*0.5, rect.size.height*0.5);
    CGContextConcatCTM(ctx, self.zoomingImageView.transform);
    CGContextTranslateCTM(ctx, -rect.size.width*0.5, -rect.size.height*0.5);
    
    // Tanslate and scale upside-down to compensate for Quartz's inverted coordinate system
    CGContextTranslateCTM(ctx, 0.0, rect.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    // Draw view into context
    CGContextDrawImage(ctx, rect, self.chosenImage.CGImage);
    
    // Create the new UIImage from the context
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    NSLog(@"1new ht: %f",newImage.size.height);
   
    // End the drawing
    UIGraphicsEndImageContext();
    
    CGRect myImageArea = CGRectMake (rect.size.width/2 - screenRect.size.width/2, rect.size.height/2 - screenRect.size.height/2,screenRect.size.width, screenRect.size.height);
    
    CGImageRef mySubimage = CGImageCreateWithImageInRect (newImage.CGImage, myImageArea);
    
    return [UIImage imageWithCGImage:mySubimage];
}



-(UIImage*)scaleAndRotateImage:(UIImage*)image{
    
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    

    int kMaxResolution = 1000;

    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}




@end
