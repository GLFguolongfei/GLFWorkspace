//
//  NetworkManager.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/6/14.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkManager : NSObject

HMSingletonH(NetworkManager)

#pragma mark 网络爬虫
+ (void)getNetworkData1;
+ (void)getNetworkData2;
+ (void)getNetworkDataTest;

#pragma mark 公司自动打卡
+ (void)iskytripLogin;

@end

NS_ASSUME_NONNULL_END
