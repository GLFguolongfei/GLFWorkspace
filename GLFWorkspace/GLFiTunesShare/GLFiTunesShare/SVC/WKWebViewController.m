//
//  WKWebViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/3/6.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>

@interface WKWebViewController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation WKWebViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setWKWebView];
    [self setUIProgressView];
    [self addObserver];
}

- (void)dealloc {
    // 注意移除,否则页面跳转会崩溃的
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)setWKWebView {
    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-64)];
    self.wkWebView.UIDelegate = self;
    self.wkWebView.navigationDelegate = self;
    [self.view addSubview:self.wkWebView];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"bd" ofType:@"webarchive"];
    NSURL *url = [NSURL URLWithString:filePath];
//    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.wkWebView loadRequest:request];
}

- (void)setUIProgressView {
    self.progressView = [[UIProgressView alloc] initWithFrame:self.view.frame];
    self.progressView.progressViewStyle = UIProgressViewStyleDefault;
    self.progressView.progressTintColor = [UIColor blueColor];  // 前景色
    self.progressView.trackTintColor = [UIColor lightGrayColor];    // 背景色
    self.progressView.progress = 0; // 进度默认为0 - 1
    [self.view addSubview:self.progressView];
}

- (void)addObserver {
    // 通过监听estimatedProgress可以获取它的加载进度,还可以监听它的title,URL,loading
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"loading"]) {
        WKBackForwardList *backForwardList = self.wkWebView.backForwardList;
        NSLog(@"loading: %@", backForwardList);
    } else if ([keyPath isEqualToString:@"title"]) {
        NSLog(@"title: %@", self.wkWebView.title);
    } else if ([keyPath isEqualToString:@"URL"]) {
        NSLog(@"URL: %@", self.wkWebView.URL);
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"estimatedProgress: %f", self.wkWebView.estimatedProgress);
    }
    
    if (object == self.wkWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        } else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}

#pragma mark WKUIDelegate
// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    return nil;
}

// 界面弹出警告框、确认框、输入框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"Web界面弹出警告框");
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    completionHandler(); // 注意: 不加这一句,当有弹框时就会崩溃
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(@"Web界面弹出确认框");
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *result))completionHandler {
    NSLog(@"Web界面弹出输入框");
}

#pragma mark WKNavigationDelegate
// 该代理提供的方法,用来追踪页面加载过程(开始加载、加载完成、加载失败)、决定是否执行跳转
#pragma mark 1-页面加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"1-页面开始加载");
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"2-页面开始返回");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"3-页面加载完成");
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"4-页面加载失败");
}

#pragma mark 2-页面跳转
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"接收到服务器跳转请求");
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"在发送请求之前,决定是否跳转");
    decisionHandler(WKNavigationActionPolicyAllow); // 允许跳转
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"在收到响应后,决定是否跳转");
    decisionHandler(WKNavigationResponsePolicyAllow); // 允许跳转
}

#pragma mark 3-未知
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

// 权限认证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

#pragma mark WKScriptMessageHandler
// 该代理提供一个必须实现的方法,这个方法是提高App与web端交互的关键,它可以直接将接收到的JS脚本转为OC或Swift对象
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"从web界面中接收到一个脚本时调用: %@", message);
}


@end
