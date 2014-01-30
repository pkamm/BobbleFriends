//
//  MainBobbleViewController.m
//  BobbleFriends
//
//  Created by Peter Kamm on 9/17/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

#import "MainBobbleViewController.h"
#import "ZoomingImageView.h"
#import "AppDelegate.h"
#import "AudioRecorderViewController.h"
#import "Background.h"
#import "Body.h"
#import "FlurryAdDelegate.h"
#import "FlurryAds.h"

NSString *adSpaceName = @"INTERSTITIAL_MAIN_VIEW";


@interface MainBobbleViewController ()

@end

@implementation MainBobbleViewController

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
    
    _bobbleIntensity = 0.5;
    _bobbleSpeed = -.4;
    
    imageArray = [[NSMutableArray alloc] initWithCapacity:200];
    NSLog(@"sizeofHead: %f, %f", [APP_DELEGATE bobbleFaceImage].size.width, [APP_DELEGATE bobbleFaceImage].size.height );
    self.bobblingHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 200)];
    [self.bobblingHeadView setContentMode:UIViewContentModeScaleToFill];

    self.headImageView = [[UIImageView alloc] initWithImage:[[self headWithMouthImages] objectAtIndex:0]];
    [self.headImageView setContentMode:UIViewContentModeScaleToFill];
    [self.headImageView setFrame:self.bobblingHeadView.frame];
    
    [self.bobblingHeadView setBackgroundColor:[UIColor clearColor]];
    [self.headImageView setBackgroundColor:[UIColor clearColor]];
    
    [self.bobblingHeadView addSubview:self.headImageView];
    [self.view addSubview:self.bobblingHeadView];
    [self.bobblingHeadView setCenter:CGPointMake(self.view.center.x, 150)];
    
    NSLog(@"frameHead: %f, %f", self.headImageView.frame.size.width, self.headImageView.frame.size.height );
    NSLog(@"frameHead: %f, %f", self.bobblingHeadView.frame.size.width, self.bobblingHeadView.frame.size.height );
    
    frameNumber = 0;
    _currentMouthFrame = 0;
    _mouthLevels[199] = {0};
    
    videoSaveFileManager = [NSFileManager defaultManager];
    
    if ([APP_DELEGATE mouthType] == 2) {
        [APP_DELEGATE setBobbleBodyIndex:6];
    }else{
        [APP_DELEGATE setBobbleBodyIndex:10];
    }
}


- (IBAction)hideControllsButtonPressed:(id)sender {
    
    if (_speedSlider) {
        [self hideSpeedControls];
    }
    if (_audioRecorder) {
        [self hideRecordControls];
    }
    if (_shareVC) {
        [self hideShareControls];
    }
}



-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.backgroundImage setImage:[UIImage imageNamed:[(Background*)[[APP_DELEGATE bobbleBackgroundArray] objectAtIndex:[APP_DELEGATE bobbleBGIndex]] imageName]]];
    [self.bodyImage setImage:[UIImage imageNamed:[(Body*)[[APP_DELEGATE bobbleBodyArray] objectAtIndex:[APP_DELEGATE bobbleBodyIndex]] imageName]]];
    
    [FlurryAds setAdDelegate:self];
    [FlurryAds fetchAdForSpace:adSpaceName frame:[[self view] frame] size:FULLSCREEN];
}


-(void)viewDidAppear:(BOOL)animated{

    [self.loadingIndicator setHidden:YES];

  //  NSString *path = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    
/*    NSFileManager* fm = [[NSFileManager alloc] init];
    NSDirectoryEnumerator* en = [fm enumeratorAtPath:path];
    NSError* err = nil;
    BOOL res;
    
    NSString* file;
    while (file = [en nextObject]) {
        res = [fm removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err];
        if (!res && err) {
            NSLog(@"oops: %@", err);
        }
    }
*/
    animationTimer = [NSTimer timerWithTimeInterval:0.04 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:animationTimer forMode:NSRunLoopCommonModes];

    [self resetBobble];
    [super viewDidAppear:animated];
    
}


-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Reset delegate
    [FlurryAds setAdDelegate:nil];
}


-(void)showInterstitialAd{
    if ([FlurryAds adReadyForSpace:adSpaceName]) {
        [FlurryAds displayAdForSpace:adSpaceName onView:[self view]];
    } else {
        // Fetch an ad
        [FlurryAds fetchAdForSpace:adSpaceName frame:[[self view] frame] size:FULLSCREEN];
    }
}

- (BOOL) spaceShouldDisplay:(NSString*)adSpace interstitial:(BOOL)
interstitial {
    if (interstitial) {
        // Pause app state here
    }
    
    // Continue ad display
    return YES;
}

- (void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial {
    if (interstitial) {
        // Resume app state here
    }
}

-(void)setMouth:(int)mouthLevel{
    
    [self.headImageView setImage:[_headWithMouthImages objectAtIndex:mouthLevel]];
    [self.headImageView setTag:mouthLevel];
   // [self.mouthImageView setImage:[self mouthAtLevel:mouthLevel]];
}

- (IBAction)saveBobbleToCameraRoll:(id)sender {
    
    if (_shareVC || _speedSlider || _audioRecorder) {
        [self hideControllsButtonPressed:nil];
    }else{
        _shareVC = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:[NSBundle mainBundle]];
        [_shareVC setDelegate:self];
        
        [_shareVC.view setFrame:CGRectMake(0, self.view.frame.size.height - self.bottomNavBarView.frame.size.height+20, self.view.frame.size.width, _shareVC.view.frame.size.height)];
        
        [self.view insertSubview:_shareVC.view belowSubview:self.bottomNavBarView];
        [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            [_shareVC.view setFrame:CGRectMake(0, self.view.frame.size.height - self.bottomNavBarView.frame.size.height-_shareVC.view.frame.size.height+2, self.view.frame.size.width, _shareVC.view.frame.size.height)];
        } completion:nil];
    }

    //    [self.loadingIndicator setHidden:NO];
    //    [animationTimer invalidate];
    //    frameNumber = 0;
    //    [self performSelectorInBackground:@selector(saveBobble) withObject:nil];
}


- (IBAction)recordButtonPressed:(id)sender {
    
    if (_shareVC || _audioRecorder || _speedSlider) {
        [self hideControllsButtonPressed:nil];
    }else{
        _audioRecorder = [[AudioRecorderViewController alloc] initWithNibName:@"AudioRecorderViewController" bundle:[NSBundle mainBundle]];
        [_audioRecorder setDelegate:self];
        
        [_audioRecorder.view setFrame:CGRectMake(0, self.view.frame.size.height - self.bottomNavBarView.frame.size.height+20, self.view.frame.size.width, _audioRecorder.view.frame.size.height)];
        
        [self.view insertSubview:_audioRecorder.view belowSubview:self.bottomNavBarView];
        [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            [_audioRecorder.view setFrame:CGRectMake(0, self.view.frame.size.height - self.bottomNavBarView.frame.size.height-_audioRecorder.view.frame.size.height+2, self.view.frame.size.width, _audioRecorder.view.frame.size.height)];
        } completion:nil];
    }
}

-(void)hideRecordControls{
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        [_audioRecorder.view setFrame:CGRectMake(0, self.view.frame.size.height - self.bottomNavBarView.frame.size.height+10, self.view.frame.size.width, _audioRecorder.view.frame.size.height)];
    } completion:^(BOOL finished) {
        [_audioRecorder removeFromParentViewController];
        _audioRecorder = nil;
    }];
}

-(void)hideSpeedControls{
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        [_speedSlider.view setFrame:CGRectMake(0, self.view.frame.size.height - self.bottomNavBarView.frame.size.height, self.view.frame.size.width, _speedSlider.view.frame.size.height)];
    } completion:^(BOOL finished) {
        [_speedSlider removeFromParentViewController];
        _speedSlider = nil;
    }];
}

-(void)hideShareControls{
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        [_shareVC.view setFrame:CGRectMake(0, self.view.frame.size.height - self.bottomNavBarView.frame.size.height, self.view.frame.size.width, _shareVC.view.frame.size.height)];
    } completion:^(BOOL finished) {
        [_shareVC removeFromParentViewController];
        _shareVC = nil;
    }];
}

- (IBAction)speedButtonPressed:(id)sender {
    
    if (_shareVC || _audioRecorder || _speedSlider) {
        [self hideControllsButtonPressed:nil];
    }else{
        _speedSlider = [[SpeedModulationViewController alloc] initWithNibName:@"SpeedModulationViewController" bundle:[NSBundle mainBundle]];
        [_speedSlider.view setFrame:CGRectMake(0, self.view.frame.size.height - self.bottomNavBarView.frame.size.height+20, self.view.frame.size.width, _speedSlider.view.frame.size.height)];
        [self.view insertSubview:_speedSlider.view belowSubview:self.bottomNavBarView];
        [_speedSlider.bobbleSlider setValue:_bobbleIntensity animated:NO];
        [_speedSlider.speedSlider setValue:_bobbleSpeed animated:NO];
        
        [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            [_speedSlider.view setFrame:CGRectMake(0, self.view.frame.size.height - self.bottomNavBarView.frame.size.height-_speedSlider.view.frame.size.height, self.view.frame.size.width, _speedSlider.view.frame.size.height)];
        } completion:nil];
    }
}

-(void)animation1{

    [self.bobblingHeadView setTransform:[self createNextTransform:NO]];
    if ([_audioRecorder recordTimer]) {
        _mouthLevels[_currentMouthFrame] = self.headImageView.tag;
        _currentMouthFrame++;
    }
}

-(CGAffineTransform)createNextTransform:(BOOL)forVideo{
    
    if (_speedSlider) {
        _bobbleSpeed = _speedSlider.speedSlider.value;
        _bobbleIntensity = _speedSlider.bobbleSlider.value;
    }
    
    float rotateSpeed = .2 + (_bobbleSpeed * .2);
    float rotateLength = .4 + (_bobbleIntensity * .2);
//    float xSpeed = 4 + (_bobbleSpeed * 6);
//    float ySpeed = 5 + (_bobbleIntensity * 6);
//    float xLength = 15 + (_bobbleSpeed * 6);
//    float yLength = 9 + (_bobbleIntensity * 6);
    
    if ((currentRotation + rotateSpeed > rotateLength && rotateClockwise) || (currentRotation - rotateSpeed < -rotateLength && !rotateClockwise)){
        rotateClockwise = !rotateClockwise;
    }
    if (rotateClockwise) {
        currentRotation += rotateSpeed;
    }else{
        currentRotation -= rotateSpeed;
    }
    
    CGAffineTransform rotationTransform;
    if (forVideo) {
        rotationTransform = [self CGAffineTransformMakeRotationAtAngle:currentRotation point:CGPointMake(0, 18)];
    }else{
        rotationTransform = [self CGAffineTransformMakeRotationAtAngle:currentRotation point:CGPointMake(0, 78)];
    }
// CGAffineTransform rotationTransform = [self CGAffineTransformMakeRotationAtAngle:currentRotation point:CGPointMake(0, 20)];
    
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(currentX, currentY);
    CGAffineTransform nextTransform = CGAffineTransformConcat(rotationTransform, translationTransform);

    return nextTransform;
}

-(CGAffineTransform)CGAffineTransformMakeRotationAtAngle:(CGFloat)angle point:(CGPoint) pt{
    const CGFloat fx = pt.x;
    const CGFloat fy = pt.y;
    const CGFloat fcos = cos(angle);
    const CGFloat fsin = sin(angle);
    return CGAffineTransformMake(fcos, fsin, -fsin, fcos, fx - fx * fcos + fy * fsin, fy - fx * fsin - fy * fcos);
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveBobble{
    [self saveBobbleMovieFrame];
}

-(void)saveBobbleMovieFrame {
    
    [animationTimer invalidate];
    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSInteger randomNumber = arc4random();
    [APP_DELEGATE setOutputFileName:[NSString stringWithFormat:@"%d",randomNumber]];
    documents = [documents stringByAppendingPathComponent:[APP_DELEGATE outputFileName]];
    NSLog(@"path: %@", [APP_DELEGATE outputFileName]);

    [self writeImagesAsMovieToPath:[documents stringByAppendingString:@"_temp.mov"]];
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documents error:&error]);
    
}

-(UIImage*)addBackgroundImage:(UIImage*)headImage{
    
        UIGraphicsBeginImageContextWithOptions(self.backgroundImage.frame.size, NO, 0.0f);

        [[[self backgroundImage] image] drawInRect:self.backgroundImage.frame];
        [[[self bodyImage] image] drawInRect:self.bodyImage.frame];
        [headImage drawInRect:CGRectMake((self.backgroundImage.frame.size.width/2)-95, 135-(240/2), 190, 240)];
      //  [headImage drawInRect:self.bobblingHeadView.frame];
        
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultImage;

}

-(UIImage*)createBobbleFrame:(UIImage*)headImage layerRef:(CGLayerRef)layerRefd context:(CGContextRef)ctxs{

    UIGraphicsBeginImageContextWithOptions(self.backgroundImage.bounds.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGLayerRef layerRef= CGLayerCreateWithContext(ctx,self.backgroundImage.bounds.size,NULL);
    CGContextRef layerContext = CGLayerGetContext(layerRef);

    CGContextDrawImage(layerContext, self.backgroundImage.bounds, [[self backgroundImage] image].CGImage);

    CGRect bodyFrame = self.bodyImage.frame;
    bodyFrame.origin.y = self.backgroundImage.bounds.size.height - bodyFrame.origin.y - bodyFrame.size.height ;

    CGContextDrawImage(layerContext, bodyFrame, [[self bodyImage] image].CGImage);
    
    //rotate and draw head
    CGAffineTransform transform = [self createNextTransform:YES];
    
    CGContextTranslateCTM(layerContext, self.backgroundImage.bounds.size.width*0.5, self.backgroundImage.bounds.size.height*0.5);
    CGContextConcatCTM(layerContext, transform);
    CGContextTranslateCTM(layerContext, -self.backgroundImage.bounds.size.width*0.5, -self.backgroundImage.bounds.size.height*0.5);
    
    CGRect headFrame = self.headImageView.frame;
    headFrame.origin.y = self.backgroundImage.bounds.size.height - self.bobblingHeadView.frame.origin.y - headFrame.size.height;
    headFrame.origin.x = self.backgroundImage.bounds.size.width/2 - headFrame.size.width/2;
    CGContextDrawImage(layerContext, headFrame, headImage.CGImage);

    CGContextTranslateCTM(ctx, 0.0, self.backgroundImage.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextDrawLayerInRect(ctx,self.backgroundImage.bounds,layerRef);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


-(void)resetBobble{
    
    currentRotation = 0;
    currentX = 0;
    currentY = 0;
    
    xPositiveDirection = YES;
    yPositiveDirection = YES;
    rotateClockwise = YES;
    
    NSLog(@"alpha of head:%d", CGImageGetAlphaInfo(self.headImageView.image.CGImage));

    [self.headImageView setImage: [self applyTransform:CGAffineTransformIdentity toImage:self.headImageView.image]];
}


-(UIImage*)applyTransform:(CGAffineTransform)nextTransform fromLayerRef:(CGLayerRef)layerRef andContext:(CGContextRef)ctx{

    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    // Clear whole thing
    CGContextClearRect(ctx, rect);
    
    // Transform the image (as the image view has been transformed)
    CGContextTranslateCTM(ctx, rect.size.width*0.5, rect.size.height*0.5);
    CGContextConcatCTM(ctx, nextTransform);
    CGContextTranslateCTM(ctx, -rect.size.width*0.5, -rect.size.height*0.5);
    
    // Tanslate and scale upside-down to compensate for Quartz's inverted coordinate system
    CGContextTranslateCTM(ctx, 0.0, rect.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    // Draw view into context
    CGContextDrawLayerInRect(ctx,rect,layerRef);
    
    // Create the new UIImage from the context
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    CGAffineTransform ctm = CGAffineTransformInvert(CGContextGetCTM(ctx));
    CGContextConcatCTM(ctx, ctm);
    CGContextTranslateCTM(ctx, 0.0, rect.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);

    // End the drawing
    
    return newImage;
}


- (void) writeImagesAsMovieToPath:(NSString*)path {
    [self resetBobble];
//    for (int i = 0; i < 200; i++) {
//        NSLog(@"%d",_mouthLevels[i]);
//    }
//    NSMutableArray *layerRefs = [NSMutableArray arrayWithCapacity:3];
    
//    UIGraphicsBeginImageContext(self.view.frame.size);
    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGLayerRef layerRef= CGLayerCreateWithContext(ctx,self.backgroundImage.frame.size,NULL);
 //   CGRect rect = CGRectMake(0, 0, self.backgroundImage.frame.size.width, self.backgroundImage.frame.size.height);
    
//	CGContextRef layerContext = CGLayerGetContext(layerRef);
//	CGContextDrawImage(layerContext, rect, ((UIImage*)[_headWithMouthImages objectAtIndex:0]).CGImage);
    
    //these were in
    //UIImage *first = [self applyTransform:[self createNextTransform] fromLayerRef:layerRef andContext:ctx];
    //first = [self addBackgroundImage:first];
    
    UIImage *first = [self createBobbleFrame:[_headWithMouthImages objectAtIndex:0] layerRef:nil context:nil];
    
    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSInteger randomNumber = arc4random();
    [APP_DELEGATE setOutputFileName:[NSString stringWithFormat:@"%d",randomNumber]];
    documents = [documents stringByAppendingPathComponent:[APP_DELEGATE outputFileName]];
    
    [UIImagePNGRepresentation(first) writeToFile:[documents stringByAppendingString:@".png"] atomically:NO];
    CGSize frameSize = first.size;
    
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:path] fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    
    if(error) {
        NSLog(@"error creating AssetWriter: %@",[error description]);
    }
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:frameSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:frameSize.height], AVVideoHeightKey,
                                   nil];
    
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput
                                        assetWriterInputWithMediaType:AVMediaTypeVideo
                                        outputSettings:videoSettings];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:frameSize.width] forKey:(NSString*)kCVPixelBufferWidthKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:frameSize.height] forKey:(NSString*)kCVPixelBufferHeightKey];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                     sourcePixelBufferAttributes:attributes];
    
    [videoWriter addInput:writerInput];
    
    // fixes all errors
    writerInput.expectsMediaDataInRealTime = YES;
    
    //Start a session:
    BOOL start = [videoWriter startWriting];
    NSLog(@"Session started? %d", start);
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef pxbuffer = NULL;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(first.CGImage),
                        CGImageGetHeight(first.CGImage), kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                        &pxbuffer);
    
    
    [self pixelBufferFromCGImage:[first CGImage] buffer:pxbuffer];
    BOOL result = [adaptor appendPixelBuffer:pxbuffer withPresentationTime:kCMTimeZero];
    
    if (result == NO) //failes on 3GS, but works on iphone 4
        NSLog(@"failed to append buffer");

    int fps = 26;
    CMTime frameTime = CMTimeMake(1, fps);
    UIImage *imgFrame = nil;
    
    for (int i = 0; i < 200; i++) {
        if(i%10==0)
            NSLog(@"frame %d", i);
        
        @autoreleasepool {
            
            
//            CGContextRef layerContext = CGLayerGetContext(layerRef);
//            CGContextDrawImage(layerContext, rect, ((UIImage*)[_headWithMouthImages objectAtIndex:_mouthLevels[i]]).CGImage);
//            
//            imgFrame = [self applyTransform:[self createNextTransform] fromLayerRef:layerRef andContext:ctx];
//            
//            imgFrame = [self addBackgroundImage:imgFrame];

            
            imgFrame = [self createBobbleFrame:[_headWithMouthImages objectAtIndex:_mouthLevels[i]] layerRef:nil context:nil];
//
//            CGContextRef layerContext = CGLayerGetContext(layerRef);
//            CGContextDrawImage(layerContext, rect, ((UIImage*)[_headWithMouthImages objectAtIndex:_mouthLevels[i]]).CGImage);
//            
//            imgFrame = [self applyTransform:[self createNextTransform] fromLayerRef:layerRef andContext:ctx];
//            
//            imgFrame = [self addBackgroundImage:imgFrame];
//            [APP_DELEGATE setPercentLoaded:i/200.f];
            
            if (adaptor.assetWriterInput.readyForMoreMediaData){
                
                CMTime lastTime=CMTimeMake(i, fps);
                CMTime presentTime=CMTimeAdd(lastTime, frameTime);
                
                [self pixelBufferFromCGImage:[imgFrame CGImage] buffer:pxbuffer];
                BOOL result = [adaptor appendPixelBuffer:pxbuffer withPresentationTime:presentTime];
                
                if (result == NO){ //failes on 3GS, but works on iphone 4
                    NSLog(@"failed to append buffer");
                    NSLog(@"The error is %@", [videoWriter error]);
                }
            }else{
                NSLog(@"error");
                i--;
            }
        }
    }
    if(pxbuffer)
        CVBufferRelease(pxbuffer);
    
    //Finish the session:    
    UIGraphicsEndImageContext();

    [writerInput markAsFinished];
    [videoWriter finishWriting];
    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
    NSLog(@"Finished");
    NSMutableArray *savedBobbles = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"bobbleArray"]];
    [savedBobbles addObject:[NSString stringWithString:[APP_DELEGATE outputFileName]]];
    [[NSUserDefaults standardUserDefaults] setObject:savedBobbles forKey:@"bobbleArray"];
    [self addSoundToVideo:path];
    [_shareVC finishedCreatingVideo];
}


-(void)addSoundToVideo:(NSString*)tempPath{
    
    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0] ;
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    NSString *audio_inputFilePath = [documents stringByAppendingString:@"/audio.m4a"];
    
  //  NSString* audio_inputFilePath = [APP_DELEGATE soundFilePath];
    NSURL*    audio_inputFileUrl = [NSURL fileURLWithPath:audio_inputFilePath];
    
    NSURL*    video_inputFileUrl = [NSURL fileURLWithPath:tempPath];

    NSURL*    outputFileUrl = [NSURL fileURLWithPath:[[documents stringByAppendingPathComponent:[APP_DELEGATE outputFileName]] stringByAppendingString:@".mov"]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:[APP_DELEGATE outputFileName]])
        [[NSFileManager defaultManager] removeItemAtPath:[APP_DELEGATE outputFileName] error:nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:audio_inputFilePath]){
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (tempPath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(tempPath ,nil,nil,nil);
        }
        
        if ( [[NSFileManager defaultManager] isReadableFileAtPath:tempPath] ){
            NSError *err = nil;
            [[NSFileManager defaultManager] copyItemAtURL:video_inputFileUrl toURL:outputFileUrl error:&err];
            if (err) {
                NSLog(@"error: %@",[err userInfo]);
            }
        }
        [self sendDone];
        return;
    }

    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    //nextClipStartTime = CMTimeAdd(nextClipStartTime, a_timeRange.duration);
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    _assetExport.outputURL = outputFileUrl;
    

        [_assetExport exportAsynchronouslyWithCompletionHandler:
         ^(void ) {
             
             if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum ([[documents stringByAppendingPathComponent:[APP_DELEGATE outputFileName]] stringByAppendingString:@".mov"])) {
                 
                 UISaveVideoAtPathToSavedPhotosAlbum([[documents stringByAppendingPathComponent:[APP_DELEGATE outputFileName]] stringByAppendingString:@".mov"] ,nil,nil,nil);
             }
            // frameNumber = 0;
            // animationTimer = [NSTimer timerWithTimeInterval:0.04 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
           //  [[NSRunLoop mainRunLoop] addTimer:animationTimer forMode:NSRunLoopCommonModes];
             [self sendDone];
         }];  

}

-(void)sendDone{
    [self.loadingIndicator setHidden:YES];
    NSLog(@"DONE");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_SAVED" object:self userInfo:nil];
    [APP_DELEGATE setPercentLoaded:1.];
}

-(void)getStatus{
    switch ([_assetExport status]) {
        case AVAssetExportSessionStatusUnknown:
            NSLog(@"1");
            break;
        case    AVAssetExportSessionStatusWaiting:
            NSLog(@"2");
            break;
        case AVAssetExportSessionStatusExporting:
            NSLog(@"3");
            break;
        case    AVAssetExportSessionStatusCompleted:
            NSLog(@"4");
            break;
        case    AVAssetExportSessionStatusFailed:
            NSLog(@"5");
            break;
        case AVAssetExportSessionStatusCancelled:
            NSLog(@"6");
            break;
            
        default:
            break;
    }
    
    NSLog(@"progress: %f",[_assetExport progress]);
}


-(void)pixelBufferFromCGImage:(CGImageRef)image buffer:(CVPixelBufferRef)pxbuffer
{
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
}

/*
- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                        CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                        &pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}
*/

-(void)viewDidDisappear:(BOOL)animated{
    [animationTimer invalidate];
}

- (void)viewDidUnload
{
    [self setLoadingIndicator:nil];
    [self setBottomNavBarView:nil];
    [self setHeadImageView:nil];
    [self setBackgroundImage:nil];
    [self setBodyImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(UIImage*)applyTransform:(CGAffineTransform)nextTransform toImage:(UIImage*)image{
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //   CGLayerRef layerRef= CGLayerCreateWithContext(ctx,self.view.frame.size,NULL);
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    
    // Clear whole thing
    CGContextClearRect(ctx, rect);
    
    // Transform the image (as the image view has been transformed)
    CGContextTranslateCTM(ctx, rect.size.width*0.5, rect.size.height*0.5);
    CGContextConcatCTM(ctx, nextTransform);
    CGContextTranslateCTM(ctx, -rect.size.width*0.5, -rect.size.height*0.5);
    
    // Tanslate and scale upside-down to compensate for Quartz's inverted coordinate system
    CGContextTranslateCTM(ctx, 0.0, rect.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    // Draw view into context
    CGContextDrawImage(ctx, rect, image.CGImage);
    //    CGContextDrawLayerInRect(ctx,rect,layerRef);
    // Create the new UIImage from the context
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //    NSLog(@"alpha of new uiimage1:%d", CGImageGetAlphaInfo(newImage.CGImage));
    
    
    // End the drawing
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void)transformContext:(CGContextRef)ctx withTransform:(CGAffineTransform)transform{

 //   CGContextClearRect(ctx, rect);
    
    // Transform the image (as the image view has been transformed)
    CGContextTranslateCTM(ctx, self.backgroundImage.bounds.size.width*0.5, self.backgroundImage.bounds.size.height*0.5);
    CGContextConcatCTM(ctx, transform);
    CGContextTranslateCTM(ctx, -self.backgroundImage.bounds.size.width*0.5, -self.backgroundImage.bounds.size.height*0.5);
    
    // Tanslate and scale upside-down to compensate for Quartz's inverted coordinate system
//    CGContextTranslateCTM(ctx, 0.0, rect.size.height);
//    CGContextScaleCTM(ctx, 1.0, -1.0);
    
 //   CGAffineTransform ctm = CGAffineTransformInvert(CGContextGetCTM(ctx));
 //   CGContextConcatCTM(ctx, ctm);
 //   CGContextTranslateCTM(ctx, 0.0, rect.size.height);
 //   CGContextScaleCTM(ctx, 1.0, -1.0);
    // Draw view into context
//    CGContextDrawImage(ctx, rect, image.CGImage);
}


@end
