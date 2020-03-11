//
//  WebViewController+RegisterHandler.h
//  UIWebView
//
//  Created by guolongfei on 2020/3/11.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "WebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebViewController (RegisterHandler)

@property (nonatomic, strong) WVJBResponseCallback responseCallback;

- (void)registerHandlers;

@end

NS_ASSUME_NONNULL_END
