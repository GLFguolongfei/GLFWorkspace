//
//  WKWebViewController.h
//  UIWebView
//
//  Created by guolongfei on 2020/3/9.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewController : BaseViewController

@property(nonatomic, strong) WKWebViewJavascriptBridge *bridge;

@property (nonatomic, strong) NSString *urlStr;

@end

NS_ASSUME_NONNULL_END
