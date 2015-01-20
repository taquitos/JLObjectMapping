//
//  JLTimer.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/23/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "JLTimer.h"

@interface JLTimer ()

@property (nonatomic, copy) NSString *timerName;
@property (nonatomic) CFAbsoluteTime startTime;
@property (nonatomic) CFAbsoluteTime totalTime;

@end

@implementation JLTimer

- (id)initWithStartTimerName:(NSString *)name
{
    self = [super init];
    if (self) {
        _totalTime = 0.0;
        _timerName = [name copy];
        _startTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"Timer: %@, Start", name);
    }
    return self;
}

- (void)recordTime:(NSString *)message
{
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime taskTime = (endTime - self.startTime);
    self.totalTime += taskTime;
    if (message) {
        NSLog(@"Timer: %@, %f, %@", self.timerName, taskTime, message);
    } else {
        NSLog(@"Timer: %@, %f", self.timerName, taskTime);
    }
    //reset for next recording
    self.startTime = endTime;
}

- (CFAbsoluteTime)totalElapsedTime
{
    return self.totalTime;
}

@end
