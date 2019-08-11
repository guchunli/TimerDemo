//
//  ProxyTimer.m
//  test
//
//  Created by ICBC2019_IMAC on 11/8/2019.
//  Copyright © 2019 gcl. All rights reserved.
//

#import "ProxyTimer.h"
#import "ProxyObject.h"

@implementation ProxyTimer

//+ (NSTimer *)scheduledProxyTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo{
//    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:ti target:[ProxyObject proxyWithTarget: aTarget] selector:aSelector userInfo:userInfo repeats:yesOrNo];
//    return timer;
//}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo{
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:ti target:[ProxyObject proxyWithTarget: aTarget] selector:aSelector userInfo:userInfo repeats:yesOrNo];
    return timer;
}

@end
