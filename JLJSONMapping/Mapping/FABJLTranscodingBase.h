//
//  JLTranscodingBase.h
//  JLJSONMapping
//
//  Base class for JLObjectSerializer/Deserializer, contains shared utilities
//
//  Created by Joshua Liebowitz on 7/24/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FABJLTimer;

@interface FABJLTranscodingBase : NSObject

- (FABJLTimer *)timerForMethodNamed:(NSString *)methodName;
- (BOOL)isReportTimers;
- (BOOL)isVerbose;
- (void)logVerbose:(NSString *)message;

@end
