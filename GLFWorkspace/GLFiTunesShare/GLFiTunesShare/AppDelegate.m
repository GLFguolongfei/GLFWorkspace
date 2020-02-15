//
//  AppDelegate.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/9/29.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "LoginViewController.h"
#import "ViewController.h"
#import "MoveViewController.h"
#import "UncaughtExceptionHandler.h"

@interface AppDelegate ()
{
    UIImageView *imageView; // 启动图
}
@end

@implementation AppDelegate


#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    [manager eachAllFiles:YES];
    
    // 让程序从容的崩溃
    // ----- 好像没起到作用,原因未知 -----
    InstallUncaughtExceptionHandler();
    
    BOOL isTestFounction = NO;
    if (isTestFounction) {
        ViewController *testVC = [[ViewController alloc] init];
        self.window.rootViewController = testVC;
    } else {
        [DocumentManager updateDocumentPaths];
#if FirstTarget
        RootViewController *rootVC = [[RootViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:rootVC];
        self.window.rootViewController = navi;
#elif SecondTarget
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = navi;
#else
        NSLog(@"---------------------- 其它Target ----------------------");
#endif
    }
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
#if FirstTarget
    UIImage *image = [UIImage imageNamed:@"lunch5"];
#elif SecondTarget
    UIImage *image = [UIImage imageNamed:@"lunch2"];
    // 重新登陆
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = navi;
#else
    NSLog(@"---------------------- 其它Target ----------------------");
#endif
    imageView = [[UIImageView alloc] initWithFrame:self.window.bounds];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.window addSubview:imageView];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [UIView animateWithDuration:2 animations:^{
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
    
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    [manager eachAllFiles:NO];
    [manager setVideosImage:10];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // 不记录,否则太耗费空间了
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kRecord];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSLog(@"很荣幸,收到内存警告");
}

#pragma mark 共享
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    return YES;
}
#else
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
    NSLog(@"%@ , %@", url, options);
    NSString *path = url.relativePath;
    NSArray *array = [path componentsSeparatedByString:@"/"];
    FileModel *model = [[FileModel alloc] init];
    model.path = path;
    model.name = array.lastObject;
#if FirstTarget
    MoveViewController *editVC = [[MoveViewController alloc] init];
    editVC.modelArray = @[model];
    [self.window.rootViewController presentViewController:editVC animated:YES completion:nil];
#elif SecondTarget
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.moveModel = model;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = navi;
#else
    NSLog(@"---------------------- 其它Target ----------------------");
#endif
    return YES;
}
#endif


@end
