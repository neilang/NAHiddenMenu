//
//  NAAppDelegate.m
//  Demo
//
//  Created by Neil Ang on 2/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NAAppDelegate.h"
#import "NAHiddenMenuController.h"
#import "SampleTableViewController.h"
#import "SampleViewController.h"

@implementation NAAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    // Create the hidden menu controller
    NAHiddenMenuController * rootViewController;
    
    SampleViewController * sample1 = [[SampleViewController alloc] init];
    sample1.title = @"Sample 1";
    sample1.view.backgroundColor = [UIColor redColor];
    sample1.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:rootViewController action:@selector(showMenu:)];

    UINavigationController * sample1NavController = [[UINavigationController alloc] initWithRootViewController:sample1];
    
    SampleViewController * sample2 = [[SampleViewController alloc] init];
    sample2.title = @"Sample 2";
    sample2.view.backgroundColor = [UIColor blueColor];
    sample2.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:rootViewController action:@selector(showMenu:)];
    
    UINavigationController * sample2NavController = [[UINavigationController alloc] initWithRootViewController:sample2];
   
    // Create a sample table
    SampleTableViewController * sampleTable = [[SampleTableViewController alloc] init];
    sampleTable.title = @"Sample Table";
    sampleTable.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:rootViewController action:@selector(showMenu:)];
    
    UINavigationController * tableNavController = [[UINavigationController alloc] initWithRootViewController:sampleTable];
    
    NSArray * viewControllers = [NSArray arrayWithObjects:sample1NavController, sample2NavController, tableNavController, nil];
    rootViewController        = [[NAHiddenMenuController alloc] initWithViewControllers:viewControllers];
    
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
