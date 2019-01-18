//
//  ViewController.m
//  LearnGCD
//
//  Created by ios on 2019/1/7.
//  Copyright © 2019年 KN. All rights reserved.
//

/*
 iOS常见多线程方案：pthread、NSThread、GCD、NSOperation（基于GCD）
 术语：
 同步（sync）：在当前线程中执行任务，不具备开启新线程的能力。
 异步（async）：在新的线程中执行任务，具备开启新线程的能力，但不一定会开启新线程。
 ************异步串行不开启新线程
 
 并发（serial）：多个任务同时执行  DISPATCH_QUEUE_SERIAL
 串行（concrrent）：一个任务执行完毕后，再执行下一个任务  DISPATCH_QUEUE_CONCURRENT
 
 同步并发、同步串行、同步主队列：不开启新线程，串行执行任务
 异步并发：开启新线程、并发执行任务
 异步串行：开启新线程、串行执行任务
 异步主队列：不开启新线程、串行执行任务
 ************同步主队列在主线程中调用，会出现互相堵塞导致Crash
 
 线程间通信
 dispatch_barrier_async : 先执行栅栏前的方法，再执行栅栏方法，最后执行栅栏后的方法
 dispatch_apply : 快速迭代
 dispatch_semaphore : 信号量机制，信号量为0时阻塞线程 用于保证线程安全
 */
#import "ViewController.h"

#define ThreadName "com.1-chengzi.learnGCD"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self interview1];
    [self interview2];
    [self interview3];
    [self solve];
    [self syncSerial];
    [self apply];
}

// 快速迭代  在函数执行完毕后才会运行下面的代码
//         在串行队列中与For循环类似
//         在并发队列中是随机的
- (void)apply {
    NSArray *num = @[@1,@2,@3,@4,@5,@6,@7,@8,@9];
    dispatch_queue_t sarialQueue = dispatch_queue_create(ThreadName, DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t concurrentQueue = dispatch_queue_create(ThreadName, DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(num.count, sarialQueue, ^(size_t index) {
        NSLog(@"serial : %@",num[index]);
    });
    dispatch_apply(num.count, concurrentQueue, ^(size_t index) {
        NSLog(@"concurrent : %@",num[index]);
    });
    
}

// 同步主队列在主线程中调用
// 在主线程出现Crash
- (void)syncSerial {
    dispatch_queue_t queue = dispatch_get_main_queue();
    // 解决方案 在线程中调用
    [NSThread detachNewThreadWithBlock:^{
        
        dispatch_sync(queue, ^{
            NSLog(@"syncSerial : 1");
        });
    }];
}

// 实现 异步并发执行任务1、任务2，在任务1、任务2都执行完毕后，回到主线程执行任务三
// dispatch_group_wait   阻塞当前线程，等待group中的任务完成
// dispatch_group_notify 监听 group 中任务的完成状态，当所有的任务都执行完成后，追加任务到 group 中，并执行任务
- (void)solve {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create(ThreadName, DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"solve : 1");
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:0.4];
        NSLog(@"solve : 2");
    });
    dispatch_group_notify(group, queue, ^{
        NSLog(@"solve : 3");
    });
}

// 面试题
- (void)interview1 {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        NSLog(@"interview1  :   1");
        // 不执行
        // 原因是子线程默认不开启runloop
        // performSelector:withObject:afterDelay:的本质是往Runloop中添加定时器
        [self performSelector:@selector(interviewTest) withObject:nil afterDelay:1.0];
        NSLog(@"interview1  :   3");
    });
}

- (void)interview2 {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"interview2  :   1");
        
        // 解决Crash 在子线程中增加runloop 不销毁子线程
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    }];
    // 执行完线程就被销毁
    [thread start];
    // 造成Crash 线程不存在
    [self performSelector:@selector(interviewTest) onThread:thread withObject:nil waitUntilDone:YES];
}

// 头条面试题
- (void)interview3 {
    dispatch_queue_t main_thread = dispatch_get_main_queue();
    dispatch_queue_t globe_thread = dispatch_get_global_queue(0, 0);
//    dispatch_async(main_thread, ^{
//        // 产生了死锁
//        // 同步主队列在主线程中调用  ->  syncSerial
//        dispatch_sync(main_thread, ^{
//            NSLog(@"123");
//        });
//        NSLog(@"456");
//    });
    // 解决
    dispatch_async(main_thread, ^{
        dispatch_sync(globe_thread, ^{
            NSLog(@"789");
        });
        NSLog(@"abc");
    });
}

-(void)interviewTest {
    NSLog(@"2");
}


@end
