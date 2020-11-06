//
//  WKWebViewController.h
//  UIWebView
//
//  Created by guolongfei on 2020/3/9.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 有Bridge
@interface WKWebViewController : BaseViewController

@property(nonatomic, strong) WKWebViewJavascriptBridge *bridge;

@property (nonatomic, strong) NSString *urlStr;

@property (nonatomic, assign) BOOL isHiddenXuanFu; // 是否隐藏广告
@property (nonatomic, assign) BOOL isHiddenImage; // 是否隐藏图片
@property (nonatomic, assign) BOOL isPlainText; // 是否纯文本

@end

NS_ASSUME_NONNULL_END
