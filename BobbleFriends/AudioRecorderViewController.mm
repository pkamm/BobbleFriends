//
//  AudioRecorderViewController.m
//  BobbleFriends
//
//  Created by Peter Kamm on 9/17/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

#import "AudioRecorderViewController.h"
//#import "ObjectAL.h"
//#import "ALCaptureDevice.h"
#import "AppDelegate.h"
#import "MainBobbleViewController.h"
#import "pitchShift.h"


#define MAX_FRAME_LENGTH 4096	// tz


@interface AudioRecorderViewController ()

@end

@implementation AudioRecorderViewController

@synthesize playButton, stopButton, recordButton;

- (void)viewDidLoad {
    
    [super viewDidLoad];

    playButton.enabled = NO;
    stopButton.enabled = NO;
    
    self.graphSampleRate = 44100.0;    // Hertz

    effectPitch = 1;
    mouthChangeCount = 0;
}


-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"shouldbethere");
    ringBuffer = new RingBuffer(32768, 2);
    audioManager = [Novocaine audioManager];
    [self FFTSetup];
    _timerDuration = -1;
    _timerCounter = 0;

}

-(void)viewDidDisappear:(BOOL)animated{
    [APP_DELEGATE setSoundPitchValue:effectPitch];
}

/*
- (IBAction)recordAudioPressed:(id)sender {
    
    effectPitch = 1.;
//    [[self pitchSlider] setValue:effectPitch animated:YES];
    
    if (!audioRecorder.recording)
    {
        
        NSError *setCategoryError = nil;
        
        NSError *setCategoryErr = nil;
        NSError *activationErr  = nil;
        //Set the general audio session category
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: &setCategoryErr];
        
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        
        AudioSessionSetProperty (
                                 kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),
                                 &audioRouteOverride                      
                                 );
        
        //Make the default sound route for the session be to use the speaker
        UInt32 doChangeDefaultRoute = 1;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
        
        //Activate the customized audio session
        [[AVAudioSession sharedInstance] setActive: YES error: &activationErr];
        
        if (setCategoryError) { NSLog(@"%@, %@",[setCategoryError localizedDescription], [setCategoryError userInfo]); }
        
        NSURL *soundFileURL = [NSURL fileURLWithPath:[APP_DELEGATE soundFilePath]];
        
        NSDictionary *recordSettings = [NSDictionary
                                        dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:AVAudioQualityMax],
                                        AVEncoderAudioQualityKey,
                                        [NSNumber numberWithInt:16],
                                        AVEncoderBitRateKey,
                                        [NSNumber numberWithInt: 2],
                                        AVNumberOfChannelsKey,
                                        [NSNumber numberWithFloat:44100.0],
                                        AVSampleRateKey,
                                        nil];
        
        NSError *error = nil;
        
        audioRecorder = [[AVAudioRecorder alloc]
                         initWithURL:soundFileURL
                         settings:recordSettings
                         error:&error];
        
        if (error)
        {
            NSLog(@"error: %@", [error localizedDescription]);
            
        } else {
            [audioRecorder prepareToRecord];
        }
        
        playButton.enabled = NO;
        stopButton.enabled = YES;
        [audioRecorder record];
    }
}
*/

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
    
    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0] ;
    NSURL *outputFileURL = [NSURL URLWithString:[documents stringByAppendingString:@"/audio.m4a"]];

   // NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    NSLog(@"audio output URL: %@", outputFileURL);
    
    NSError* err = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[outputFileURL absoluteString] error:&err];
    
    fileWriter = [[AudioFileWriter alloc]
                  initWithAudioFileURL:outputFileURL
                  samplingRate:audioManager.samplingRate
                  numChannels:audioManager.numInputChannels];
    
    audioManager.inputBlock = ^(float *data, UInt32 numFrames, UInt32 numChannels) {

        //[self fftPassThrough:numFrames buffer:data];
//        [self fftPitchShift:numFrames buffer:data];

        [self fftPitchShift:numFrames buffer:data];
        [fileWriter writeNewAudio:data numFrames:numFrames numChannels:numChannels];

        if (![[self stopButton] isEnabled]) {
            audioManager.inputBlock = nil;
            [fileWriter release];
            NSLog(@"Done recording");
        }
    };
}

- (IBAction)stopAudioPressed:(id)sender{
    [self.stopButton setEnabled:NO];
    [self.recordButton setEnabled:YES];
    [self.playButton setEnabled:YES];
    _timerDuration = _timerCounter;
    [_recordTimer invalidate];
    _recordTimer = nil;
}

- (IBAction)playAudioPressed:(id)sender{
    
    [self.stopButton setEnabled:YES];
    [self.recordButton setEnabled:NO];
    [self.playButton setEnabled:NO];
    _timerCounter = 0;
    _recordTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(increaseTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_recordTimer forMode:NSRunLoopCommonModes];

    // Point to Document directory
    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0] ;
    // Write out the contents of home directory to console
        NSError *error;

        NSLog(@"Documents directory: %@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documents error:&error]);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
//   NSURL *inputFileURL = [[NSBundle mainBundle] URLForResource:@"TLC" withExtension:@"mp3"];
//  NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0] ;
    NSURL *inputFileURL = [NSURL URLWithString:[documents stringByAppendingString:@"/audio.m4a"]];
    NSLog(@"audio input URL: %@", inputFileURL);
    
    
   fileReader = [[AudioFileReader alloc]
                  initWithAudioFileURL:inputFileURL
                  samplingRate:audioManager.samplingRate
                  numChannels:audioManager.numOutputChannels];
    
    [fileReader play];
    fileReader.currentTime = 0.0;
    [audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){

        [self fftPassThrough:numFrames buffer:data];
        [fileReader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
//      [self fftPitchShift:numFrames buffer:data];
//      [self fftPitchShift:numFrames buffer:data];

        
        if (![[self stopButton] isEnabled]) {
            
//            [fileReader stop];
            audioManager.outputBlock = nil;
            [fileReader release];
            NSLog(@"Done playing audio");
        }
     }];
}


//////////////////////////////////////////////////
// Setup FFT - structures needed by vdsp functions
//
- (void) FFTSetup {
	
	// I'm going to just convert everything to 1024
	
	// on the simulator the callback gets 512 frames even if you set the buffer to 1024, so this is a temp workaround in our efforts
	// to make the fft buffer = the callback buffer,
	
	// for smb it doesn't matter if frame size is bigger than callback buffer
	
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

// called by audio callback function with a slice of sample frames
//
// note this is nearly identical to the code example in apple developer lib at
// http://developer.apple.com/library/ios/#documentation/Performance/Conceptual/vDSP_Programming_Guide/SampleCode/SampleCode.html%23//apple_ref/doc/uid/TP40005147-CH205-CIAEJIGF
//
// this code does a passthrough from mic input to mixer bus using forward and inverse fft
// it also analyzes frequency with the freq domain data
//-------------------------------------------------------------

-(OSStatus)fftPassThrough:(UInt32)inNumberFrames
                   buffer:(float*) sampleBuffer{
	
    // note: the fx control slider does nothing during fft passthrough
    
    // set all the params
    
    // scope reference that allows access to everything in MixerHostAudio class
    
    
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

	// this next logic assumes that the bufferCapacity determined by maxFrames in the fft-setup is less than or equal to
	// the inNumberFrames (which should be determined by the av session IO buffer size (ie duration)
	//
	// If we can guarantee the fft buffer size is equal to the inNumberFrames, then this buffer filling step is unecessary
	//
	// at this point i think its essential to make the two buffers equal size in order to do the fft passthrough without doing
	// the overlapping buffer thing
	//
	
    
	// Fill the buffer with our sampled data. If we fill our buffer, run the
	// fft.
	
	// so I have a question - the fft buffer  needs to be an even multiple of the frame (packet size?) or what?
    int read = bufferCapacity - index;
	if (read > inNumberFrames) {
        
		memcpy((SInt16 *)dataBuffer + index, sampleBuffer, inNumberFrames * sizeof(SInt16));
		self.fftIndex += inNumberFrames;
	} else {
		// NSLog(@"processing");
		// If we enter this conditional, our buffer will be filled and we should
		// perform the FFT.
        
	//	memcpy((SInt16 *)dataBuffer + index, sampleBuffer, read * sizeof(SInt16));
        memcpy((float *)dataBuffer + index, sampleBuffer, read * sizeof(float));
        
		
		// Reset the index.
		self.fftIndex = 0;
        
        
        // *************** FFT ***************
        // convert Sint16 to floating point
        
        //petevDSP_vflt16((SInt16 *) dataBuffer, stride, (float *) outputBuffer, stride, bufferCapacity );
        
        
		//
		// Look at the real signal as an interleaved complex vector by casting it.
		// Then call the transformation function vDSP_ctoz to get a split complex
		// vector, which for a real signal, divides into an even-odd configuration.
		//
        
        //pete vDSP_ctoz((COMPLEX*)outputBuffer, 2, &A, 1, nOver2);
		vDSP_ctoz((COMPLEX*)dataBuffer, 2, &A, 1, nOver2);
        
		// Carry out a Forward FFT transform.
        vDSP_fft_zrip(fftSetup, &A, stride, log2n, FFT_FORWARD);
		
        
		// The output signal is now in a split real form. Use the vDSP_ztoc to get
		// an interleaved complex vector.
        vDSP_ztoc(&A, 1, (COMPLEX *)analysisBuffer, 2, nOver2);
		
		// for display purposes...
        //
        // Determine the dominant frequency by taking the magnitude squared and
		// saving the bin which it resides in. This isn't precise and doesn't
        // necessary get the "fundamental" frequency, but its quick and sort of works...
        
        // note there are vdsp functions to do the amplitude calcs
        float dominantFrequency = 0;
        int bin = -1;
        for (int i=0; i<n; i+=2) {
			float curFreq = [self MagnitudeSquared:analysisBuffer[i] withFloat:analysisBuffer[i+1]];
			if (curFreq > dominantFrequency) {
				dominantFrequency = curFreq;
				bin = (i+1)/2;
			}
		}
        float maxMagnitude = dominantFrequency;

        dominantFrequency = bin*(self.graphSampleRate/bufferCapacity);
        
        // printf("Dominant frequency: %f   \n" , dominantFrequency);
    //    THIS.displayInputFrequency = (int) dominantFrequency;   // set instance variable with detected frequency
		NSLog(@"frequency: %f magnitude: %f", dominantFrequency, maxMagnitude);
        
       // [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if (mouthChangeCount >=10) {

        dispatch_async(dispatch_get_main_queue(), ^{   
            if (maxMagnitude < 50) {
                [(MainBobbleViewController*)self.delegate setMouth:0];
            }else if(maxMagnitude < 600){
                [(MainBobbleViewController*)self.delegate setMouth:1];

            }else{
                [(MainBobbleViewController*)self.delegate setMouth:2];
            }
        });
            mouthChangeCount = 0;
        }else{
            mouthChangeCount++;
        }
      //  }];
        
        
        // Carry out an inverse FFT transform.
		
        vDSP_fft_zrip(fftSetup, &A, stride, log2n, FFT_INVERSE );
        
        // scale it
		
		float scale = (float) 1.0 / (2 * n);
		vDSP_vsmul(A.realp, 1, &scale, A.realp, 1, nOver2 );
		vDSP_vsmul(A.imagp, 1, &scale, A.imagp, 1, nOver2 );
		
		
        // convert from split complex to interleaved complex form
		
		//pete vDSP_ztoc(&A, 1, (COMPLEX *) outputBuffer, 2, nOver2);
		vDSP_ztoc(&A, 1, (COMPLEX *) dataBuffer, 2, nOver2);
        
        // now convert from float to Sint16
		
		//pete vDSP_vfixr16((float *) outputBuffer, stride, (SInt16 *) sampleBuffer, stride, bufferCapacity );
	}
    
    return noErr;
}


////////////////////////////////////////////////////////////////////////
//
// pitch shifter using stft - based on dsp dimension articles and source
// http://www.dspdimension.com/admin/pitch-shifting-using-the-ft/

-(OSStatus) fftPitchShift:(UInt32) inNumberFrames buffer:(float*)sampleBuffer {      // frames (sample data)
    

	FFTSetup fftSetup = self.fftSetup;      // fft setup structures need to support vdsp functions
	
    
//	uint32_t stride = 1;                    // interleaving factor for vdsp functions
//	int bufferCapacity = self.fftBufferCapacity;    // maximum size of fft buffers
    
   // float pitchShift = .3;                 // pitch shift factor 1=normal, range is .5->2.0
    long osamp = 2;//4                         // oversampling factor
    long fftSize = 1024;                    // fft size
	float frequency;                        // analysis frequency result
    
    
    //	ConvertInt16ToFloat
    
//pete    vDSP_vflt16((SInt16 *) sampleBuffer, stride, (float *) analysisBuffer, stride, bufferCapacity );
    
    // run the pitch shift
    
    // scale the fx control 0->1 to range of pitchShift .5->2.0
    
    //pete pitchShift = (self.micFxControl * 1.5) + .5;
    
    // osamp should be at least 4, but at this time my ipod touch gets very unhappy with
    // anything greater than 2
    
    
 /*   smb2PitchShift( pitchShift , (long) inNumberFrames,
                   fftSize,  osamp, (float) self.graphSampleRate,
                   (float *) analysisBuffer , (float *) outputBuffer,
                   fftSetup, &frequency);
    */
//pete    [self smb2PitchShift:pitchShift numSampsToProcess:(long)inNumberFrames fftFrameSize:fftSize osamp:osamp sampleRate:(float)self.graphSampleRate indata:(float *) analysisBuffer outdata:(float *) outputBuffer fftSetup:fftSetup frequency:&frequency];
  
        [self smb2PitchShift:effectPitch numSampsToProcess:(long)inNumberFrames fftFrameSize:fftSize osamp:osamp sampleRate:(float)self.graphSampleRate indata:(float *) sampleBuffer outdata:(float *) sampleBuffer fftSetup:fftSetup frequency:&frequency];
    
    // display detected pitch
    
    NSLog(@"freq: %f", frequency);
   // self.displayInputFrequency = (int) frequency;
    // very very cool effect but lets skip it temporarily
 //       THIS.sinFreq = THIS.frequency;   // set synth frequency to the pitch detected by microphone

    // now convert from float to Sint16
    
//    vDSP_vfixr16((float *) outputBuffer, stride, (SInt16 *) sampleBuffer, stride, bufferCapacity );
 //pete   vDSP_vfixr16((float *) sampleBuffer, stride, (SInt16 *) sampleBuffer, stride, bufferCapacity );

    return noErr;
    
}


-(void) smb2PitchShift:(float)pitchShift
     numSampsToProcess:(long)numSampsToProcess
          fftFrameSize:(long)fftFrameSize
                 osamp:(long)osamp
            sampleRate:(float)sampleRate
                indata:(float *)indata
               outdata:(float *)outdata
              fftSetup:(FFTSetup)fftSetup
             frequency:(float *)frequency
/*
 Routine smbPitchShift(). See top of file for explanation
 Purpose: doing pitch shifting while maintaining duration using the Short
 Time Fourier Transform.
 Author: (c)1999-2009 Stephan M. Bernsee <smb [AT] dspdimension [DOT] com>
 */
{

	static float gInFIFO[MAX_FRAME_LENGTH];
	static float gOutFIFO[MAX_FRAME_LENGTH];
	static float gFFTworksp[2*MAX_FRAME_LENGTH];
	static float gLastPhase[MAX_FRAME_LENGTH/2+1];
	static float gSumPhase[MAX_FRAME_LENGTH/2+1];
	static float gOutputAccum[2*MAX_FRAME_LENGTH];
	static float gAnaFreq[MAX_FRAME_LENGTH];
	static float gAnaMagn[MAX_FRAME_LENGTH];
	static float gSynFreq[MAX_FRAME_LENGTH];
	static float gSynMagn[MAX_FRAME_LENGTH];
	
	static COMPLEX_SPLIT A;
	
	static long gRover = FALSE, gInit = FALSE;
	double magn, phase, tmp, window, real, imag;
	double freqPerBin;
	double expct;		// expected phase difference tz
	long i,k, qpd, index, inFifoLatency, stepSize, fftFrameSize2;
	
	int stride;
	size_t bufferCapacity;	// In samples
	int log2n, n, nOver2;		// params for fft setup
    
	
	float maxMag;	// tz maximum magnitude for pitch detection display
	float displayFreq;	// true pitch from last window analysis
	int pitchCount = 0;	// number of times pitch gets measured
	float freqTotal = 0; // sum of all pitch measurements
	
	/* set up some handy variables */
	fftFrameSize2 = fftFrameSize/2;
	stepSize = fftFrameSize/osamp;
	freqPerBin = sampleRate/(double)fftFrameSize;
	expct = 2.*M_PI*(double)stepSize/(double)fftFrameSize;
	inFifoLatency = fftFrameSize-stepSize;
	if (gRover == FALSE) gRover = inFifoLatency;
	
	stride = 1;
	log2n = log2f(fftFrameSize);		// log base2 of max number of frames, eg., 10 for 1024
	n = 1 << log2n;					// actual max number of frames, eg., 1024 - what a silly way to compute it
	
	nOver2 = fftFrameSize/2;
	bufferCapacity = fftFrameSize;
    //	index = 0;
    
	/* initialize our static arrays */
	if (gInit == FALSE) {
		NSLog(@"init static arrays");
		//printFFTInitSnapshot(fftFrameSize2,stepSize, freqPerBin, expct, inFifoLatency, gRover);

		memset(gInFIFO, 0, MAX_FRAME_LENGTH*sizeof(float));
		memset(gOutFIFO, 0, MAX_FRAME_LENGTH*sizeof(float));
		memset(gFFTworksp, 0, 2*MAX_FRAME_LENGTH*sizeof(float));
		memset(gLastPhase, 0, (MAX_FRAME_LENGTH/2+1)*sizeof(float));
		memset(gSumPhase, 0, (MAX_FRAME_LENGTH/2+1)*sizeof(float));
		memset(gOutputAccum, 0, 2*MAX_FRAME_LENGTH*sizeof(float));
		memset(gAnaFreq, 0, MAX_FRAME_LENGTH*sizeof(float));
		memset(gAnaMagn, 0, MAX_FRAME_LENGTH*sizeof(float));
		
		// split complex number buffer
		A.realp = (float *)malloc(nOver2 * sizeof(float));		//
		A.imagp = (float *)malloc(nOver2 * sizeof(float));		// why is it set to half the frame size

		gInit = true;
	}
	
    //	NSLog(@"before load");
	/* main processing loop */
	for (i = 0; i < numSampsToProcess; i++){
		
		// loading
		
		// load the next section of data, one stepsize chunk at a time, starting at beginning of indata. the chunk gets loaded
		// to a slot at the end of the gInFIFO, while at the same time, the chunk at the beginning of gOutFIFO gets loaded to into
		// the outdata buffer one chunk at a time starting at the beginning.
		//
		// the very first time this pitchshifter is called, the gOutFIFO will be initialized with zero's so it looks like
		// there will be some latency before the actual 'processed' samples begin to fill outdata.
		//
		
		/* As long as we have not yet collected enough data, just read in */
		gInFIFO[gRover] = indata[i];
		outdata[i] = gOutFIFO[gRover-inFifoLatency];
		gRover++;
		
		/* now we have enough data for processing */
		if (gRover >= fftFrameSize) {
			gRover = inFifoLatency;			// gRover cycles up between (fftFrameSize - stepsize) and fftFrameSize
			// eg., 896 - 1024 for an osamp of 8 and framesize of 1024
			
			/* do windowing and re,im interleave */
			// note that the first time this runs, the inFIFO will be mostly zeroes, but essentially, the fft runs on
			// data that keeps getting slid to the left?
			
			// the window is like a triangular hat that gets imposed over the sample buffer before its input to the fft
			// the size of the hat is the fftsize and it scales off the data at beginning and end of the buffer
			
			// i think that the vDSP_ctoz function will accomplish the interleaving and complex formatting stuff below
			// we would still need to do the windowing, but maybe there's an apple function for that too
			
            //			for (k = 0; k < fftFrameSize;k++) {
            //				window = -.5*cos(2.*M_PI*(double)k/(double)fftFrameSize)+.5;
            //				gFFTworksp[2*k] = gInFIFO[k] * window;				// real part is winowed amplitude of samples
            //				gFFTworksp[2*k+1] = 0.;								// imag part is set to 0
            //				//	NSLog(@"i: %d, k: %d, window: %f", i, k, window );
            //			}
            
			
			for (k = 0; k < fftFrameSize;k++) {
				window = -.5*cos(2.*M_PI*(double)k/(double)fftFrameSize)+.5;
				gFFTworksp[k] = gInFIFO[k] * window;				// real part is winowed amplitude of samples
                //				gFFTworksp[2*k+1] = 0.;								// imag part is set to 0
				//	NSLog(@"i: %d, k: %d, window: %f", i, k, window );
			}
			
			// cast to complex interleaved then convert to split complex vector
			
			vDSP_ctoz((COMPLEX*)gFFTworksp, 2, &A, 1, nOver2);
			
			// Carry out a Forward FFT transform.
            //			NSLog(@"before transform");
			
			vDSP_fft_zrip(fftSetup, &A, stride, log2n, FFT_FORWARD);
			
            //			NSLog(@"after transform");
            // convert from split complex to complex interleaved for analysis
			
			vDSP_ztoc(&A, 1, (COMPLEX *)gFFTworksp, 2, nOver2);
			
			/* ***************** ANALYSIS ******************* */
			/* do transform */
			// lets try replacing this with accelerate functions
			
            //	smbFft(gFFTworksp, fftFrameSize, -1);
			
			/* this is the analysis step */
			// this is looping through the fft output bins in the frequency domain
			
			for (k = 0; k <= fftFrameSize2; k++) {
				
				/* de-interlace FFT buffer */
				real = gFFTworksp[2*k];
				imag = gFFTworksp[2*k+1];
				
				/* compute magnitude and phase */
				magn = 2.*sqrt(real*real + imag*imag);
				phase = atan2(imag,real);
				
				/* compute phase difference */
				// the gLastPhase[k] would be the phase from the kth frequency bin from the previous transform over this endlessly
				// shifting data
				
				tmp = phase - gLastPhase[k];
				gLastPhase[k] = phase;
				
				/* subtract expected phase difference */
				tmp -= (double)k*expct;
				
				/* map delta phase into +/- Pi interval */
				qpd = tmp/M_PI;
				if (qpd >= 0) qpd += qpd&1;
				else qpd -= qpd&1;
				
				tmp -= M_PI*(double)qpd;
				
				/* get deviation from bin frequency from the +/- Pi interval */
				tmp = osamp*tmp/(2.*M_PI);
				
				/* compute the k-th partials' true frequency */
				tmp = (double)k*freqPerBin + tmp*freqPerBin;
				
				/* store magnitude and true frequency in analysis arrays */
				gAnaMagn[k] = magn;
				gAnaFreq[k] = tmp;
			}
			
            
            // pitch detection ------------------
            
            // find max magnitude for this pass
         
            maxMag = 0.0;
            displayFreq = 0.0;
            for (k = 0; k <= fftFrameSize2; k++) {
                if (gAnaMagn[k] > maxMag) {
                    maxMag = gAnaMagn[k];
                    displayFreq = gAnaFreq[k];
				}
            }
            
			freqTotal += displayFreq;
			pitchCount++;
            
            
			
			/* ***************** PROCESSING ******************* */
			/* this does the actual pitch shifting */
			memset(gSynMagn, 0, fftFrameSize*sizeof(float));	// why do we zero out the buffer to frame size but
			memset(gSynFreq, 0, fftFrameSize*sizeof(float));	// only actually seem to use half of frame size?
			
			// so this code assigns the results of the analysis.
			
			// it sets up pitch shifted bins using analyzed magnitude and analyzed freq * pitchShift
			
			for (k = 0; k <= fftFrameSize2; k++) {
				index = (long) (k * pitchShift);
				//			NSLog(@"i: %d, index: %d, k: %d, pitchShift: %f", i, index, k, pitchShift );
				if (index <= fftFrameSize2) {
					gSynMagn[index] += gAnaMagn[k];
					gSynFreq[index] = gAnaFreq[k] * pitchShift;
				}
			}
			
			/* ***************** SYNTHESIS ******************* */
			/* this is the synthesis step */
			for (k = 0; k <= fftFrameSize2; k++) {
				
				/* get magnitude and true frequency from synthesis arrays */
				magn = gSynMagn[k];
				tmp = gSynFreq[k];
				
				/* subtract bin mid frequency */
				tmp -= (double)k*freqPerBin;
				
				/* get bin deviation from freq deviation */
				tmp /= freqPerBin;
				
				/* take osamp into account */
				tmp = 2.*M_PI*tmp/osamp;
				
				/* add the overlap phase advance back in */
				tmp += (double)k*expct;
				
				/* accumulate delta phase to get bin phase */
				gSumPhase[k] += tmp;
				phase = gSumPhase[k];
				
				/* get real and imag part and re-interleave */
				gFFTworksp[2*k] = magn*cos(phase);
				gFFTworksp[2*k+1] = magn*sin(phase);
				
			}
			
			/* zero negative frequencies */
			for (k = fftFrameSize+2; k < 2*fftFrameSize; k++) gFFTworksp[k] = 0.;
            
            // convert from complex interleaved to split complex vector
            
			vDSP_ctoz((COMPLEX*)gFFTworksp, 2, &A, 1, nOver2);
			
			// Carry out an inverse FFT transform.
			
			vDSP_fft_zrip(fftSetup, &A, stride, log2n, FFT_INVERSE );
			
			// scale it
            
            //		the suggested scale factor makes the sound barely audible
            //		so we should probably experiment with various things
            //		I have a hunch that the stfft needs a different kind of scaling
			
            //		float scale = (float) 1.0 / (2 * n);
            //		float scale = (float) 1.0 / (osamp);
			float scale = .25;
			vDSP_vsmul(A.realp, 1, &scale, A.realp, 1, nOver2 );
			vDSP_vsmul(A.imagp, 1, &scale, A.imagp, 1, nOver2 );
			
			
			// covert from split complex to complex interleaved
			
			vDSP_ztoc(&A, 1, (COMPLEX *) gFFTworksp, 2, nOver2);
			
			/* do inverse transform */
            //			smbFft(gFFTworksp, fftFrameSize, 1);
			
			/* do windowing and add to output accumulator */
			
            /*
             for(k=0; k < fftFrameSize; k++) {
             window = -.5*cos(2.*M_PI*(double)k/(double)fftFrameSize)+.5;
             gOutputAccum[k] += 2.*window*gFFTworksp[2*k]/(fftFrameSize2*osamp);
             }
             
             */
			/* do windowing and add to output accumulator */
			for(k=0; k < fftFrameSize; k++) {
				window = -.5*cos(2.*M_PI*(double)k/(double)fftFrameSize)+.5;
				gOutputAccum[k] += 2.*window*gFFTworksp[k]/(fftFrameSize2*osamp);
			}
			
			for (k = 0; k < stepSize; k++) gOutFIFO[k] = gOutputAccum[k];
			
			// why use two different methods to copy memory?
			
			/* shift accumulator */
			// this shifts in zeroes from beyond the bounds of framesize to fill the upper step size chunk
			
			memmove(gOutputAccum, gOutputAccum+stepSize, fftFrameSize*sizeof(float));
			
			/* move input FIFO */
			for (k = 0; k < inFifoLatency; k++) gInFIFO[k] = gInFIFO[k+stepSize];
		}
	}
	
	
	// NSLog(@"pitchCount: %d", pitchCount);
	*frequency = (float) (freqTotal / pitchCount);
   /*
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if (maxMag < 6) {
            [(MainBobbleViewController*)self.delegate setMouth:0];
        }else if(maxMag < 600){
            [(MainBobbleViewController*)self.delegate setMouth:1];
            
        }else{
            [(MainBobbleViewController*)self.delegate setMouth:2];
        }
            }];
    */
    
  //  if (mouthChangeCount >=5) {
    
    NSLog(@"Max Freq: %f",maxMag);
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if (maxMag < 100) {
                [(MainBobbleViewController*)self.delegate setMouth:0];
            }else if(maxMag >= 100 && maxMag < 200){
                [(MainBobbleViewController*)self.delegate setMouth:1];
            }else if(maxMag >= 200 && maxMag < 300){
                [(MainBobbleViewController*)self.delegate setMouth:2];
            }else if(maxMag >= 300 && maxMag < 400){
                [(MainBobbleViewController*)self.delegate setMouth:3];
            }else if(maxMag >= 400 && maxMag < 500){
                [(MainBobbleViewController*)self.delegate setMouth:4];
            }else{
                [(MainBobbleViewController*)self.delegate setMouth:5];
            }
        });
//        mouthChangeCount = 0;
//    }else{
//        mouthChangeCount++;
//    }
//    
    
    
    /*if (maxMagnitude > 1.2) {
    if (dominantFrequency < 400) {
    [(MainBobbleViewController*)self.delegate setMouth:0];
    }
    else if (dominantFrequency < 1200){
    [(MainBobbleViewController*)self.delegate setMouth:1];
    }else{
    [(MainBobbleViewController*)self.delegate setMouth:2];
    }
    }
    else{
    [(MainBobbleViewController*)self.delegate setMouth:0];
    }
    */

    
	//			NSLog(@"pitch is: %f", *frequency );
    
}


- (IBAction)sliderSlid:(id)sender {
    effectPitch = [(UISlider*)sender value];
}

void Compare(float *original, float *computed, long length)

{
    
    int             i;
    
    float           error = original[0] - computed[0];
    
    float           max = error;
    
    float           min = error;
    
    float           mean = 0.0;
    
    float           sd_radicand = 0.0;
    
    
    
    for (i = 0; i < length; i++) {
        
        error = original[i] - computed[i];
        
        /* printf("%f %f %f\n", original[i], computed[i], error); */
        
        max = (max < error) ? error : max;
        
        min = (min > error) ? error : min;
        
        mean += (error / length);
        
        sd_radicand += ((error * error) / (float) length);
        
    }
    
    
    
    NSLog(@"Max error: %f  Min error: %f  Mean: %f  Std Dev: %f\n",
           
           max, min, mean, sqrt(sd_radicand));
    
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    recordButton.enabled = YES;
    stopButton.enabled = NO;
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
-(float)MagnitudeSquared:(float)x withFloat:(float)y {
	return ((x*x) + (y*y));
}

//-(void)beginAppearanceTransition:(BOOL)isAppearing animated:(BOOL)animated

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
  //  [self setPitchSlider:nil];
    [self setTimerLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
