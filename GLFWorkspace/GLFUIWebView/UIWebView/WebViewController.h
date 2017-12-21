//
//  WebViewController.h
//  UIWebView
//
//  Created by guolongfei on 2017/10/27.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : BaseViewController

// 1 健康大本营
// 2 城市令家庭医生 居民端
// 3 健康1+1家庭医生 医生端
@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, strong) NSString *urlStr;

@end
