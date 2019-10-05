//
//  UncaughtExceptionHandler.m
//  UncaughtExceptions
//
//  Created by Matt Gallagher on 2010/05/25.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "UncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0; // 未捕获的异常数目
const int32_t UncaughtExceptionMaximum = 10; // 未捕获的异常最大数目

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

#pragma mark OC类
@implementation UncaughtExceptionHandler


+ (NSArray *)backtrace {
	 void *callstack[128];
	 int frames = backtrace(callstack, 128);
	 char **strs = backtrace_symbols(callstack, frames);
	 
	 int i;
	 NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
	 for (i = UncaughtExceptionHandlerSkipAddressCount; i < UncaughtExceptionHandlerSkipAddressCount + UncaughtExceptionHandlerReportAddressCount; i++)
	 {
	 	[backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
	 }
	 free(strs);
	 
	 return backtrace;
}

- (void)handleException:(NSException *)exception {
    // 1-保存发送Crash信息
    [self validateAndSaveCriticalApplicationData:exception];
    
    // 2-弹框
    NSString *message = [NSString stringWithFormat:NSLocalizedString(
                                                                     @"You can try to continue but the application may be unstable.\n\n"
                                                                     @"Debug details follow:\n%@\n%@", nil),
                         [exception reason],
                         [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: NSLocalizedString(@"Unhandled exception", nil)
                          message: message
                          delegate: self
                          cancelButtonTitle: NSLocalizedString(@"退出App", nil)
                          otherButtonTitles: NSLocalizedString(@"不予理会", nil), nil];
    [alert show];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!dismissed) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    
    // 3-清除
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL,  SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE,  SIG_DFL);
    signal(SIGBUS,  SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    } else {
        [exception raise];
    }
}


- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex {
	if (anIndex == 0) { // 退出App
		dismissed = YES;
    } else if (anIndex == 1) { // 不予理会

    }
}

- (void)validateAndSaveCriticalApplicationData:(NSException *)exception  {
    NSString *name = [exception name];              // 异常类型
    NSString *reason = [exception reason];          // 非常重要，就是崩溃的原因
    NSDictionary *userInfo = [exception userInfo];
    
    NSString *crashInfo = [NSString stringWithFormat:@"exception type:%@ \nexception reason: %@ \nexception userInfo: %@", name, reason, userInfo];
    
    // 获取document目录(即Home目录）保存Crash文件到其下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSLog(@"document目录(即Home目录): %@", path);
    
    NSString *crashPath = [path stringByAppendingPathComponent:@"/Exception.txt"];
    [crashInfo writeToFile:crashPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


@end





#pragma mark C语言函数
// 初始设置
void InstallUncaughtExceptionHandler(void) {
    // 当应用发生异常而产生NSException后,就将会进入我们自定义的回调函数HandleException
    NSSetUncaughtExceptionHandler(&HandleException);
    
    // 当应用发生错误而产生Signal后,就将会进入我们自定义的回调函数MySignalHandler
    signal(SIGABRT, SignalHandler);
    signal(SIGILL,  SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE,  SignalHandler);
    signal(SIGBUS,  SignalHandler);
    signal(SIGPIPE, SignalHandler);
}

// 处理NSException
void HandleException(NSException *exception) {
    // 1-如果当前未捕获的异常数目大于我们定义的最大未捕获异常数目,就不在操作了
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum) {
		return;
	}
	
    // 2-获取信息设置userInfo
	NSArray *callStack = [UncaughtExceptionHandler backtrace];
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
	[userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
	
    // 3-处理NSException
    NSException *myException = [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo];
	[[[UncaughtExceptionHandler alloc] init] performSelectorOnMainThread:@selector(handleException:) withObject:myException
			 waitUntilDone:YES];
}

// 处理signal
void SignalHandler(int signal) {
    // 1-如果当前未捕获的异常数目大于我们定义的最大未捕获异常数目,就不在操作了
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum) {
		return;
	}
	
    // 2-获取信息设置userInfo
	NSArray *callStack = [UncaughtExceptionHandler backtrace];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
	[userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
	
    // 3-处理NSException
    NSString *myReason = [NSString stringWithFormat: NSLocalizedString(@"Signal %d was raised.", nil), signal];
    NSDictionary *myUserInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
    NSException *myException = [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName reason:myReason
                                userInfo:myUserInfo];
	[[[UncaughtExceptionHandler alloc] init] performSelectorOnMainThread:@selector(handleException:) withObject:myException waitUntilDone:YES];
}

