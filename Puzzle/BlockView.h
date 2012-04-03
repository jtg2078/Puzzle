//
//  BlockView.h
//  Puzzle
//
//  Created by ling tsu hsuan on 4/3/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlockView : UIView

@property (nonatomic) int blockId;
@property (nonatomic) BOOL displayId;
@property (nonatomic) CGPoint originalPosition;
@property (nonatomic) CGPoint currentPosition;
@property (nonatomic, retain) UIImageView *imageView;

- (id)initWithFrame:(CGRect)frame id:(int)anId showId:(BOOL)aFlag;

@end
