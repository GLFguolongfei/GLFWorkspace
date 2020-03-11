//
//  WKWebViewController+RegisterHandler.m
//  UIWebView
//
//  Created by guolongfei on 2020/3/11.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "WKWebViewController+RegisterHandler.h"

@implementation WKWebViewController (RegisterHandler)


#pragma mark 公用方法
- (void)registerHandlers {
    kWEAKSELF
    // app版本号
    [self registerHandler:@"AirportAppVersion" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportAppVersion:data callBack:responseCallback];
    }];
    // 新开webview
    [self registerHandler:@"AirportOpenWebView" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportOpenWebView:data callBack:responseCallback];
    }];
    // 打开原生页面
    [self registerHandler:@"AirportOpenPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportOpenPage:data callBack:responseCallback];
    }];
    // 获取app渠道
    [self registerHandler:@"AirportAppChannel" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportAppChannel:data callBack:responseCallback];
    }];
    // 获取导航条高度
    [self registerHandler:@"AirportNavHeight" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportNavHeight:data callBack:responseCallback];
    }];
    // 获取信号栏文字颜色
    [self registerHandler:@"AirportSignalBarColor" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportSignalBarColor:data callBack:responseCallback];
    }];
    // 获取信号栏背景色
    [self registerHandler:@"AirportSignalBarBackgroundColor" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportSignalBarBackgroundColor:data callBack:responseCallback];
    }];
    // 获取信号栏高度
    [self registerHandler:@"AirportSignalBarHeight" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportSignalBarHeight:data callBack:responseCallback];
    }];
    // 定位经纬度
    [self registerHandler:@"AirportLocation" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportLocation:data callBack:responseCallback];
    }];
    // 是否在App当中
    [self registerHandler:@"AirportInTheApp" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportInTheApp:data callBack:responseCallback];
    }];
    // 拨打电话
    [self registerHandler:@"AirportCallPhone" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportCallPhone:data callBack:responseCallback];
    }];
    // 页面回退
    [self registerHandler:@"AirportViewBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportViewBack:data callBack:responseCallback];
    }];
    // 写临时存储
    [self registerHandler:@"AirportSetNativeStorage" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportSetNativeStorage:data callBack:responseCallback];
    }];
    // 读临时存储
    [self registerHandler:@"AirportGetNativeStorage" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportGetNativeStorage:data callBack:responseCallback];
    }];
    // 删除临时存储
    [self registerHandler:@"AirportDeleteNativeStorage" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportDelectNativeStorage:data callBack:responseCallback];
    }];
    // 禁止当前页面右滑返回
    [self registerHandler:@"AirportBanRightGestures" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportBanRightGestures:data callBack:responseCallback];
    }];
    // 获取APP Token
    [self registerHandler:@"AirportToken" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportToken:data callBack:responseCallback];
    }];
    // 获取app request Header
    [self registerHandler:@"AirportHeader" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportHeader:data callBack:responseCallback];
    }];
    // 获取AuthCode
    [self registerHandler:@"AirportAuthCode" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportAuthCode:data callBack:responseCallback];
    }];
    // 添加toast
    [self registerHandler:@"AirportToast" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportToast:data callBack:responseCallback];
    }];
    // 打开定位设置权限
    [self registerHandler:@"AirportLocationPermissions" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportLocationpPermissions:data callBack:responseCallback];
    }];
    // 开启或关闭webview Bounces效果
    [self registerHandler:@"AirportOpenBounces" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportIosBounces:data callBack:responseCallback];
    }];
    // 埋点事件统计
    [self registerHandler:@"AirportUbtEvent" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportUbtEvent:data callBack:responseCallback];
    }];
    // 埋点进入页面
    [self registerHandler:@"AirportUbtPageIn" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportUbtPageIn:data callBack:responseCallback];
    }];
    // 埋点离开页面
    [self registerHandler:@"AirportUbtPageOut" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportUbtPageOut:data callBack:responseCallback];
    }];
    // 获取当前机场信息
    [self registerHandler:@"UserAirportInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportUserAirportInfo:data callBack:responseCallback];
    }];
    // loading展示和关闭
    [self registerHandler:@"airportLoading" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf airportLoading:data callBack:responseCallback];
    }];
}

#pragma mark 私有方法
// 获取app版本号
- (void)airportAppVersion:(id)data callBack:(WVJBResponseCallback)responseCallback {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    responseCallback(@{@"appVersion": version});
}

// 新开webview
- (void)airportOpenWebView:(id )data callBack:(WVJBResponseCallback)responseCallback {
    if ([data isKindOfClass:[NSDictionary class]]) {
        if ([[data allKeys] containsObject:@"url"]) {
            NSString *urlString = data[@"url"];
            id params = data[@"params"];
            
            WKWebViewController *vc = [[WKWebViewController alloc] init];
            if (urlString.length > 0) {
                vc.urlStr = urlString;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
}

// 打开原生页面
- (void)airportOpenPage:(id)data callBack:(WVJBResponseCallback)responseCallback {
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSString *pageName = [data objectForKey:@"pageName"];
        NSString *str = [NSString stringWithFormat:@"打开原生页面: %@", pageName];
        [self showStringHUD:str second:2];
    }
}

// 获取app渠道
- (void)airportAppChannel:(id)data callBack:(WVJBResponseCallback)responseCallback {
    responseCallback(@{@"appChannel":@"AppStore"});
}

#pragma mrk 获取导航条高度
- (void)airportNavHeight:(id)data callBack:(WVJBResponseCallback)responseCallback {
    responseCallback(@{@"navHeight":@(NAVIGATION_HEIGHT_X)});
}

// 获取信号栏文字颜色
- (void)airportSignalBarColor:(NSDictionary *)data callBack:(WVJBResponseCallback)responseCallback {
    if ([data[@"color"] isEqualToString:@"black"]) {
        //设置全局状态栏字体颜色为黑色
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        responseCallback(@{@"result":@(true)});
    } else if ([data[@"color"] isEqualToString:@"white"]) {
        //设置全局状态栏字体颜色为白色
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        responseCallback(@{@"result":@(true)});
    } else {
        responseCallback(@{@"result":@(false)});
    }
}

// 获取信号栏背景色
- (void)airportSignalBarBackgroundColor:(NSDictionary *)data callBack:(WVJBResponseCallback)responseCallback {
    NSString * colorStr = data[@"backgroundColor"];
    [self setStatusBarBackgroundColor:colorStr];
    if (colorStr.length > 0) {
        responseCallback(@{@"result":@(true)});
    } else {
        responseCallback(@{@"result":@(false)});
    }
}

// 获取信号栏高度
- (void)airportSignalBarHeight:(NSDictionary *)data callBack:(WVJBResponseCallback)responseCallback {
    responseCallback(@{@"height":@(STATUSBAR_HEIGHT_X)});
}

// 定位经纬度
- (void)airportLocation:(id)data callBack:(WVJBResponseCallback)responseCallback {
    responseCallback(@{@"status":@"201"});
}

// 是否在App当中
- (void)airportInTheApp:(id)data callBack:(WVJBResponseCallback)responseCallback {
    responseCallback(@{@"InTheApp":@(true)});
}

// 拨打电话
- (void)airportCallPhone:(NSDictionary *)data callBack:(WVJBResponseCallback)responseCallback {
    NSString * phone = data[@"num"];
    
    if (phone.length > 0) {
        NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:^(BOOL success) {
            //回调
        }];
        responseCallback(@{@"result":@(true)});
    } else {
        responseCallback(@{@"result":@(false)});
    }
    
}

// 页面回退
- (void)airportViewBack:(id )data callBack:(WVJBResponseCallback)responseCallback {
    if ([data isKindOfClass:[NSDictionary class]]) {
        if ([data allKeys].count > 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

// 写临时存储
- (void)airportSetNativeStorage:(id )data callBack:(WVJBResponseCallback)responseCallback {
    if ([data isKindOfClass:[NSDictionary class]]) {
        if ([[data allKeys] containsObject:@"key"]) {
            NSString *key = [data objectForKey:@"key"];
            if (key.length>0) {
                if ([[data allKeys] containsObject:@"data"]) {
                    id values = [data objectForKey:@"data"];
                    if (values==nil) {
                        values=@"";
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:values forKey:key];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    responseCallback(@{@"result":@(true)});
                } else {
                    responseCallback(@{@"result":@(false)});
                }
            }
        } else {
            responseCallback(@{@"result":@(false)});
        }
    } else {
        responseCallback(@{@"result":@(false)});
    }
}

// 读临时存储
- (void)airportGetNativeStorage:(id )data callBack:(WVJBResponseCallback)responseCallback {
    id values;
    if ([data isKindOfClass:[NSDictionary class]]) {
        if ([[data allKeys] containsObject:@"key"]) {
            NSString *key = [data objectForKey:@"key"];
            if (key.length>0) {
                values=[[NSUserDefaults standardUserDefaults] objectForKey:key];
                if (values==nil) {
                    values=@"";
                }
                responseCallback(@{@"result":@(true),@"data":values});
            } else {
                responseCallback(@{@"result":@(false)});
            }
        } else {
            responseCallback(@{@"result":@(false)});
        }
    } else {
        responseCallback(@{@"result":@(false)});
    }
}

// 删除临时存储
- (void)airportDelectNativeStorage:(id )data callBack:(WVJBResponseCallback)responseCallback {
    if ([data isKindOfClass:[NSDictionary class]]) {
        if ([[data allKeys] containsObject:@"key"]) {
            NSString *key = [data objectForKey:@"key"];
            if (key.length>0) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
                responseCallback(@{@"result":@(true)});
            } else {
                responseCallback(@{@"result":@(false)});
            }
        } else {
            responseCallback(@{@"result":@(false)});
        }
    } else {
        responseCallback(@{@"result":@(false)});
    }
}

// 禁止当前页面右滑返回
- (void)airportBanRightGestures:(id )data callBack:(WVJBResponseCallback)responseCallback {
    
}

// --获取APP Token
- (void)airportToken:(id )data callBack:(WVJBResponseCallback)responseCallback {
    responseCallback(@{
        @"token": @"",
        @"userId": @"162",
        @"result": @(true)
    });
}

// --获取Header
- (void)airportHeader:(id )data callBack:(WVJBResponseCallback)responseCallback {
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
//    [dict setObject:@"60103" forKey:@"appId"];
//    [dict setObject:@"101" forKey:@"channelSource"];
//    [dict setObject:@"" forKey:@"clientIp"];
//    [dict setObject:@"ios" forKey:@"clientName"];
//    [dict setObject:KVersion forKey:@"clientVersion"];
//    [dict setObject:@"" forKey:@"customerData"];
//    [dict setObject:[SKUUID getUUID] forKey:@"deviceId"];
//    [dict setObject:@(2) forKey:@"deviceType"];
//    [dict setObject:@"" forKey:@"requestId"];
//    [dict setObject:[NSString getNowTimeTimestamp] forKey:@"timestamp"];
//    [dict setObject:isNotEmptyValue(APPInstance.token)?APPInstance.token:@"" forKey:@"token"];
//    [dict setObject:isNotEmptyValue(APPInstance.user_id)?APPInstance.user_id:@"" forKey:@"uid"];
//    [dict setObject:KVersion forKey:@"version"];

    responseCallback(dict);
}

// --获取AuthCode
- (void)airportAuthCode:(id )data callBack:(WVJBResponseCallback)responseCallback {
    
}

// 添加toast
- (void)airportToast:(NSDictionary *)data callBack:(WVJBResponseCallback)responseCallback {
    
}


// 打开定位权限
- (void)airportLocationpPermissions:(NSDictionary *)data callBack:(WVJBResponseCallback)responseCallback {

}

- (void)applicationDidBecomeActive:(NSNotification *)notification {

}

// 开启或关闭ios webview Bounces效果
- (void)airportIosBounces:(NSDictionary *)data callBack:(WVJBResponseCallback)responseCallback {
    
}

// 埋点事件统计
- (void)airportUbtEvent:(NSDictionary *)data callBack:(WVJBResponseCallback)responseCallback {

}

// 埋点进入页面
- (void)airportUbtPageIn:(NSDictionary *)data callBack:(WVJBResponseCallback)responseCallback {

}

// 埋点离开页面
- (void)airportUbtPageOut:(NSDictionary *)data callBack:(WVJBResponseCallback)responseCallback {

}

// 获取当前机场信息
- (void)airportUserAirportInfo:(NSDictionary *)data callBack:(WVJBResponseCallback)responseCallback {
}

// loading展示和关闭
- (void)airportLoading:(NSDictionary *)data callBack:(WVJBResponseCallback)responseCallback {
    NSInteger showFlag = [data[@"show"] intValue];
    if (showFlag == 1) { //开启
        [self showHUD];
        responseCallback(@{@"result":@(true)});
    } else if (showFlag == 2) { // 关闭
        [self hideAllHUD];
        responseCallback(@{@"result":@(true)});
    }
}

#pragma mark 私有方法
// 注册OC方法给JS调用
- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    [self.bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
        handler(data, responseCallback);
    }];
}

// 设置状态栏背景颜色
- (void)setStatusBarBackgroundColor:(NSString *)colorStr {
   
}

- (void)setResponseCallback:(WVJBResponseCallback)responseCallback {

}


@end
