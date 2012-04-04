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
- (void)setupGestureRecognizersToBlock:(BlockView *)aBlock;

- (void)shuffleBlocksWithAnimation:(BOOL)animation;
- (CGPoint)testForPossibleMove:(BlockView *)aBlock;
- (BOOL)checkForPuzzleCompleteState;
- (void)checkPuzzleState;

- (UIImage *)diceUpImage:(UIImage *)aImage frame:(CGRect)aFrame;
- (UIImage *)resizeImageIfNeeded:(UIImage *)aImage width:(CGFloat)aWidth height:(CGFloat)aHeight;
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
@end

@implementation RootViewController

#pragma mark - define

#define NUM_BLOCK_PER_ROW_COL           4
#define DEFAULT_IMAGE_NAME              @"UIE_Slider_Puzzle--globe.jpg"
#define DEFAULT_BLOCK_ANIMATION_SPEED   0.2f
#define SHUFFLE_MOVE_COUNT              20

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
        debuggingMode = NO;
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
    blockWidth = imageWidth / cols;
    blockHeight = imageHeight / rows;
    int x = 0;
    int y = 0;
    int count = 0;
    
    for(int r = 0; r < rows; r++)
    {
        x = 0;
        for(int c = 0; c < cols; c++)
        {
            CGRect blockFrame = CGRectMake(x, y, blockWidth, blockHeight);            
            BlockView *block = [[BlockView alloc] initWithFrame:blockFrame id:count showId:self.debuggingMode];
            block.originalPosition = CGPointMake(c, r);
            block.currentPosition = CGPointMake(c, r);
            
            if(count == (numBlocks - 1))
            {
                self.emptyBlock = block;
                [block release];
                break;
            }
            
            block.imageView.image = [self diceUpImage:image frame:blockFrame];
            [self setupGestureRecognizersToBlock:block];
            
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

- (void)setupGestureRecognizersToBlock:(BlockView *)aBlock
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBlock:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setDelegate:self];
    [aBlock addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panBlock:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [aBlock addGestureRecognizer:panGesture];
    [panGesture release];
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

- (void)shuffleBlocksWithAnimation:(BOOL)animation
{
    NSMutableArray *moves = [NSMutableArray array];
    int numOfMoves = SHUFFLE_MOVE_COUNT;
    
    for(int i = 0; i < numOfMoves; i++)
    {
        for(BlockView *block in self.blockArray)
        {
            CGPoint possibleMove = [self testForPossibleMove:block];
            if(CGPointEqualToPoint(possibleMove, invalid) == NO)
            {
                [moves addObject:block];
            }
        }
        
        if(self.debuggingMode == YES)
        {
            NSLog(@"list of blocks that can move");
            [moves enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BlockView *block = (BlockView *)obj;
                NSLog(@"[%d]", block.blockId);
            }];
            
            int moveCount = [moves count];
            NSLog(@"number of avaiable moves: %d", moveCount);
            if(moveCount == 0)
            {
                CGPoint e = self.emptyBlock.currentPosition;
                NSLog(@"zero available move! the empty block pos is %@", NSStringFromCGPoint(e));
            }
        }
        
        // pick an action from actions and perform it
        int rand = arc4random() % moves.count;
        BlockView *block = [moves objectAtIndex:rand];
        [self swapBlcokAndEmptyBlockPosition:block animation:animation];
        [moves removeAllObjects];
    }
}

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

- (BOOL)checkForPuzzleCompleteState
{
    BOOL matchedWithInitialState = YES;
    
    for(BlockView *block in self.blockArray)
    {
        if(CGPointEqualToPoint(block.originalPosition, block.currentPosition) == NO)
        {
            matchedWithInitialState = NO;
            break;
        }
    }
    
    return matchedWithInitialState;
}

- (void)checkPuzzleState
{
    if([self checkForPuzzleCompleteState] == YES)
    {
        // the puzzle is solved!
        NSLog(@"you win!!");
        
        UIAlertView *message = [[[UIAlertView alloc] initWithTitle:@"You Win!" 
                                                           message:@"Puzzle solved" 
                                                          delegate:nil 
                                                 cancelButtonTitle:@"ok" 
                                                 otherButtonTitles: nil] autorelease];
        [message show];
    }
}

#pragma mark - user interaction

- (void)shuffleButtonPressed
{
    [self shuffleBlocksWithAnimation:YES];
}

- (void)tapBlock:(UITapGestureRecognizer *)gestureRecognizer
{
    BlockView *tappedBlock = (BlockView *)[gestureRecognizer view];
    
    CGPoint availableMove = [self testForPossibleMove:tappedBlock];
    if(CGPointEqualToPoint(availableMove, invalid) == NO)
    {
        [self swapBlcokAndEmptyBlockPosition:tappedBlock animation:YES];
        
        [self checkPuzzleState];
    }
}

- (void)panBlock:(UIPanGestureRecognizer *)gestureRecognizer
{
    BlockView *pannedBlock = (BlockView *)[gestureRecognizer view];
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        CGPoint availableMove = [self testForPossibleMove:pannedBlock];
        if(CGPointEqualToPoint(availableMove, invalid) == NO)
        {
            CGPoint translation = [gestureRecognizer translationInView:[pannedBlock superview]];
            
            // find out if the move is horizontal or vertical
            // since the either one x or y will remain the same, we can use this property
            // to determine the moved direction
            CGRect blockPos = pannedBlock.frame;
            if(availableMove.x == pannedBlock.currentPosition.x)
            {
                // vertical
                translation.x = 0;
                
                int start = MIN(pannedBlock.currentPosition.y, availableMove.y) * blockHeight;
                int end = MAX(pannedBlock.currentPosition.y, availableMove.y) * blockHeight;
                float c = blockPos.origin.y + translation.y;
                // limit the move range
                
                if(c <= start || c >= end)
                    translation.y = 0;
            }
            else 
            {
                // horizontal
                translation.y = 0;
                
                int start = MIN(pannedBlock.currentPosition.x, availableMove.x) * blockWidth;
                int end = MAX(pannedBlock.currentPosition.x, availableMove.x) * blockWidth;
                float c = blockPos.origin.x + translation.x;
                // limit the move range
                if(c <= start || c >= end)
                    translation.x = 0;
            }
            
            blockPos.origin.x += translation.x;
            blockPos.origin.y += translation.y;
            
            
            pannedBlock.frame = blockPos;
        }
        [gestureRecognizer setTranslation:CGPointZero inView:[pannedBlock superview]];
    }
    
    if([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        CGPoint availableMove = [self testForPossibleMove:pannedBlock];
        if(CGPointEqualToPoint(availableMove, invalid) == NO)
        {
            CGPoint translation = [gestureRecognizer translationInView:[pannedBlock superview]];
            
            // find out if the move is horizontal or vertical
            // since the either one x or y will remain the same, we can use this property
            // to determine the moved direction
            if(availableMove.x == pannedBlock.currentPosition.x)
            {
                // vertical
                translation.x = 0;
                float was = pannedBlock.currentPosition.y * blockHeight;
                float current = pannedBlock.frame.origin.y;
                int trigger = blockHeight / 2;
                if(abs(was - current) >= trigger)
                {
                    if(self.debuggingMode == YES) NSLog(@"vertical snapped over");
                    
                    [self swapBlcokAndEmptyBlockPosition:pannedBlock animation:YES];
                    [self checkPuzzleState];
                }
                else 
                {
                    if(self.debuggingMode == YES) NSLog(@"vertical snapped under");
                    
                    CGRect frame = CGRectMake(pannedBlock.currentPosition.x * blockWidth, pannedBlock.currentPosition.y * blockHeight, blockWidth, blockHeight);
                    [UIView animateWithDuration:DEFAULT_BLOCK_ANIMATION_SPEED animations:^{
                        
                        pannedBlock.frame = frame;
                    }]; 
                }
            }
            else 
            {
                // horizontal
                translation.y = 0;
                
                float was = pannedBlock.currentPosition.x * blockWidth;
                float current = pannedBlock.frame.origin.x;
                int trigger = blockWidth / 2;
                if(abs(was - current) >= trigger)
                {
                    if(self.debuggingMode == YES) NSLog(@"horizontal snapped over");
                    
                    [self swapBlcokAndEmptyBlockPosition:pannedBlock animation:YES];
                    [self checkPuzzleState];
                }
                else 
                {
                    if(self.debuggingMode == YES) NSLog(@"horizontal snapped under");
                    
                    CGRect frame = CGRectMake(pannedBlock.currentPosition.x * blockWidth, pannedBlock.currentPosition.y * blockHeight, blockWidth, blockHeight);
                    [UIView animateWithDuration:DEFAULT_BLOCK_ANIMATION_SPEED animations:^{
                        
                        pannedBlock.frame = frame;
                    }]; 
                }
            }
        }
        
        [gestureRecognizer setTranslation:CGPointZero inView:[pannedBlock superview]];
    }
}

#pragma mark - UIGestureRecognizerDelegate

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

// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

@end
