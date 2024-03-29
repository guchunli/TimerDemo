//
//  ViewController.m
//  test
//
//  Created by ICBC2019_IMAC on 11/8/2019.
//  Copyright © 2019 gcl. All rights reserved.
//

#import "ViewController.h"
#import "NSTimer+BlockTimer.h"
//#import "ProxyTimer.h"
//#import "WeakTimer.h"

@interface ViewController ()
{
    dispatch_source_t timer;
}

@property (nonatomic,copy) void (^delayStartBlock)(void);

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//     1.timer分为invocation和selector两种调用方式，其实这两种区别不大，一般我们用selector方式较为方便。
//    NSMethodSignature  *signature = [[self class] instanceMethodSignatureForSelector:@selector(Timered:)];
//    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
//    invocation.target = self;
//    invocation.selector = @selector(Timered:);
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 invocation:invocation repeats:YES];
//
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(Timered:) userInfo:nil repeats:YES];
//
//     2.scheduledTimerWith和timerWith这是因为NSTimer是加到runloop中执行的。看scheduledTimerWith的函数说明，创建并安排到runloop的default mode中。
//    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(Timered:) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//
//     3.坑
//     坑一：子线程启动定时器问题
//     主线程默认启动了runloop，可是子线程没有默认的runloop，我们在子线程启动定时器是不生效的,解决:在子线程启动一下runloop就可以了。
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
////        NSTimer* timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(Timered:) userInfo:nil repeats:YES];
////        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
//        // scheduledTimerWith:创建并安排到runloop的default mode中
//        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(Timered:) userInfo:nil repeats:YES];
//
//        // 子线程启动runloop
//        [[NSRunLoop currentRunLoop] run];
//    });
//
//     坑二：runloop的mode问题
//     UITrackingRunLoopMode和NSDefaultRunLoopMode都被标记为了common模式，所以只需要将timer的模式设置为NSRunLoopCommonModes，就可以在默认模式和追踪模式都能够运行。
//
//     坑三：循环引用问题
//     原因：就是NSTimer的target被强引用了，而通常target就是所在的控制器，他又强引用的timer，造成了循环引用
//    以下两种timer不会有循环引用：
//    （1）非repeat类型的。非repeat类型的timer不会强引用target，因此不会出现循环引用。
//    （2）block类型的，新api。iOS 10之后才支持，因此对于还要支持老版本的app来说，这个API暂时无法使用。当然，block内部的循环引用也要避免。
//    [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//    }];
//    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//    }];
//
//    强调：不是解决了循环引用，target就可以释放了，别忘了在持有timer的类dealloc的时候执行invalidate。
//
//    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(Timered:) userInfo:nil repeats:YES];
//    如上面代码，这个timer并没有被self引用，那么为什么self不会被释放呢？因为timer被加到了runloop中，timer又强引用了self，所以timer一直存在的话，self也不会释放
//    解决:打破timer对target的强引用。
//    解决方式一：NSTimer会保留其目标对象
//    /*
//     解释：将强引用的target变成了NSTimer的类对象。类对象本身是单例的，是不会释放的，所以强引用也无所谓。执行的block通过userInfo传递给定时器的响应函数timered:。循环引用被打破的结果是：
//     timer的使用者强引用timer。
//     timer强引用NSTimer的类对象。
//     timer的使用者在block中通过weak的形式使用，因此是被timer弱引用。
//     */
//    __weak id weakSelf = self;
//    NSTimer* timer = [NSTimer scheduledBlockTimerWithTimeInterval:1 repeats:YES blockTimer:^(NSTimer *timer) {
//        NSLog(@"block %@",weakSelf);
//    }];
//
//     解决方式二：NSProxy的方式
//     建立一个proxy类，让timer强引用这个实例，这个类中对timer的使用者target采用弱引用的方式，再把需要执行的方法都转发给timer的使用者。
//     NSTimer *timer = [ProxyTimer scheduledProxyTimerWithTimeInterval:1 target:self selector:@selector(Timered:) userInfo:nil repeats:YES];x
//    NSTimer *timer = [ProxyTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(Timered:) userInfo:nil repeats:YES];
//
//     解决方式三：封装timer，弱引用target
//     类似NSProxy的方式，建立一个桥接timer的实例，弱引用target，让timer强引用这个实例
//    NSTimer *timer = [NSTimer scheduledWeakTimerWithTimeInterval:1 target:self selector:@selector(Timered:) userInfo:nil repeats:YES];
//
//
//     GCD定时器
//    GCD定时器的好处是，他并不是加入runloop执行的，因此子线程也可以使用。也不会引起循环引用的问题。
//    注意:需要把timer声明为属性，否则，由于这种timer并不是添加到runloop中的，直接就被释放了。
//    __weak id weakSelf = self;
//    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
//    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
//    dispatch_source_set_event_handler(timer, ^{
//        [weakSelf timered];
//    });
//    dispatch_resume(timer);
//    // 取消定时器
//    dispatch_suspend(timer);
//    
//
//     dispatch_after
//     dispatch_after内部也是使用的Dispatch Source。因此也避免了NSTimer的很多坑。
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//    });
//
//     performSelector：after
//     这种方式通常是用于在延时后去处理一些操作，其内部也是基于将timer加到runloop中实现的。因此也存在NSTimer的关于子线程runloop的问题。这种调用方式的好处是可以取消。
//    [self performSelector:@selector(Timered:) withObject:nil afterDelay:3];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(Timered:) object:nil];
//
//     延时操作
//    /*
//    延时一次操作的选择：
//    几种方式都是定时器，都可以实现延时操作。综合相比：如果只是单独一次的延时操作，NSTimer和GCD的定时器都显得有些笨重。performSelector方式比较合适，但是又收到了子线程runloop的限制。因此，dispatch_after是最优的选择。
//    延时的取消操作：：
//    以上几种方式都可以实现取消操作。
//    NSTimer可以通过invalidate来停止定时器。
//    GCD的定时器可以调用dispatch_suspend来挂起。
//    performSelector：after可以通过cancelPreviousPerformRequestsWithTarget取消。
//    dispatch_after可以通过dispatch_block_cancel来取消。
//    */
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSLog(@"把我取消");
//        });
//    self.delayStartBlock = dispatch_block_create(0, ^{
//        NSLog(@"把我取消");
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(),self.delayStartBlock);
//    dispatch_block_cancel(self.delayStartBlock);
    
}

- (void)Timered:(NSTimer*)timer {
    NSLog(@"Timered");
}

- (void)timered{
    NSLog(@"timered");
}

@end
