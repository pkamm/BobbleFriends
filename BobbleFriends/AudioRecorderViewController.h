//
//  AudioRecorderViewController.h
//  BobbleFriends
//
//  Created by Peter Kamm on 9/17/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//#import "ObjectAL.h"
#import "Novocaine.h"
#import "RingBuffer.h"
#import "AudioFileReader.h"
#import "AudioFileWriter.h"

#define MAX_FRAME_LENGTH 4096	// tz


@interface AudioRecorderViewController : UIViewController
//<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    UIButton *playButton;
    UIButton *recordButton;
    UIButton *stopButton;
    
//	ALSource* source;
//	ALBuffer* buffer;
    
    float effectPitch;
    
    Novocaine *audioManager;
    AudioFileReader *fileReader;
    AudioFileWriter *fileWriter;
    RingBuffer *ringBuffer;
    
    int _timerCounter;
    int _timerDuration;
    int mouthChangeCount;
    
}

@property (strong, nonatomic) id delegate;
@property (retain, nonatomic) IBOutlet UILabel *timerLabel;

@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;

@property (strong, nonatomic) NSTimer *recordTimer;


// fft

@property (readwrite)  Float64 graphSampleRate;


@property (assign, nonatomic) FFTSetup fftSetup;			// fft predefined structure required by vdsp fft functions
@property (assign, nonatomic) COMPLEX_SPLIT fftA;			// complex variable for fft
@property (assign, nonatomic) int fftLog2n;               // base 2 log of fft size
@property (assign, nonatomic) int fftN;                   // fft size
@property (assign, nonatomic) int fftNOver2;              // half fft size
@property (assign, nonatomic) size_t fftBufferCapacity;	// fft buffer size (in samples)
@property (assign, nonatomic) size_t fftIndex;            // read index pointer in fft buffer

// working buffers for sample data

//@property (assign, nonatomic) void *dataBuffer;               //  input buffer from mic/line
@property (assign, nonatomic) float *outputBuffer;            //  fft conversion buffer
@property (assign, nonatomic) float *analysisBuffer;          //  fft analysis buffer
@property (assign, nonatomic) SInt16 *conversionBufferLeft;   // for data conversion from fixed point to integer
@property (assign, nonatomic) SInt16 *conversionBufferRight;   // for data conversion from fixed point to integer






- (IBAction)recordAudioPressed:(id)sender;
- (IBAction)stopAudioPressed:(id)sender;
- (IBAction)playAudioPressed:(id)sender;

- (void) FFTSetup;
-(float)MagnitudeSquared:(float)x withFloat:(float)y;

-(OSStatus) fftPassThrough:(UInt32) inNumberFrames buffer:(float*) sampleBuffer;


//@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;

@end
