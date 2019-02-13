//
//  YZpthread_mutex_condition.m
//  LearnGCD
//
//  Created by ios on 2019/2/13.
//  Copyright © 2019 KN. All rights reserved.
//

#import "YZpthread_mutex_condition.h"
#import <pthread.h>

@interface YZpthread_mutex_condition()

// money
@property(nonatomic,assign)NSInteger cash;

// 锁
@property(nonatomic,assign)pthread_mutex_t lock;

@end

@implementation YZpthread_mutex_condition

- (instancetype)init
{
    self = [super init];
    if (self) {
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        // NULL 就是default（normal）
        pthread_mutexattr_settype(&attr, NULL);
        pthread_mutex_init(&_lock, &attr);
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
    pthread_mutex_lock(&_lock);
    sleep(1);
    _cash -= 50;
    
    pthread_mutex_lock(&_lock);
    sleep(1);
    NSLog(@"拿走了50,还剩%li",(long)_cash);
    pthread_mutex_unlock(&_lock);
    NSLog(@"拿走了50,还剩%li",(long)_cash);
    pthread_mutex_unlock(&_lock);
}

- (void)saveMoney
{
    pthread_mutex_lock(&_lock);
    sleep(1);
    _cash += 100;
    NSLog(@"存了100,还剩%li",(long)_cash);
    pthread_mutex_unlock(&_lock);
}

- (void)dealloc
{
    pthread_mutex_destroy(&_lock);
}
@end

