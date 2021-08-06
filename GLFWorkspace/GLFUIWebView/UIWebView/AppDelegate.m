//
//  AppDelegate.m
//  UIWebView
//
//  Created by guolongfei on 2017/10/27.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MMScanViewController.h"
#import "WebViewController.h"
#import "WKWebViewController.h"

@interface AppDelegate ()
{
    UIImageView *imageView; // 启动图
}
@end

@implementation AppDelegate


#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 3DTouch
    [self creatShortcutItem];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    UIImage *image = [UIImage imageNamed:@"bg6"];
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

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark 共享
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    return YES;
}
#else
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
    NSLog(@"%@ , %@", url, options);
    
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = navi;
    [vc goURLVC:url.relativePath];
    
    return YES;
}
#endif

#pragma mark 3DTouch
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    if (shortcutItem) {
        if([shortcutItem.type isEqualToString:@"com.glf.scan"]){
            ViewController *vc = [[ViewController alloc] init];
            vc.action = 1;
            UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
            self.window.rootViewController = navi;
        } else if([shortcutItem.type isEqualToString:@"com.glf.baidu"]){
            ViewController *vc = [[ViewController alloc] init];
            vc.action = 2;
            UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
            self.window.rootViewController = navi;
        }
    }
    if (completionHandler) {
        completionHandler(YES);
    }
}

#pragma mark Setup
// 3DTouch
- (void)creatShortcutItem {
    UIApplicationShortcutIcon *icon1 = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeSearch];
    UIApplicationShortcutIcon *icon2 = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeHome];
    UIApplicationShortcutItem *item1 = [[UIApplicationShortcutItem alloc] initWithType:@"com.glf.scan" localizedTitle:@"扫码" localizedSubtitle:@"" icon:icon1 userInfo:nil];
    UIApplicationShortcutItem *item2 = [[UIApplicationShortcutItem alloc] initWithType:@"com.glf.baidu" localizedTitle:@"百度" localizedSubtitle:@"" icon:icon2 userInfo:nil];
    [UIApplication sharedApplication].shortcutItems = @[item1,item2];
}


@end
