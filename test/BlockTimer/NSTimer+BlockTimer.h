//
//  NSTimer+BlockTimer.h
//  test
//
//  Created by ICBC2019_IMAC on 11/8/2019.
//  Copyright © 2019 gcl. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (BlockTimer)

+ (NSTimer*)scheduledBlockTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats blockTimer:(void (^)(NSTimer *))block;

@end

NS_ASSUME_NONNULL_END
