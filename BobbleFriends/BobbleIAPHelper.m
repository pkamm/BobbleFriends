//
//  BobbleIAPHelper.m
//  BobbleFriends
//
//  Created by Peter Kamm on 3/5/14.
//  Copyright (c) 2014 Peter Kamm. All rights reserved.
//

#import "BobbleIAPHelper.h"

@implementation BobbleIAPHelper

+ (BobbleIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static BobbleIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.blankworldwide.bobblefriends.second",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
