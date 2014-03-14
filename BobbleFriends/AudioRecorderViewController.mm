//
//  AudioRecorderViewController.m
//  BobbleFriends
//
//  Created by Peter Kamm on 9/17/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

#import "AudioRecorderViewController.h"
#import "AppDelegate.h"
#import "MainBobbleViewController.h"

#import "EAFRead.h"
#import "EAFWrite.h"
#import "Utilities.h"

#include "Dirac.h"
#include <stdio.h>
#include <sys/time.h>

#define MAX_FRAME_LENGTH 4096

double gExecTimeTotal = 0.;

@interface AudioRecorderViewController ()

@end

/*
 This is the callback function that supplies data from the input stream/file whenever needed.
 It should be implemented in your software by a routine that gets data from the input/buffers.
 The read requests are *always* consecutive, ie. the routine will never have to supply data out
 of order.
 */
long myReadData(float **chdata, long numFrames, void *userData)
{
	// The userData parameter can be used to pass information about the caller (for example, "self") to
	// the callback so it can manage its audio streams.
	if (!chdata)	return 0;
	
	AudioRecorderViewController *Self = (AudioRecorderViewController*)userData;
	if (!Self)	return 0;
	
	// we want to exclude the time it takes to read in the data from disk or memory, so we stop the clock until
	// we've read in the requested amount of data
	gExecTimeTotal += DiracClockTimeSeconds(); 		// ............................. stop timer ..........................................
    
	OSStatus err = [Self.reader readFloatsConsecutive:numFrames intoArray:chdata];
	
	DiracStartClock();								// ............................. start timer ..........................................
    
	return err;
	
}

@implementation AudioRecorderViewController

@synthesize playButton, stopButton, recordButton;

- (void)viewDidLoad {
    isPlaying = NO;
    _mouthFrame = 0;
    self.mouthLevels = [[NSMutableArray alloc] init];
    
    [super viewDidLoad];

    playButton.enabled = NO;
    stopButton.enabled = NO;
    
    self.graphSampleRate = 44100.0;    // Hertz

    effectPitch = 1;
    mouthChangeCount = 0;
    
    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0] ;
    self.originalSoundFileURL = [NSURL URLWithString:[documents stringByAppendingString:@"/audio.aif"]];
    self.shiftedSoundFileURL = [NSURL URLWithString:[documents stringByAppendingString:@"/shifted.aif"]];
}

-(void)viewDidAppear:(BOOL)animated{
//    ringBuffer = new RingBuffer(32768, 2);
    audioManager = [Novocaine audioManager];
    [self FFTSetup];
    _timerDuration = -1;
    _timerCounter = 0;
}

-(void)viewDidDisappear:(BOOL)animated{
    [APP_DELEGATE setSoundPitchValue:effectPitch];
    [self createNewAudioFileWithPitch:effectPitch];
}

-(void)increaseTimer:(NSTimer*)timer{
    _timerCounter++;
    
    if (_timerDuration != -1 && _timerCounter > _timerDuration) {
        [self.stopButton setEnabled:NO];
        [self.recordButton setEnabled:YES];
        [self.playButton setEnabled:YES];
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
    else if (_timerCounter < 10) {
        self.timerLabel.text = [NSString stringWithFormat:@"0:0%d",_timerCounter];
    }else{
        self.timerLabel.text = [NSString stringWithFormat:@"0:%d",_timerCounter];
    }
}

- (IBAction)recordAudioPressed:(id)sender{
    
    [self.stopButton setEnabled:YES];
    [self.recordButton setEnabled:NO];
    [self.playButton setEnabled:NO];
    
    _timerCounter = 0;
    _timerDuration = -1;
    _recordTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(increaseTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_recordTimer forMode:NSRunLoopCommonModes];
    float interval =(1.f/FRAMES_PER_SEC);
    
    NSLog(@"interval: %f",interval);
    self.mouthTimer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(switchMouth) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.mouthTimer forMode:NSRunLoopCommonModes];
    
    NSLog(@"audio output URL: %@", self.originalSoundFileURL);
    
    NSError* err = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[self.originalSoundFileURL absoluteString] error:&err];
    
    fileWriter = [[AudioFileWriter alloc]
                  initWithAudioFileURL:self.originalSoundFileURL
                  samplingRate:audioManager.samplingRate
                  numChannels:audioManager.numInputChannels];
    
    audioManager.inputBlock = ^(float *data, UInt32 numFrames, UInt32 numChannels) {


        [fileWriter writeNewAudio:data numFrames:numFrames numChannels:numChannels];
        
        [self fftPassThrough:numFrames buffer:data];
        
        if (![[self stopButton] isEnabled]) {
            audioManager.inputBlock = nil;
            [fileWriter release];
            NSLog(@"Done recording");
            [self createNewAudioFileWithPitch:1];
            [self.mouthTimer invalidate];
        }
    };
    [audioManager play];
}



- (IBAction)stopAudioPressed:(id)sender{
    [self.stopButton setEnabled:NO];
    [self.recordButton setEnabled:YES];
    [self.playButton setEnabled:YES];
    _timerDuration = _timerCounter;
    [_recordTimer invalidate];
    _recordTimer = nil;
//    [self createNewAudioFileWithPitch:1];
}

-(void)diracPlayerDidFinishPlaying:(DiracAudioPlayerBase*)player successfully:(BOOL)flag{
    recordButton.enabled = YES;
    stopButton.enabled = NO;
    isPlaying = NO;
    [self.mouthTimer invalidate];
}

- (IBAction)playAudioPressed:(id)sender{
    
    [self.stopButton setEnabled:YES];
    [self.recordButton setEnabled:NO];
    [self.playButton setEnabled:NO];
    _timerCounter = 0;
    _mouthFrame = 0;
    _recordTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(increaseTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_recordTimer forMode:NSRunLoopCommonModes];
    float interval =(1.f/FRAMES_PER_SEC);

    self.mouthTimer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(switchMouth) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.mouthTimer forMode:NSRunLoopCommonModes];
    
	NSError *error = nil;
	mDiracAudioPlayer = [[DiracFxAudioPlayer alloc] initWithContentsOfURL:self.originalSoundFileURL channels:1 error:&error];		// LE only supports 1 channel!
	[mDiracAudioPlayer setDelegate:self];
	[mDiracAudioPlayer setNumberOfLoops:0];
    
    float pitch     = powf(2.f, (int)effectPitch / 12.f);     // pitch shift (0 semitones)
    [mDiracAudioPlayer changePitch:pitch];
    [mDiracAudioPlayer setVolume:1];
    [mDiracAudioPlayer setMVolume:1];
    UInt32 doChangeDefaultRoute = true;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    isPlaying = YES;
    [mDiracAudioPlayer play];
}


//////////////////////////////////////////////////
// Setup FFT - structures needed by vdsp functions
//
- (void) FFTSetup {

	UInt32 maxFrames = 1024;    // fft size
	
	// setup input and output buffers to equal max frame size
	
//	self.dataBuffer = (void*)malloc(maxFrames * sizeof(SInt16));
	self.outputBuffer = (float*)malloc(maxFrames *sizeof(float));
	self.analysisBuffer = (float*)malloc(maxFrames *sizeof(float));
	
	// set the init stuff for fft based on number of frames
	
	self.fftLog2n = log2f(maxFrames);		// log base2 of max number of frames, eg., 10 for 1024
	self.fftN = 1 << self.fftLog2n;					// actual max number of frames, eg., 1024 - what a silly way to compute it
    
	self.fftNOver2 = maxFrames/2;                // half fft size
	self.fftBufferCapacity = maxFrames;          // yet another way of expressing fft size
	self.fftIndex = 0;                           // index for reading frame data in callback
	
    COMPLEX_SPLIT A  = self.fftA;
    
	// split complex number buffer
	 A.realp = (float *)malloc(self.fftNOver2 * sizeof(float));		//
	 A.imagp = (float *)malloc(self.fftNOver2 * sizeof(float));		//
    
	self.fftA = A;
	
	// zero return indicates an error setting up internal buffers
	
	self.fftSetup = vDSP_create_fftsetup(self.fftLog2n, FFT_RADIX2);
    if( self.fftSetup == (FFTSetup) 0) {
        NSLog(@"Error - unable to allocate FFT setup buffers" );
	}
}



#pragma mark -
#pragma mark fft passthrough function

// Called by audio callback function with a slice of sample frames
//
// Adopted from code samples on dev forum @
// http://developer.apple.com/library/ios/#documentation/Performance/Conceptual/vDSP_Programming_Guide/SampleCode/SampleCode.html%23//apple_ref/doc/uid/TP40005147-CH205-CIAEJIGF
//
// This checks the frequency by doing a forward and inverse fft during passthrough
//-------------------------------------------------------------

-(OSStatus)fftPassThrough:(UInt32)inNumberFrames
                   buffer:(float*) sampleBuffer{

    COMPLEX_SPLIT A = self.fftA;                // complex buffers
	
//	void *dataBuffer = self.dataBuffer;         // working sample buffers
	void *dataBuffer = sampleBuffer;         // working sample buffers

//	float *outputBuffer = self.outputBuffer;
	float *analysisBuffer = self.analysisBuffer;
	
	FFTSetup fftSetup = self.fftSetup;          // fft structure to support vdsp functions
    
    // fft params
    
	uint32_t log2n = self.fftLog2n;
	uint32_t n = self.fftN;
	uint32_t nOver2 = self.fftNOver2;
	uint32_t stride = 1;
	int bufferCapacity = self.fftBufferCapacity;
	SInt16 index = self.fftIndex;

    int read = bufferCapacity - index;
	if (read > inNumberFrames) {
        
		memcpy((SInt16 *)dataBuffer + index, sampleBuffer, inNumberFrames * sizeof(SInt16));
		self.fftIndex += inNumberFrames;
	} else {

        memcpy((float *)dataBuffer + index, sampleBuffer, read * sizeof(float));
        
		
		// Reset the index.
		self.fftIndex = 0;

		vDSP_ctoz((COMPLEX*)dataBuffer, 2, &A, 1, nOver2);
        
		// Carry out a Forward FFT transform.
        vDSP_fft_zrip(fftSetup, &A, stride, log2n, FFT_FORWARD);
		
        
		// The output signal is now in a split real form. Use the vDSP_ztoc to get
		// an interleaved complex vector.
        vDSP_ztoc(&A, 1, (COMPLEX *)analysisBuffer, 2, nOver2);

        float dominantFrequency = 0;
        int bin = -1;
        for (int i=0; i<n; i+=2) {
			float curFreq = [self magnitudeSquared:analysisBuffer[i] withFloat:analysisBuffer[i+1]];
			if (curFreq > dominantFrequency) {
				dominantFrequency = curFreq;
				bin = (i+1)/2;
			}
		}
        self.lastMaxMag = dominantFrequency;
        self.lastDomFreq = bin*(self.graphSampleRate/bufferCapacity);
        
		NSLog(@"frequency: %f magnitude: %f", self.lastDomFreq, self.lastMaxMag);
	}
    
    return noErr;
}

-(void)switchMouth{
    if (isPlaying) {
        if (_mouthFrame < [self.mouthLevels count]) {
            [(MainBobbleViewController*)self.delegate setMouth:[[self.mouthLevels objectAtIndex:_mouthFrame] integerValue]];
        }
    }else{
        int index = 0;
        if (self.lastMaxMag > 60) {
            
            if(self.lastDomFreq < 200){
                index = 1;
            }else if(self.lastDomFreq < 400){
                index = 2;
            }else if(self.lastDomFreq < 500){
                index = 3;
            }else if(self.lastDomFreq < 600){
                index = 4;
            }else{
                index = 5;
            }
        }
        [(MainBobbleViewController*)self.delegate setMouth:index];
        [self.mouthLevels setObject:[NSNumber numberWithInt:index] atIndexedSubscript:_mouthFrame];
    }
    _mouthFrame++;
}


- (IBAction)sliderSlid:(id)sender {
    effectPitch = [(UISlider*)sender value];
}

-(void)createNewAudioFileWithPitch:(float)pitch{
    self.reader = [[EAFRead alloc] init];
	writer = [[EAFWrite alloc] init];
	[NSThread detachNewThreadSelector:@selector(processThread:) toTarget:self withObject:nil];
}

-(void)processThread:(id)param
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	long numChannels = 1;		// DIRAC LE allows mono only
	float sampleRate = 44100.;
    
	// open input file
	[self.reader openFileForRead:self.originalSoundFileURL sr:sampleRate channels:numChannels];
	
	// create output file (overwrite if exists)
	[writer openFileForWrite:self.shiftedSoundFileURL sr:sampleRate channels:numChannels wordLength:16 type:kAudioFileAIFFType];
	
	// DIRAC parameters
	// Here we set our time an pitch manipulation values
	float time      = 1.0;                 // 400% length
	float pitch     = powf(2.f, (int)effectPitch / 12.f);     // pitch shift (0 semitones)
	
	// First we set up DIRAC to process numChannels of audio at 44.1kHz
	// N.b.: The fastest option is kDiracLambdaPreview / kDiracQualityPreview, best is kDiracLambda3, kDiracQualityBest
	// The probably best *default* option for general purpose signals is kDiracLambda3 / kDiracQualityGood
	void *dirac = DiracCreate(kDiracLambdaTranscribe, kDiracQualityBest, numChannels, sampleRate, &myReadData, (void*)self);
	//	void *dirac = DiracCreate(kDiracLambda3, kDiracQualityBest, numChannels, sampleRate, &myReadData);
	if (!dirac) {
		printf("!! ERROR !!\n\n\tCould not create DIRAC instance\n\tCheck number of channels and sample rate!\n");
		printf("\n\tNote that the free DIRAC LE library supports only\n\tone channel per instance\n\n\n");
		exit(-1);
	}
	
	// Pass the values to our DIRAC instance
	DiracSetProperty(kDiracPropertyTimeFactor, time, dirac);
	DiracSetProperty(kDiracPropertyPitchFactor, pitch, dirac);
	
	// upshifting pitch will be slower, so in this case we'll enable constant CPU pitch shifting
	if (pitch > 1.0)
		DiracSetProperty(kDiracPropertyUseConstantCpuPitchShift, 1, dirac);
	
	// Print our settings to the console
	DiracPrintSettings(dirac);
	
	
	NSLog(@"Running DIRAC version %s\nStarting processing", DiracVersion());
	
	// Get the number of frames from the file to display our simplistic progress bar
	SInt64 numf = [self.reader fileNumFrames];
	SInt64 outframes = 0;
	SInt64 newOutframe = numf*time;
	long lastPercent = -1;
	percent = 0;
	
	// This is an arbitrary number of frames per call. Change as you see fit
	long numFrames = 8192;
	
	// Allocate buffer for output
	float **audio = AllocateAudioBuffer(numChannels, numFrames);
    
	double bavg = 0;
	
	// MAIN PROCESSING LOOP STARTS HERE
	for(;;) {
		
		// Display ASCII style "progress bar"
		percent = 100.f*(double)outframes / (double)newOutframe;
		long ipercent = percent;
		if (lastPercent != percent) {
			//[self performSelectorOnMainThread:@selector(updateBarOnMainThread:) withObject:self waitUntilDone:NO];
			printf("\rProgress: %3li%% [%-40s] ", ipercent, &"||||||||||||||||||||||||||||||||||||||||"[40 - ((ipercent>100)?40:(2*ipercent/5))] );
			lastPercent = ipercent;
			fflush(stdout);
		}
		
		DiracStartClock();								// ............................. start timer ..........................................
		
		// Call the DIRAC process function with current time and pitch settings
		// Returns: the number of frames in audio
		long ret = DiracProcess(audio, numFrames, dirac);
		bavg += (numFrames/sampleRate);
		gExecTimeTotal += DiracClockTimeSeconds();		// ............................. stop timer ..........................................
		
		printf("x realtime = %3.3f : 1 (DSP only), CPU load (peak, DSP+disk): %3.2f%%\n", bavg/gExecTimeTotal, DiracPeakCpuUsagePercent(dirac));
		
		// Process only as many frames as needed
		long framesToWrite = numFrames;
		unsigned long nextWrite = outframes + numFrames;
		if (nextWrite > newOutframe) framesToWrite = numFrames - nextWrite + newOutframe;
		if (framesToWrite < 0) framesToWrite = 0;
		
		// Write the data to the output file
		[writer writeFloats:framesToWrite fromArray:audio];
		
		// Increase our counter for the progress bar
		outframes += numFrames;
		
		// As soon as we've written enough frames we exit the main loop
		if (ret <= 0) break;
	}
	
	percent = 100;
	//[self performSelectorOnMainThread:@selector(updateBarOnMainThread:) withObject:self waitUntilDone:NO];
    
	
	// Free buffer for output
	DeallocateAudioBuffer(audio, numChannels);
	
	// destroy DIRAC instance
	DiracDestroy( dirac );
	
	// Done!
	NSLog(@"\nDone!");
	
	[self.reader release];
	[writer release]; // important - flushes data to file
	
	// start playback on main thread
    //	[self performSelectorOnMainThread:@selector(playOnMainThread:) withObject:self waitUntilDone:NO];
	
	[pool release];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    recordButton.enabled = YES;
    stopButton.enabled = NO;
    isPlaying = NO;
    [self.mouthTimer invalidate];
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                error:(NSError *)error
{
    NSLog(@"Decode Error occurred");
}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                          successfully:(BOOL)flag
{
}
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                  error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}


// for some calculation in the fft callback
// check to see if there is a vDsp library version
-(float)magnitudeSquared:(float)x withFloat:(float)y {
	return ((x*x) + (y*y));
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setTimerLabel:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
