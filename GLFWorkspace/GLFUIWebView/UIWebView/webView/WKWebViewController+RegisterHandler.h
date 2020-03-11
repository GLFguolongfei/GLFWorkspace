//
//  WKWebViewController+RegisterHandler.h
//  UIWebView
//
//  Created by guolongfei on 2020/3/11.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "WKWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewController (RegisterHandler)

@property (nonatomic, strong) WVJBResponseCallback responseCallback;

- (void)registerHandlers;

@end

NS_ASSUME_NONNULL_END
