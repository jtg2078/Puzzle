//
//  AppDelegate.m
//  Puzzle
//
//  Created by ling tsu hsuan on 4/3/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "TestFlight.h"

@implementation AppDelegate

#pragma mark - define

#define TESTFLIGHT_TOKEN    @"05b650d0be87f18c4b39a68b8f315691_Nzc0OTkyMDEyLTA0LTAzIDExOjA3OjM4LjA4NTE3OA"

#pragma mark - synthesize

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:TESTFLIGHT_TOKEN];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    RootViewController *rvc = [[[RootViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:rvc] autorelease];
    nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [self.window setRootViewController:nav];
    
    // end override point
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
