//
//  BlockView.m
//  Puzzle
//
//  Created by ling tsu hsuan on 4/3/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "BlockView.h"

@implementation BlockView

#pragma mark - define

#define IMAGE_INSET         2
#define ID_LABEL_WIDTH      10
#define ID_LABEL_HEIGHT     10
#define ID_LABEL_FONT_SIZE  8

#pragma mark - synthesize

@synthesize blockId;
@synthesize displayId;
@synthesize originalPosition;
@synthesize currentPosition;
@synthesize imageView;

#pragma mark - dealloc

- (void)dealloc
{
    [imageView release];
    [super dealloc];
}

#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width - IMAGE_INSET * 2;
        CGFloat height = frame.size.height - IMAGE_INSET * 2;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(IMAGE_INSET, IMAGE_INSET, width, height)];
        [self addSubview:imageView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame id:(int)anId showId:(BOOL)aFlag
{
    self = [super initWithFrame:frame];
    if (self) {
        blockId = anId;
        displayId = aFlag;
        CGFloat width = frame.size.width - IMAGE_INSET * 2;
        CGFloat height = frame.size.height - IMAGE_INSET * 2;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(IMAGE_INSET, IMAGE_INSET, width, height)];
        [self addSubview:imageView];
        
        if(displayId)
        {
            UILabel *idLabel = [[UILabel alloc] init];
            idLabel.frame = CGRectMake(0, 0, ID_LABEL_WIDTH, ID_LABEL_HEIGHT);
            idLabel.font = [UIFont boldSystemFontOfSize:ID_LABEL_FONT_SIZE];
            idLabel.textColor = [UIColor redColor];
            idLabel.text = [NSString stringWithFormat:@"%d", blockId];
            [self addSubview:idLabel];
            [idLabel release];
        }
    }
    return self;
}

@end
