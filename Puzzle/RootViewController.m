//
//  RootViewController.m
//  Puzzle
//
//  Created by ling tsu hsuan on 4/3/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "RootViewController.h"
#import "BlockView.h"

@interface RootViewController ()
- (void)setupNavigationBarButtons;
- (void)setupPuzzle;
- (void)shuffleBlocksWithAnimation:(BOOL)animation;
- (UIImage *)diceUpImage:(UIImage *)aImage frame:(CGRect)aFrame;
- (UIImage *)resizeImageIfNeeded:(UIImage *)aImage width:(CGFloat)aWidth height:(CGFloat)aHeight;

- (CGPoint)testForPossibleMove:(BlockView *)aBlock;

@end

@implementation RootViewController

#pragma mark - define

#define NUM_BLOCK_PER_ROW_COL           4
#define DEFAULT_IMAGE_NAME              @"UIE_Slider_Puzzle--globe.jpg"
#define DEFAULT_BLOCK_ANIMATION_SPEED   0.2f

#pragma mark - synthesize

@synthesize blockArray;
@synthesize emptyBlock;
@synthesize debuggingMode;

#pragma mark - dealloc

- (void)dealloc
{
    [blockArray release];
    [emptyBlock release];
    
    [super dealloc];
}

#pragma mark - init and setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        debuggingMode = YES;
        invalid = CGPointMake(-1, -1);
    }
    return self;
}

- (void)setupNavigationBarButtons
{
    // setup navigation bar buttons
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Shuffle" 
                                                                    style:UIBarButtonItemStyleBordered 
                                                                   target:self 
                                                                   action:@selector(shuffleButtonPressed)];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
}

- (void)setupPuzzle
{
    UIImage *image = [UIImage imageNamed:DEFAULT_IMAGE_NAME];
    int rows = NUM_BLOCK_PER_ROW_COL;
    int cols = NUM_BLOCK_PER_ROW_COL;
    int numBlocks = rows * cols;
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:numBlocks - 1];
    int imageWidth = 320;
    int imageHeight = 320;
    image = [self resizeImageIfNeeded:image width:imageWidth height:imageHeight];
    int blockWidth = imageWidth / cols;
    int blockHeight = imageHeight / rows;
    int x = 0;
    int y = 0;
    int count = 0;
    
    for(int r = 0; r < rows; r++)
    {
        x = 0;
        for(int c = 0; c < cols; c++)
        {
            CGRect blockFrame = CGRectMake(x, y, blockWidth, blockHeight);
            //BlockView *block = [[BlockView alloc] initWithFrame:blockFrame];
            BlockView *block = [[BlockView alloc] initWithFrame:blockFrame id:count showId:YES];
            block.originalPosition = CGPointMake(c, r);
            block.currentPosition = CGPointMake(c, r);
            
            if(count == (numBlocks - 1))
            {
                self.emptyBlock = block;
                [block release];
                break;
            }
            
            block.imageView.image = [self diceUpImage:image frame:blockFrame];
            
            [self.view addSubview:block];
            [array addObject:block];
            [block release];
            
            x += blockWidth;
            count++;
        }
        y += blockHeight;
    }
    
    self.blockArray = array;
}

- (void)shuffleBlocksWithAnimation:(BOOL)animation
{
    NSMutableArray *actions = [NSMutableArray array];
    int numOfMoves = 20;
    
    for(int i = 0; i < numOfMoves; i++)
    {
        for(BlockView *block in self.blockArray)
        {
            CGPoint possibleMove = [self testForPossibleMove:block];
            if(CGPointEqualToPoint(possibleMove, invalid) == NO)
            {
                [actions addObject:block];
            }
        }
        
        if(self.debuggingMode == YES)
        {
            NSLog(@"list of blocks that can move");
            [actions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BlockView *block = (BlockView *)obj;
                NSLog(@"[%d]", block.blockId);
            }];
            
            int moveCount = [actions count];
            NSLog(@"number of avaiable moves: %d", [actions count]);
            if(moveCount == 0)
            {
                CGPoint e = self.emptyBlock.currentPosition;
                NSLog(@"zero available move! the empty block pos is %@", NSStringFromCGPoint(e));
            }
        }
        
        // pick an action from actions and perform it
        int rand = arc4random() % actions.count;
        BlockView *block = [actions objectAtIndex:rand];
        [self swapBlcokAndEmptyBlockPosition:block animation:animation];
        [actions removeAllObjects];
    }
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupNavigationBarButtons];
    [self setupPuzzle];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - game logic methods

- (CGPoint)testForPossibleMove:(BlockView *)aBlock
{
    // see if aBlock's neighbor contains empty block or not
    int rows = NUM_BLOCK_PER_ROW_COL;
    int cols = NUM_BLOCK_PER_ROW_COL;
    int top = 0;
    int left = 0;
    int right = cols - 1;
    int down = rows - 1;
    CGPoint p = aBlock.currentPosition;
    CGPoint n = CGPointZero;
    CGPoint e = self.emptyBlock.currentPosition;
    
    // top
    if(p.y > top)
    {
        n.x = p.x;
        n.y = p.y - 1;
        if(CGPointEqualToPoint(n, e))
            return n;
    }
    
    // left
    if(p.x > left)
    {
        n.x = p.x - 1;
        n.y = p.y;
        if(CGPointEqualToPoint(n, e))
            return n;
    }
    
    // right
    if(p.x < right)
    {
        n.x = p.x + 1;
        n.y = p.y;
        if(CGPointEqualToPoint(n, e))
            return n;
    }
    
    // down
    if(p.y < down)
    {
        n.x = p.x;
        n.y = p.y + 1;
        if(CGPointEqualToPoint(n, e))
            return n;
    }
    
    return invalid;
}

- (void)swapBlcokAndEmptyBlockPosition:(BlockView *)aBlock animation:(BOOL)animation 
{
    if(self.debuggingMode == YES)
    {
        NSLog(@"before the swap");
        NSLog(@"empty block :%@ loc:%@", NSStringFromCGPoint(self.emptyBlock.currentPosition), NSStringFromCGPoint(self.emptyBlock.frame.origin));
        NSLog(@"block [%d]%@ loc:%@", aBlock.blockId, NSStringFromCGPoint(aBlock.currentPosition), NSStringFromCGPoint(aBlock.frame.origin));
    }
    
    CGPoint tmp = self.emptyBlock.currentPosition;
    self.emptyBlock.currentPosition = aBlock.currentPosition;
    aBlock.currentPosition = tmp;
    
    CGRect e = self.emptyBlock.frame;
    e.origin.x = emptyBlock.currentPosition.x * e.size.width;
    e.origin.y = emptyBlock.currentPosition.y * e.size.height;
    
    CGRect b = aBlock.frame;
    b.origin.x = aBlock.currentPosition.x * b.size.width;
    b.origin.y = aBlock.currentPosition.y * b.size.height;
    
    if(self.debuggingMode == YES)
    {
        NSLog(@"empty block changed to: %@", NSStringFromCGRect(e));
        NSLog(@"block changed to: %@", NSStringFromCGRect(b));
    }
    
    if(animation)
    {
        [UIView animateWithDuration:DEFAULT_BLOCK_ANIMATION_SPEED animations:^{
            
            self.emptyBlock.frame = e;
            aBlock.frame = b;
        }];
    }
    else 
    {
        self.emptyBlock.frame = e;
        aBlock.frame = b;
    }
    
    if(self.debuggingMode == YES)
    {
        NSLog(@"\nafter the swap");
        NSLog(@"empty block :%@ loc:%@", NSStringFromCGPoint(self.emptyBlock.currentPosition), NSStringFromCGPoint(self.emptyBlock.frame.origin));
        NSLog(@"block [%d]%@ loc:%@", aBlock.blockId, NSStringFromCGPoint(aBlock.currentPosition), NSStringFromCGPoint(aBlock.frame.origin));
    }
}

#pragma mark - user interaction

- (void)shuffleButtonPressed
{
    [self shuffleBlocksWithAnimation:YES];
}

#pragma mark - utility methods

- (UIImage *)diceUpImage:(UIImage *)aImage frame:(CGRect)aFrame
{
    CGImageRef ref = CGImageCreateWithImageInRect(aImage.CGImage, aFrame);
    UIImage *image = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    return image;
}

- (UIImage *)resizeImageIfNeeded:(UIImage *)aImage width:(CGFloat)aWidth height:(CGFloat)aHeight
{
    if(aImage.size.width == aWidth && aImage.size.height == aHeight)
        return aImage;
    
    CGSize newSize = CGSizeMake(aWidth, aHeight);
    
    UIGraphicsBeginImageContext(newSize);
    [aImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
