//
//  RootViewController.h
//  Puzzle
//
//  Created by ling tsu hsuan on 4/3/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BlockView;
@interface RootViewController : UIViewController {
    CGPoint invalid;
}
@property (nonatomic, retain) NSArray *blockArray;
@property (nonatomic, retain) BlockView *emptyBlock;
@property (nonatomic) BOOL debuggingMode;
@end
