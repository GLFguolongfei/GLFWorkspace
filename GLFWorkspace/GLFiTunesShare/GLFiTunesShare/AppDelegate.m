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
#import "TestViewController.h"
#import "MoveViewController.h"
#import "DYViewController.h"
#import "ThreeViewController.h"
#import "FourViewController.h"
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
    // 让程序从容的崩溃
    InstallUncaughtExceptionHandler();
    
    // 通知
    [self removeLocalNotifications];
    [self resignUserNotification:application andOptions:launchOptions];
    // 3DTouch
    [self creatShortcutItem];
    
    // 上班打卡
//    [self iskytrip:2];
//    [self iskytrip:3];
//    [self iskytrip:4];
//    [self iskytrip:5];
//    [self iskytrip:6];
    
    // 只有每次重新开启应用才会全局遍历文件,防止每次进入前台老是遍历
    [DocumentManager eachAllFiles];
    [DocumentManager updateDocumentPaths];
    
    BOOL isTestFounction = NO;
    if (isTestFounction) {
        TestViewController *testVC = [[TestViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:testVC];
        self.window.rootViewController = navi;
    } else {
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
    UIImage *image = [UIImage imageNamed:@"lunch1"];
#if FirstTarget
    image = [UIImage imageNamed:@"lunch5"];
#elif SecondTarget
    image = [UIImage imageNamed:@"lunch6"];
    // 重新登陆
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *record = [userDefaults objectForKey:kRecord];
    if ([record isEqualToString:@"1"]) {
        DocumentManager *manager = [DocumentManager sharedDocumentManager];
        if (![manager isRecording]) {
            [manager startRecording];
        }
    }
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

#pragma mark 3DTouch
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    if (shortcutItem) {
        UINavigationController *navi = (UINavigationController *)self.window.rootViewController;
        NSString *str1 = NSStringFromClass([navi.topViewController class]);
        if([shortcutItem.type isEqualToString:@"com.glf.dy"]){
            DYViewController *vc = [[DYViewController alloc] init];
            NSString *str2 = NSStringFromClass([DYViewController class]);
            if (![str1 isEqualToString:str2]) {
                [navi pushViewController:vc animated:YES];
            }
        } else if([shortcutItem.type isEqualToString:@"com.glf.photo"]){
            ThreeViewController *vc = [[ThreeViewController alloc] init];
            NSString *str2 = NSStringFromClass([ThreeViewController class]);
            if (![str1 isEqualToString:str2]) {
                [navi pushViewController:vc animated:YES];
            }
        } else if([shortcutItem.type isEqualToString:@"com.glf.video"]){
            FourViewController *vc = [[FourViewController alloc] init];
            NSString *str2 = NSStringFromClass([FourViewController class]);
            if (![str1 isEqualToString:str2]) {
                [navi pushViewController:vc animated:YES];
            }
        }
    }
    if (completionHandler) {
        completionHandler(YES);
    }
}

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
    NSString *title = content.title;                // 推送消息的标题
    NSString *subtitle = content.subtitle;          // 推送消息的副标题

    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) { // 远程通知
        NSLog(@"---------- iOS10前台收到远程通知");
        NSLog(@"body:%@,title:%@,subtitle:%@,badge:%@,sound:%@,userInfo:%@",body,title,subtitle,badge,sound,userInfo);
    } else { // 本地通知
        NSLog(@"---------- iOS10前台收到本地通知");
        NSLog(@"body:%@,title:%@,subtitle:%@,badge:%@,sound:%@,userInfo:%@",body,title,subtitle,badge,sound,userInfo);
        
        NSString *type = userInfo[@"NotificationType"];
        if ([type isEqualToString:@"iskytrip"]) {
            [ProjectManager iskytripLogin];
        }
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:body preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *destructAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:destructAction];
        
//        [self.window.rootViewController presentViewController:alertVC animated:YES completion:nil];
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

- (void)iskytrip:(NSInteger)weekday {
    // 1.创建一个触发器(trigger)
    // 在每周一的14点3分提醒
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.weekday = weekday;
    components.hour = 9;
    components.minute = 10;
    // components: 日期 repeats: 是否重复
    UNCalendarNotificationTrigger *calendarTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];

    // 2.创建推送的内容(UNMutableNotificationContent)
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"通知";
//    content.subtitle = [NSString stringWithFormat:@"上班打卡"];
    content.body = [NSString stringWithFormat:@"自动打卡%ld", weekday];;
    content.badge = @1;
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = @{@"NotificationType": @"iskytrip"};

    // 3.创建推送请求(UNNotificationRequest)
    NSString *requestIdentifier = [NSString stringWithFormat:@"iskytrip%ld", weekday];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:calendarTrigger];

    // 4.推送请求添加到推送管理中心(UNUserNotificationCenter)中
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"本地推送添加成功: %@", requestIdentifier);
        }
    }];
}

- (void)removeLocalNotifications {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *localArray = [app scheduledLocalNotifications];
    NSLog(@"所有本地推送: %@", localArray);
    [app cancelAllLocalNotifications];
    NSLog(@"解除所有本地推送");
}

// 3DTouch
- (void)creatShortcutItem {
    UIApplicationShortcutIcon *icon1 = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeCaptureVideo];
    UIApplicationShortcutIcon *icon2 = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeCapturePhoto];
    UIApplicationShortcutIcon *icon3 = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeLove];
    UIApplicationShortcutItem *item1 = [[UIApplicationShortcutItem alloc] initWithType:@"com.glf.video" localizedTitle:@"录像" localizedSubtitle:@"" icon:icon1 userInfo:nil];
    UIApplicationShortcutItem *item2 = [[UIApplicationShortcutItem alloc] initWithType:@"com.glf.photo" localizedTitle:@"拍照" localizedSubtitle:@"" icon:icon2 userInfo:nil];
    UIApplicationShortcutItem *item3 = [[UIApplicationShortcutItem alloc] initWithType:@"com.glf.dy" localizedTitle:@"抖音" localizedSubtitle:@"" icon:icon3 userInfo:nil];
    #if FirstTarget
        [UIApplication sharedApplication].shortcutItems = @[item1,item2,item3];
    #else
        [UIApplication sharedApplication].shortcutItems = @[item1,item2];
    #endif
}


@end
