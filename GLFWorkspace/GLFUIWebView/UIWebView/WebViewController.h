//
//  WebViewController.h
//  UIWebView
//
//  Created by guolongfei on 2017/10/27.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : BaseViewController

// 1 城市令扫码信息
// 2 医生端账号密码
@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, strong) NSString *urlStr;

@end
