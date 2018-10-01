//
//  MyController.h
//  keylogger
//
//  Created by Jesse Aldridge on 7/22/14.
//  Copyright (c) 2014 Jesse Aldridge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyController : NSObject {
    // UI
    NSStatusItem *statusItem;
    NSMenu *menu;
    NSMenuItem *quitMI;
    NSMenuItem *aboutMI;
    NSImage *tiny;
    
    // Not UI
    NSString *logPath;
    NSString *dateString;

    NSTimeInterval since;
    NSDate *now;

    NSMutableArray *mouse_buffer;
    NSMutableArray *key_buffer;

//    long tickStrokes;
//    long lastTick;
    
    NSFileHandle *output;
}
@property (retain) NSDate* then;
@end