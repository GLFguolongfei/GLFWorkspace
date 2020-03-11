//
//  WebViewController.h
//  UIWebView
//
//  Created by guolongfei on 2017/10/27.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : BaseViewController

@property(nonatomic, strong) WebViewJavascriptBridge *bridge;

@property (nonatomic, strong) NSString *urlStr;

@end
