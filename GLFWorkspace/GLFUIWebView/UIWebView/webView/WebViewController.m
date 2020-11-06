//
//  WebViewController.m
//  UIWebView
//
//  Created by guolongfei on 2017/10/27.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "WebViewController.h"
#import "WebViewController+RegisterHandler.h"

@interface WebViewController ()<UIWebViewDelegate>
{
    UIWebView *_webView;
    UIBarButtonItem *item1;
    UIBarButtonItem *item2;
    
    NSTimer *timer;
    NSInteger count;
}
@end

@implementation WebViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    item1 = [[UIBarButtonItem alloc] initWithTitle:@"W前进" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction1:)];
    item2 = [[UIBarButtonItem alloc] initWithTitle:@"W回退" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction2:)];
    self.navigationItem.rightBarButtonItems = @[item1, item2];
    self.canHiddenNaviBar = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naviBarChange:) name:@"NaviBarChange" object:nil];

    [self setWebView];
}

- (void)setWebView {
    CGRect rect = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tabbarHidden = [userDefaults objectForKey:kTabbarHidden];
    if (tabbarHidden.integerValue) {
        rect = CGRectMake(0, 20, kScreenWidth, kScreenHeight-20);
    }

    NSString *isHaveBridge = [userDefaults objectForKey:kHaveBridge];
    if (isHaveBridge.integerValue) {
        [self setWebView1:rect];
    } else {
        [self setWebView2:rect];
    }
}

- (void)setWebView1:(CGRect)rect {
    _webView = [[UIWebView alloc] initWithFrame:rect];
    _webView.dataDetectorTypes = UIDataDetectorTypeAll; // 设定使电话号码、网址、电子邮件和符合格式的日期等文字变为链接文字
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    // Webview设置其UserAgent
//    NSString *userAgent = [NSString stringWithFormat:@"iskytrip_app signalBarHeight=%d", STATUSBAR_HEIGHT_X];
//    [_webView setValue:userAgent forKey:@"applicationNameForUserAgent"];
    
    NSString *sureStr;
    if ([self.urlStr containsString:@"?"]) {
        sureStr = [NSString stringWithFormat:@"%@&agent=iskytrip_app&signalBarHeight=%d&nativeLoading=1", self.urlStr, STATUSBAR_HEIGHT_X];
    } else {
        sureStr = [NSString stringWithFormat:@"%@?agent=iskytrip_app&signalBarHeight=%d&nativeLoading=1", self.urlStr, STATUSBAR_HEIGHT_X];
    }
    NSURL *url = [NSURL URLWithString:sureStr];
    // 加载请求的时候忽略缓存
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3.0];
    [_webView loadRequest:request];
    
    // Bridge
    [WebViewJavascriptBridge enableLogging];
    
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
    [self.bridge setWebViewDelegate:self];
    
    [self registerHandlers];
}

- (void)setWebView2:(CGRect)rect {
    _webView = [[UIWebView alloc] initWithFrame:rect];
    _webView.dataDetectorTypes = UIDataDetectorTypeAll; // 设定使电话号码、网址、电子邮件和符合格式的日期等文字变为链接文字
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    // Webview设置其UserAgent
//    NSString *userAgent = [NSString stringWithFormat:@"iskytrip_app signalBarHeight=%d", STATUSBAR_HEIGHT_X];
//    [_webView setValue:userAgent forKey:@"applicationNameForUserAgent"];
    
    NSString *sureStr;
    if ([self.urlStr containsString:@"?"]) {
        sureStr = [NSString stringWithFormat:@"%@&agent=iskytrip_app&signalBarHeight=%d&nativeLoading=1", self.urlStr, STATUSBAR_HEIGHT_X];
    } else {
        sureStr = [NSString stringWithFormat:@"%@?agent=iskytrip_app&signalBarHeight=%d&nativeLoading=1", self.urlStr, STATUSBAR_HEIGHT_X];
    }
    NSURL *url = [NSURL URLWithString:sureStr];
    // 加载请求的时候忽略缓存
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3.0];
    [_webView loadRequest:request];
}

- (void)buttonAction1:(id)sender {
    if (_webView.canGoForward) {
        [_webView goForward];
    }
}

- (void)buttonAction2:(id)sender {
    if (_webView.canGoBack) {
        [_webView goBack];
    }
}

- (void)naviBarChange:(NSNotification *)notify {
    NSDictionary *dict = notify.userInfo;
    if ([dict[@"isHidden"] isEqualToString: @"1"]) {
        _webView.frame = kScreen;
    } else {
        _webView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    }
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"路径: %@", request.URL.path);
    NSLog(@"完整的URL字符串: %@", request.URL.absoluteString);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
    [self showHUD];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
    [self hideAllHUD];
    [self setup:webView];
    [self setWebView:webView];
    
    // 定时器
    count = 0;
    timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"didFailLoadWithError: %@", error.localizedDescription);
    [self hideAllHUD];
    NSString *msg = [NSString stringWithFormat:@"加载失败: %@", error.localizedDescription];
    [self showStringHUD:msg second:3];
    [self setWebView:webView];
    
    // 定时器
    count = 0;
    timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

#pragma mark WebView Events
- (void)setup:(UIWebView *)webView {
    // 获取网页的title
    NSString *js = @"document.title";
    NSString *resultJS = [webView stringByEvaluatingJavaScriptFromString:js];
    self.title = resultJS;
    // 页面能否返回
    item1.enabled = webView.canGoForward;
    item2.enabled = webView.canGoBack;
    // 保存网址
    if (webView.canGoBack) {
        return; // 能返回,就表示不是第一个页面,就不必再保存了
    }
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    NSDictionary *dict = @{
        @"ipStr": self.urlStr,
        @"ipDescribe": self.title,
        @"isLastSelect": @"1"
    };
    [manager addURL:dict];
}

- (void)timerAction {
    if (count < 6) {
        [self setWebView:_webView];
    }
    count++;
}

- (void)setWebView:(UIWebView *)webView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isPlainText) {
            // 显示纯文本
            NSString *js1 = @"document.write(document.body.innerText)";
            [webView stringByEvaluatingJavaScriptFromString:js1];
            // 设置文本样式
            NSMutableString *js2 = [NSMutableString string];
            [js2 appendString:@"document.body.style.padding = '20px';"];
            [js2 appendString:@"document.body.style.whiteSpace = 'pre-line';"];
            [js2 appendString:@"document.body.style.fontSize = '48px';"];
            [js2 appendString:@"document.body.style.lineHeight = '64px';"];
            [js2 appendString:@"document.body.style.color = '#666';"];
            [webView stringByEvaluatingJavaScriptFromString:js2];
        } else {
            NSMutableString *js = [NSMutableString string];
            if (self.isHiddenXuanFu) {
                // 删除页面上的广告悬浮框
                [js appendString:@"var array1 = document.getElementsByTagName('div');"];
                [js appendString:@"for(var i=0; i<array1.length; i++) {"];
                [js appendString:@"    var element = array1[i];"];
                [js appendString:@"    if (element.style.zIndex>0 || element.style.position=='fixed') {"];
                [js appendString:@"        element.remove();"];
                [js appendString:@"    }"];
                [js appendString:@"}"];
            }
            if (self.isHiddenImage) {
                // 隐藏所有图片
                [js appendString:@"var array2 = document.getElementsByTagName('img');"];
                [js appendString:@"for (var i = 0; i < array2.length; i++) {"];
                [js appendString:@"    var element = array2[i];"];
                [js appendString:@"    element.remove();"];
                [js appendString:@"}"];
            }
            [webView stringByEvaluatingJavaScriptFromString:js];
        }
        [self hideAllHUD];
    });
}



@end
