//
//  JLTranscodingBase.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/24/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "JLTimer.h"
#import "JLTranscodingBase.h"

@implementation JLTranscodingBase

#pragma mark - abstract methods, override these
- (BOOL)isReportTimers
{
    //implementer should override this
    NSLog(@"isReportTimers response coming from base class, this is probably not intentional.");
    return NO;
}

- (BOOL)isVerbose
{
    //implementer should override this
    NSLog(@"isVerbose response coming from base class, this is probably not intentional.");
    return YES;
}

#pragma mark - utils
- (JLTimer *)timerForMethodNamed:(NSString *)methodName
{
    if (![self isReportTimers]) {
        return nil;
    }
    JLTimer *timer = [[JLTimer alloc] initWithStartTimerName:methodName];
    return timer;
}

- (void)logVerbose:(NSString *)message
{
    if ([self isVerbose]) {
        NSLog(@"%@",message);
    }
}

@end
