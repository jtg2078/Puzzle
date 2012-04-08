//
//  PuzzleOptionManager.h
//  Puzzle
//
//  Created by ling tsu hsuan on 4/8/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface PuzzleOptionManager : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

+ (PuzzleOptionManager *)sharedInstance;

@end




