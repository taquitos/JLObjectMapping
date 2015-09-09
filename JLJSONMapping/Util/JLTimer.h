//
//  JLTimer.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/23/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLTimer : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (id)initWithStartTimerName:(NSString *)name NS_DESIGNATED_INITIALIZER;

//can be called multiple times, only responds with time elapsed between invocations after responding unless it is the first
//time being called, then it is the time elapsed between start timer and first invocation
- (void)recordTime:(NSString *) message;

//call at the end if you called recordTime multiple times for elapsed time.
- (CFAbsoluteTime)totalElapsedTime;//call at the end if you called recordTime multiple times for elapsed time.

@end
