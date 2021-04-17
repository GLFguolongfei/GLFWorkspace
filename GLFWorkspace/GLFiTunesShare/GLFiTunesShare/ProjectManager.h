//
//  ProjectManager.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/6/20.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LoadFinishCallBack) (void);

@interface ProjectManager : NSObject

HMSingletonH(ProjectManager)

// 1-正规登陆（进入首页） 2-密码登陆（进入抖音页） 3-免密登陆（进入首页）
@property (nonatomic, assign) NSString *loginType;

#pragma mark 网络爬虫
- (void)getNetworkDataTest:(NSString *)urlString;
- (void)getNetworkData:(NSInteger)type;
- (void)getNetworkDataRepeat; // 补救请求失败
- (void)getNetworkData1:(LoadFinishCallBack)callBack; // NSURLConnection(视频)
- (void)getNetworkData2:(LoadFinishCallBack)callBack; // AFHTTPSessionManager(视频)

#pragma mark 公司自动打卡
+ (void)iskytripLogin;

@end

NS_ASSUME_NONNULL_END
