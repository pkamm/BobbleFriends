//
//  pitchShift.h
//  BobbleFriends
//
//  Created by Peter Kamm on 2/18/13.
//  Copyright (c) 2013 Peter Kamm. All rights reserved.
//

#ifndef BobbleFriends_pitchShift_h
#define BobbleFriends_pitchShift_h


class pitchShift {
    
public:
    void smbPitchShift(float pitchShift, long numSampsToProcess, long fftFrameSize, long osamp, float sampleRate, float *indata, float *outdata);
protected:

};

#endif
