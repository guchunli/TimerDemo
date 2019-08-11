//
//  WeakTimer.m
//  test
//
//  Created by ICBC2019_IMAC on 11/8/2019.
//  Copyright © 2019 gcl. All rights reserved.
//

#import "WeakTimer.h"

@implementation WeakTimer
- (void)dealloc{
    NSLog(@"timer dealloc");
}

- (void)timered:(NSTimer*)timer{
    [self.target performSelector:self.selector withObject:timer];
}
@end

@implementation NSTimer(NormalTimer)
+ (NSTimer *)scheduledWeakTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo{
    WeakTimer *weakTimer = [[WeakTimer alloc] init];
    weakTimer.target = aTarget;
    weakTimer.selector = aSelector;
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:ti target:weakTimer selector:@selector(timered:) userInfo:userInfo repeats:yesOrNo];
    return timer;
}

@end
