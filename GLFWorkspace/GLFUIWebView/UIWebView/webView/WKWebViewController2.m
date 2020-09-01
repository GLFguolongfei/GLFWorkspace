//
//  WKWebViewController2.m
//  UIWebView
//
//  Created by guolongfei on 2020/9/1.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "WKWebViewController2.h"
#import <WebKit/WebKit.h>

@interface WKWebViewController2 ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
{
    WKWebView *_wkWebView;
    UIProgressView *_progressView;
    UIBarButtonItem *item1;
    UIBarButtonItem *item2;
}
@end

@implementation WKWebViewController2


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    item1 = [[UIBarButtonItem alloc] initWithTitle:@"W前进" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction1:)];
    item2 = [[UIBarButtonItem alloc] initWithTitle:@"W回退" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction2:)];
    self.navigationItem.rightBarButtonItems = @[item1, item2];
    self.canHiddenNaviBar = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naviBarChange:) name:@"NaviBarChange" object:nil];

    [self setWKWebView];
    [self setUIProgressView];
    [self addObserver];
}

- (void)dealloc {
    // 注意移除,否则页面跳转会崩溃的
    [_wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)setWKWebView {
    CGRect rect = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tabbarHidden = [userDefaults objectForKey:@"tabbarHidden"];
    if (tabbarHidden.integerValue) {
        rect = kScreen;
    }
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.dataDetectorTypes = UIDataDetectorTypeAll; // 设定使电话号码、网址、电子邮件和符合格式的日期等文字变为链接文字
    config.allowsInlineMediaPlayback = YES; // 是否允许内联(YES)或使用本机全屏控制器(NO),默认是NO
    if (@available(iOS 10.0, *)) {
        config.mediaTypesRequiringUserActionForPlayback = NO;
    } else {
        config.mediaPlaybackRequiresUserAction = NO; // 把手动播放设置NO ios(8.0, 9.0)
    }

    _wkWebView = [[WKWebView alloc] initWithFrame:rect configuration:config];
    _wkWebView.UIDelegate = self;
    _wkWebView.navigationDelegate = self;
    [self.view addSubview:_wkWebView];
    
    NSURL *url = [NSURL URLWithString:self.urlStr];
    // 加载请求的时候忽略缓存
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3.0];
    [_wkWebView loadRequest:request];
}

- (void)setUIProgressView {
    CGRect rect = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tabbarHidden = [userDefaults objectForKey:@"tabbarHidden"];
    if (tabbarHidden.integerValue) {
        rect = kScreen;
    }
    _progressView = [[UIProgressView alloc] initWithFrame:rect];
    _progressView.progressViewStyle = UIProgressViewStyleDefault;
    _progressView.progressTintColor = [UIColor blueColor];  // 前景色
    _progressView.trackTintColor = [UIColor lightGrayColor];    // 背景色
    _progressView.progress = 0; // 进度默认为0 - 1
    [self.view addSubview:_progressView];
}

- (void)addObserver {
    // 通过监听estimatedProgress可以获取它的加载进度,还可以监听它的title,URL,loading
    [_wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)buttonAction1:(id)sender {
    if (_wkWebView.canGoForward) {
        [_wkWebView goForward];
    }
}

- (void)buttonAction2:(id)sender {
    if (_wkWebView.canGoBack) {
        [_wkWebView goBack];
    }
}

- (void)naviBarChange:(NSNotification *)notify {
    NSDictionary *dict = notify.userInfo;
    if ([dict[@"isHidden"] isEqualToString: @"1"]) {
        _wkWebView.frame = kScreen;
    } else {
        _wkWebView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    }
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"loading"]) {
        WKBackForwardList *backForwardList = _wkWebView.backForwardList;
        NSLog(@"loading: %@", backForwardList);
    } else if ([keyPath isEqualToString:@"title"]) {
        NSLog(@"title: %@", _wkWebView.title);
    } else if ([keyPath isEqualToString:@"URL"]) {
        NSLog(@"URL: %@", _wkWebView.URL);
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"estimatedProgress: %f", _wkWebView.estimatedProgress);
    }
    
    if (object == _wkWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            _progressView.hidden = YES;
            [_progressView setProgress:0 animated:NO];
        } else {
            _progressView.hidden = NO;
            [_progressView setProgress:newprogress animated:YES];
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
    [self setup:webView];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"4-页面加载失败");
    [self showStringHUD:@"页面加载失败" second:2];
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

#pragma mark WebView Events
- (void)setup:(WKWebView *)webView {
    // 获取网页的title
    NSString *js = @"document.title";
    [webView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            self.title = result;
        }
    }];
    // 页面能否返回
    item1.enabled = webView.canGoForward;
    item2.enabled = webView.canGoBack;
    // 保存网址
    if (webView.canGoBack) {
        return; // 能返回,就表示不是第一个页面,就不必再保存了
    }
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *dict = @{
            @"ipStr": self.urlStr,
            @"ipDescribe": self.title,
            @"isLastSelect": @"1"
        };
        [manager addURL:dict];
    });
}


@end
