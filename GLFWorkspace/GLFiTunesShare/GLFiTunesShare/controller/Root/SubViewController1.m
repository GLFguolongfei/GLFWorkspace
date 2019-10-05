//
//  SubViewController1.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2019/10/5.
//  Copyright © 2019 GuoLongfei. All rights reserved.
//

#import "SubViewController1.h"
#import <WebKit/WebKit.h>

@interface SubViewController1 ()<WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;

@end

@implementation SubViewController1


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame];
    self.wkWebView.UIDelegate = self;
    self.wkWebView.navigationDelegate = self;
    [self.view addSubview:self.wkWebView];
    
    NSURL *url = [NSURL fileURLWithPath:self.model.path];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.wkWebView loadRequest:request];
}


@end
