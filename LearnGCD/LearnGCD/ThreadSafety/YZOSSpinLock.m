//
//  OSSpinLock.m
//  LearnGCD
//
//  Created by ios on 2019/2/13.
//  Copyright © 2019 KN. All rights reserved.
//

#import "YZOSSpinLock.h"
#import <libkern/OSAtomic.h>

@interface YZOSSpinLock ()

// money
@property(nonatomic,assign)NSInteger cash;

// 锁
@property(nonatomic,assign)OSSpinLock lock;
@end

@implementation YZOSSpinLock

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = OS_SPINLOCK_INIT;
        [self test];
    }
    return self;
}

- (void)test
{
    _cash = 200;
    
    dispatch_queue_t queue = dispatch_queue_create("456789", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            [self takeMoney];
        });
        dispatch_async(queue, ^{
            [self saveMoney];
        });
    }
}

- (void)takeMoney
{
    OSSpinLockLock(&_lock);
    sleep(1);
    _cash -= 50;
    NSLog(@"拿走了50,还剩%li",(long)_cash);
    OSSpinLockUnlock(&_lock);
}

- (void)saveMoney
{
    OSSpinLockLock(&_lock);
    sleep(1);
    _cash += 100;
    NSLog(@"存了100,还剩%li",(long)_cash);
    OSSpinLockUnlock(&_lock);
}
@end
