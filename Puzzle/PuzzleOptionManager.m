//
//  PuzzleOptionManager.m
//  Puzzle
//
//  Created by ling tsu hsuan on 4/8/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "PuzzleOptionManager.h"


static PuzzleOptionManager *singletonManager = nil;

@implementation PuzzleOptionManager

#pragma mark - define

#pragma mark - synthesize

#pragma mark - dealloc

#pragma mark - init and setup

#pragma mark - main methods

#pragma mark - singleton implementation code

+ (PuzzleOptionManager *)sharedInstance {
    
    static dispatch_once_t pred;
    static PuzzleOptionManager *manager;
    
    dispatch_once(&pred, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (singletonManager == nil) {
            singletonManager = [super allocWithZone:zone];
            return singletonManager;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}
- (oneway void)release {
    //do nothing
}
- (id)autorelease {
    return self;
}

@end