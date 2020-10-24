//
//  ProjectManager.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/6/20.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LoadCallBack) (void);

@interface ProjectManager : NSObject

HMSingletonH(ProjectManager)

@property (nonatomic, assign) NSString *loginType; // 1-首页 2-抖音页

#pragma mark 网络爬虫
+ (void)getNetworkDataTest;
+ (void)getNetworkData1:(NSInteger)start andEnd:(NSInteger)end; // NSURLConnection(视频)
+ (void)getNetworkData2:(NSInteger)start andEnd:(NSInteger)end; // AFHTTPSessionManager(视频)

#pragma mark 公司自动打卡
+ (void)iskytripLogin;

#pragma mark 其它
+ (void)calcData;

@end

NS_ASSUME_NONNULL_END
