
//
//  BobbleFontLabel.m
//  BobbleFriends
//
//  Created by Peter Kamm on 11/30/12.
//  Copyright (c) 2012 Peter Kamm. All rights reserved.
//

#import "BobbleFontLabel.h"
#import "AppDelegate.h"

@implementation BobbleFontLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.font = [UIFont fontWithName:[[APP_DELEGATE bobbleFontDict] valueForKey:[NSString stringWithFormat:@"%d", self.tag]] size:self.font.pointSize];
        
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    if (self) {
        self.font = [UIFont fontWithName:[[APP_DELEGATE bobbleFontDict] valueForKey:[NSString stringWithFormat:@"%d", self.tag]] size:self.font.pointSize];
        
    }
    
    return self;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
