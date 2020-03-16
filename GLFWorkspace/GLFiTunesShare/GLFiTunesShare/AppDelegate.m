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
// 防止低版本找不到头文件出现问题
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()
{
    UIImageView *imageView; // 启动图
}
@end

@implementation AppDelegate


#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self resignUserNotification:application andOptions:launchOptions];
    application.applicationIconBadgeNumber = 0;

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
    
    application.applicationIconBadgeNumber = 0;
    
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    [manager eachAllFiles:NO];
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

#pragma mark UNUserNotificationCenterDelegate
// iOS 10 收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    UNNotificationRequest *request = notification.request;  // 收到推送的请求
    UNNotificationContent *content = request.content;       // 收到推送的消息内容
    NSDictionary *userInfo = content.userInfo;
    NSNumber *badge = content.badge;                // 推送消息的角标
    NSString *body = content.body;                  // 推送消息体
    UNNotificationSound *sound = content.sound;     // 推送消息的声音
    NSString *subtitle = content.subtitle;          // 推送消息的副标题
    NSString *title = content.title;                // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) { // 远程通知
        NSLog(@"---------- iOS10前台收到远程通知");
        NSLog(@"body:%@,title:%@,subtitle:%@,badge:%@,sound:%@,userInfo:%@",body,title,subtitle,badge,sound,userInfo);
    } else { // 本地通知
        NSLog(@"---------- iOS10前台收到本地通知");
        NSLog(@"body:%@,title:%@,subtitle:%@,badge:%@,sound:%@,userInfo:%@",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法,选择是否提醒用户,有Badge、Sound、Alert三种类型可以设置
}

// 通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler
{
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content;               // 收到推送的消息内容
    NSDictionary * userInfo = content.userInfo;
    NSNumber *badge = content.badge;                // 推送消息的角标
    NSString *body = content.body;                  // 推送消息体
    UNNotificationSound *sound = content.sound;     // 推送消息的声音
    NSString *subtitle = content.subtitle;          // 推送消息的副标题
    NSString *title = content.title;                // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) { // 远程通知
        NSLog(@"---------- iOS10收到远程通知");
        NSLog(@"body:%@,title:%@,subtitle:%@,badge:%@,sound:%@,userInfo:%@",body,title,subtitle,badge,sound,userInfo);
    } else { // 本地通知
        NSLog(@"---------- iOS10收到本地通知");
        NSLog(@"body:%@,title:%@,subtitle:%@,badge:%@,sound:%@,userInfo:%@",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler();  // 系统要求执行这个方法
}

#pragma mark Setup
// 申请推送通知权限
- (void)resignUserNotification:(UIApplication *)application andOptions:(NSDictionary *)launchOptions {
    if (IOS10_OR_LATER) {               // iOS10特有
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self; // 必须写代理,不然无法监听通知的接收与点击
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                NSLog(@"用户点击允许推送通知");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"用户推送设定信息: %@", settings);
                }];
            } else {
                NSLog(@"用户点击不允许推送通知");
            }
        }];
    } else if (IOS8_OR_LATER) {         // iOS8 - iOS10
        UIUserNotificationType type = UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {                            // iOS8系统以下
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
    // 注册获得device Token
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}



@end
