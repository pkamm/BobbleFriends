//
//  MainBobbleViewController.h
//  BobbleFriends
//
//  Created by Peter Kamm on 9/17/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioRecorderViewController.h"
#import "SpeedModulationViewController.h"
#import "ShareViewController.h"

@interface MainBobbleViewController : UIViewController{

    UIImage* originalImage;
    
    NSTimer *animationTimer;
    
    float currentX;
    float currentY;
    float currentRotation;
    
    float _bobbleSpeed;
    float _bobbleIntensity;
    
    BOOL xPositiveDirection;
    BOOL yPositiveDirection;
    BOOL rotateClockwise;
    
    int frameNumber;
    NSFileManager *videoSaveFileManager;
    
    NSMutableArray *imageArray;
    AudioRecorderViewController* _audioRecorder;
    SpeedModulationViewController* _speedSlider;
    ShareViewController* _shareVC;
    
    AVAssetExportSession* _assetExport;
    
    NSInteger _mouthLevels[1000];
    NSInteger _currentMouthFrame;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *bottomNavBarView;

@property (strong, nonatomic) IBOutlet UIView *bobblingHeadView;
@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *bodyImage;

@property (strong, nonatomic) NSArray *headWithMouthImages;

- (CGAffineTransform)createNextTransform:(BOOL)forVideo;
-(void)setMouth:(int)mouthLevel;
-(void)showInterstitialAd;
-(void)setMouth:(int)mouthLevel forMouthFrame:(int)mouthframe;
-(int)getMouthForIndex:(int)index;


@end
