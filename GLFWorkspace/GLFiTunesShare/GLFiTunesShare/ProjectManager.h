//
//  ProjectManager.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/6/20.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProjectManager : NSObject

HMSingletonH(ProjectManager)

@property (nonatomic, assign) NSString *loginType; // 1-首页 2-抖音页

#pragma mark 网络爬虫
+ (void)getNetworkDataTest;
// NSURLConnection
+ (void)getNetworkData1;
// AFHTTPSessionManager
+ (void)getNetworkData2;

#pragma mark 公司自动打卡
+ (void)iskytripLogin;

#pragma mark 其它
+ (void)calcData;

@end

NS_ASSUME_NONNULL_END
