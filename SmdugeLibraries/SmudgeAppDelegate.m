//
//  SmudgeAppDelegate.m
//  SmdugeLibraries
//
//  Created by Hisatomo Umaoka on 29/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SmudgeAppDelegate.h"

#import "SmudgeGalleryViewController.h"
#import "SmudgeGalleryModel.h"

@implementation SmudgeAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    SmudgeGalleryModel *galleryImage1 = [[SmudgeGalleryModel alloc] init];
    galleryImage1.imageURL = @"http://www.bostoncelticsproshop.com/images/products/fullimages/2253_Boston_Celtics_Domed_Decal.jpg";
    
    SmudgeGalleryModel *galleryImage2 = [[SmudgeGalleryModel alloc] init];
    galleryImage2.imageURL = @"http://www.freeshipping3.com/images//nba_jerseys/boston_celtics/celtics_034.jpg";
    
    SmudgeGalleryModel *galleryImage3 = [[SmudgeGalleryModel alloc] init];
    galleryImage3.imageURL = @"http://content.sportslogos.net/logos/6/213/full/nzluyptlwczf3ks24chjx3fnr.gif";
    
    SmudgeGalleryModel *galleryImage4 = [[SmudgeGalleryModel alloc] init];
    galleryImage4.imageURL = @"http://images4.fanpop.com/image/photos/18200000/Rajon-Rondo-rajon-rondo-18267177-1024-768.jpg";
    galleryImage4.caption = @"Rajon Rondo";
    
    self.viewController = [[SmudgeGalleryViewController alloc] initWithNibName:@"SmudgeGalleryViewController" bundle:nil];
    [self.viewController setGalleryName:@"Boston Celtics"];
    self.viewController.imageArray = [NSArray arrayWithObjects:galleryImage1, galleryImage2, galleryImage3, galleryImage4, nil];
    self.window.rootViewController = self.viewController;
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
