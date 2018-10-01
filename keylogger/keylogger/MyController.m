#import "MyController.h"
#import <AppKit/NSAccessibility.h>

@implementation MyController

@synthesize then;

- (void)write_buffers:(NSTimer*)theTimer {
    NSLog(@"write_buffers");

    NSString *username = (NSString*)[theTimer userInfo];

    NSString *mouselog_subpath = [NSString stringWithFormat:@"mouselogs/%@", username];
    NSLog(@"writing mouselog_subpath: %@", mouselog_subpath);
    [self write_buffer:mouse_buffer dir_name:mouselog_subpath];

    NSString *keylog_subpath = [NSString stringWithFormat:@"keylogs/%@", username];
    [self write_buffer:key_buffer dir_name:keylog_subpath];
}

- (void)write_buffer:(NSMutableArray*)buffer dir_name:(NSString*)dir_name
{
    NSLog(@"writing mouse buffer: %lu", (unsigned long)[buffer count]);
    if ([buffer count] == 0) {
        return;
    }
    NSString *out_str = [buffer componentsJoinedByString:@"\n"];
    if (![out_str hasSuffix:@"\n"]) {
        out_str = [out_str stringByAppendingString:@"\n"];
    }
    
    [buffer removeAllObjects];

    @try {
        // Get path to daily log file.

        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *date_str = [dateFormatter stringFromDate:[NSDate date]];
        NSString *log_dir_path = [NSString stringWithFormat:@"~/Dropbox/%@/", dir_name];
        log_dir_path = [log_dir_path stringByExpandingTildeInPath];
        NSString *log_path = [NSString stringWithFormat:@"%@/%@.log", log_dir_path, date_str];
        NSLog(@"log_path: %@", log_path);

        NSFileHandle *out_file = [NSFileHandle fileHandleForWritingAtPath:log_path];
        
        if (out_file == nil) {
            // If log file doesn't exist, create it and parent directory.
            
            NSFileManager *filemgr;
            filemgr = [NSFileManager defaultManager];
            [filemgr createDirectoryAtPath:log_dir_path
               withIntermediateDirectories:YES attributes:nil error:nil];
            NSString *initial_str = @"timestamp keycode modifiers\n";
            BOOL success = [filemgr createFileAtPath:log_path
                                            contents:[initial_str dataUsingEncoding:NSUTF8StringEncoding]
                                          attributes:nil];
            
            if (success == YES) {
                out_file = [NSFileHandle fileHandleForWritingAtPath:log_path];
            } else {
                NSLog(@"Could not create file.");
            }
        }
        [out_file seekToEndOfFile];
        [out_file writeData:[out_str dataUsingEncoding:NSUTF8StringEncoding]];
    }
    @catch ( NSException *e ) {
        NSString *error_path = [@"~/Dropbox/mouselogs/error.txt" stringByExpandingTildeInPath];
        NSFileHandle *out_file = [NSFileHandle fileHandleForWritingAtPath:error_path];
        NSDate *curr_date = [NSDate date];
        [out_file writeData:[[NSString stringWithFormat:@"%i %@\n",
                              (int)round([curr_date timeIntervalSince1970]),
                              [e callStackSymbols]]
                             dataUsingEncoding:NSUTF8StringEncoding]];
        
        @throw;
    }
}

- (id)init
{
    self = [super init];

    // Load username from config file
    NSString *config_path = [@"~/.keylogger" stringByExpandingTildeInPath];
    NSString *config_str = [NSString stringWithContentsOfFile:config_path encoding:NSUTF8StringEncoding error:nil];
    if(config_str == NULL) {
        NSLog(@"config file not found");
    }

    NSData* config_data = [config_str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:config_data options:0 error:&error];
    NSString *username = jsonDict[@"username"];
    NSLog(@"username: %@", username);
    
    // Write buffers to files every 10 seconds.
    mouse_buffer = [NSMutableArray array];
    key_buffer = [NSMutableArray array];

    [NSTimer scheduledTimerWithTimeInterval:10.0
                                     target:self
                                   selector:@selector(write_buffers:)
                                   userInfo:username
                                    repeats:YES];

    // Prompt for permission to monitor keys.

    if (&AXIsProcessTrustedWithOptions != NULL) {
        // (10.9 and later)
        const void * keys[] = { kAXTrustedCheckOptionPrompt };
        const void * values[] = { kCFBooleanTrue };
        
        CFDictionaryRef options = CFDictionaryCreate(
                                                     kCFAllocatorDefault,
                                                     keys,
                                                     values,
                                                     sizeof(keys) / sizeof(*keys),
                                                     &kCFCopyStringDictionaryKeyCallBacks,
                                                     &kCFTypeDictionaryValueCallBacks);

        Boolean is_trusted = AXIsProcessTrustedWithOptions(options);
        NSLog(@"is_trusted: %hhu", is_trusted);
        if(!is_trusted)
            return self;
    }

    // Add mouse click lines to a buffer.
    NSLog(@"registering input handlers");
    
    [NSEvent
     addGlobalMonitorForEventsMatchingMask:NSLeftMouseUpMask
     handler:^ (NSEvent *event) {
         NSDate *curr_date = [NSDate date];
         
         NSString *mouse_str = [
                                NSString stringWithFormat:@"%@",
                                NSStringFromPoint([event locationInWindow])];
         
         NSString *line = [
                           NSString stringWithFormat:@"%i %@",
                           (int)round([curr_date timeIntervalSince1970]),
                           mouse_str];

         [mouse_buffer addObject:line];
     }];
    
    // Monitor keys too.
    [NSEvent
     addGlobalMonitorForEventsMatchingMask:NSKeyDownMask
     handler:^ (NSEvent *event) {
         NSDate *curr_date = [NSDate date];
         NSString *line = [NSString stringWithFormat:@"%i %i %lu",
                           (int)round([curr_date timeIntervalSince1970]),
                           [event keyCode], [event modifierFlags]];
         [key_buffer addObject:line];
     }];

    return self;
}
@end
