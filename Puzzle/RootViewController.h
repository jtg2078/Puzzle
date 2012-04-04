//
//  RootViewController.h
//  Puzzle
//
//  Created by ling tsu hsuan on 4/3/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class BlockView;
@interface RootViewController : UIViewController <UIGestureRecognizerDelegate> {
    CGPoint invalid;
    int blockWidth;
    int blockHeight;
    int rows;
    int cols;
    int numBlocks;
    int imageWidth;
    int imageHeight;
}
@property (nonatomic, retain) NSArray *blockArray;
@property (nonatomic, retain) BlockView *emptyBlock;
@property (nonatomic) BOOL debuggingMode;
@end
