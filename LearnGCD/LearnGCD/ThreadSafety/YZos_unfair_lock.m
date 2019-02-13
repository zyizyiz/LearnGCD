//
//  YZos_unfair_lock.m
//  LearnGCD
//
//  Created by ios on 2019/2/13.
//  Copyright © 2019 KN. All rights reserved.
//

#import "YZos_unfair_lock.h"
#import <os/lock.h>

@interface YZos_unfair_lock()

// money
@property(nonatomic,assign)NSInteger cash;

// 锁
@property(nonatomic,assign)os_unfair_lock lock;

@end

@implementation YZos_unfair_lock

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = OS_UNFAIR_LOCK_INIT;
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
    os_unfair_lock_lock(&_lock);
    sleep(1);
    _cash -= 50;
    NSLog(@"拿走了50,还剩%li",(long)_cash);
    os_unfair_lock_unlock(&_lock);
}

- (void)saveMoney
{
    os_unfair_lock_lock(&_lock);
    sleep(1);
    _cash += 100;
    NSLog(@"存了100,还剩%li",(long)_cash);
    os_unfair_lock_unlock(&_lock);
}
@end
