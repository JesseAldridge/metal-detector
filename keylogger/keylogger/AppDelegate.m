//
//  AppDelegate.m
//  keylogger
//
//  Created by Jesse Aldridge on 7/22/14.
//  Copyright (c) 2014 Jesse Aldridge. All rights reserved.
//

#import "AppDelegate.h"
#import "MyController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    MyController *controller = [MyController alloc];
    (void)[controller init];
}

@end
