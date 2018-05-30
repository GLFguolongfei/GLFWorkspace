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
#import "EditViewController.h"

@interface AppDelegate ()
{
    UIImageView *imageView; // 启动图
}
@end

@implementation AppDelegate


#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    BOOL isTestFounction = NO;
    if (isTestFounction) {
        ViewController *testVC = [[ViewController alloc] init];
        self.window.rootViewController = testVC;
    } else {
        [GLFFileManager updateDocumentPaths];
#if FirstTarget
        RootViewController *rootVC = [[RootViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:rootVC];
        self.window.rootViewController = navi;
#elif SecondTarget
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = navi;
#else
        str = @"---------------------- 其它Target ----------------------";
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
}

#pragma mark 共享
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    return YES;
}

#else
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    NSLog(@"%@ , %@", url, options);
    
    NSString *path = url.relativePath;
    NSArray *array = [path componentsSeparatedByString:@"/"];
    FileModel *model = [[FileModel alloc] init];
    model.path = path;
    model.name = array.lastObject;
#if FirstTarget
    EditViewController *editVC = [[EditViewController alloc] init];
    editVC.modelArray = @[model];
    [self.window.rootViewController presentViewController:editVC animated:YES completion:nil];
#elif SecondTarget
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.moveModel = model;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = navi;
#else
    str = @"---------------------- 其它Target ----------------------";
#endif
    
    return YES;
}
#endif


@end
