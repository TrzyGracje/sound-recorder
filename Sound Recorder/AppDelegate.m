//
//  AppDelegate.m
//  Sound Recorder
//
//  Created by Lukasz Komorowski on 29.05.2016.
//  Copyright © 2016 Lukasz Komorowski. All rights reserved.
//

#import "AppDelegate.h"
#import "UIColor+CustomColors.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UINavigationBar appearance].barTintColor = [UIColor troutColor];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

    return YES;
}

@end
