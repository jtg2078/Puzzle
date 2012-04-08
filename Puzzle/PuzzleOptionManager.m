//
//  PuzzleOptionManager.m
//  Puzzle
//
//  Created by ling tsu hsuan on 4/8/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "PuzzleOptionManager.h"
#import "BlockAlertView.h"


static PuzzleOptionManager *singletonManager = nil;

@interface PuzzleOptionManager()
- (UIImage *)getImageFromCamera;
- (UIImage *)getImageFromPhotoGallary;
@end

@implementation PuzzleOptionManager

#pragma mark - define

#pragma mark - synthesize

#pragma mark - dealloc

#pragma mark - init and setup

#pragma mark - main methods

- (void)showPuzzleMenu:(UIViewController *)sourceVC end:(void (^)())endBlock
{
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Puzzle Menu" message:@"Ready for a slider puzzle? Change the puzzle image to something else? Pick one the following options."];
    
    [alert setCancelButtonWithTitle:@"Cancel" block:nil];
    [alert addButtonWithTitle:@"I give up, show answer" block:^{
        //[self showActionSheet:nil];
    }];
    [alert addButtonWithTitle:@"Change image to..." block:^{
        //[self showAlert:nil];
    }];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES)
    {
        [alert addButtonWithTitle:@"Take a picture now and use that" block:^{
            //[self showAlert:nil];
        }];
    }
    [alert show];
}

#pragma mark - support methods

- (UIImage *)getImageFromCamera
{
    return nil;
}

- (UIImage *)getImageFromPhotoGallary
{
    return nil;
}

#pragma mark - camera methods

- (BOOL) startCameraControllerFromViewController:(UIViewController*)controller 
{    
    if (([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO) || (controller == nil))
        return NO;
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = self;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *) picker 
{
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
    [picker release];
}

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info 
{
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) 
    {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        imageToSave = editedImage ? editedImage : originalImage;
        
        // Save the new image (original or edited) to the Camera Roll
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
    }
    
    // Handle a movie capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) 
    {
        NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(moviePath, nil, nil, nil);
        }
    }
    
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
    [picker release];
}

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