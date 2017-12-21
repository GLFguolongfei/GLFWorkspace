//
//  IpModel.h
//  UIWebView
//
//  Created by guolongfei on 2017/12/8.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IpModel : NSObject

@property (nonatomic, copy) NSString *ipStr;
@property (nonatomic, copy) NSString *ipDescribe;
@property (nonatomic, assign) BOOL isLastSelect;

@end
