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
// 网络爬虫
@property (nonatomic, copy) NSMutableArray *resultArray;
@property (nonatomic, assign) NSInteger endIndex;

#pragma mark 网络爬虫
+ (void)getNetworkDataTest;
+ (void)getNetworkData:(NSInteger)index andType:(NSInteger)type;
+ (void)getNetworkData1:(NSInteger)start andPageCount:(NSInteger)pageCount andFinish:(LoadFinishCallBack)callBack; // NSURLConnection(视频)
+ (void)getNetworkData2:(NSInteger)start andPageCount:(NSInteger)pageCount andFinish:(LoadFinishCallBack)callBack; // AFHTTPSessionManager(视频)

#pragma mark 公司自动打卡
+ (void)iskytripLogin;

#pragma mark 其它
+ (void)calcData;

@end

NS_ASSUME_NONNULL_END
