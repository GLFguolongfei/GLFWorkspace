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
    UIBarButtonItem *filterItem;
    
    BOOL isFilter;
    NSTimer *timer;
    NSInteger count;
}
@end

@implementation WebViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    filterItem = [[UIBarButtonItem alloc] initWithTitle:@"内容未过滤" style:UIBarButtonItemStylePlain target:self action:@selector(button5)];
    self.navigationItem.rightBarButtonItem = filterItem;
    self.view.backgroundColor = [UIColor whiteColor];
    self.canHiddenNaviBar = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naviBarChange:) name:@"NaviBarChange" object:nil];

    [self setWebView];
    
    item1 = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(button1)];
    item2 = [[UIBarButtonItem alloc] initWithTitle:@"Forward" style:UIBarButtonItemStylePlain target:self action:@selector(button2)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(button3)];
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithTitle:@"纯文本" style:UIBarButtonItemStylePlain target:self action:@selector(button4)];
    UIBarButtonItem *toolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]; // 特殊的一个,用来自动计算宽度
    self.toolbarItems = @[toolBarSpace, item1, toolBarSpace, item2, toolBarSpace, item3, toolBarSpace, item4, toolBarSpace];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

#pragma mark Setup
- (void)setWebView {
    CGRect rect = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64-49);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tabbarHidden = [userDefaults objectForKey:kTabbarHidden];
    if (tabbarHidden.integerValue) {
        rect = CGRectMake(0, 20, kScreenWidth, kScreenHeight-20-49);
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

#pragma mark Events
// 回退
- (void)button1 {
    if (_webView.canGoBack) {
        [_webView goBack];
    }
}

// 前进
- (void)button2 {
    if (_webView.canGoForward) {
        [_webView goForward];
    }
}

// 刷新
- (void)button3 {
    [_webView reload];
}

// 纯文本
- (void)button4 {
    // 显示纯文本
    NSString *js1 = @"document.write(document.body.innerText)";
    [_webView stringByEvaluatingJavaScriptFromString:js1];
    // 设置文本样式
    NSMutableString *js2 = [NSMutableString string];
    [js2 appendString:@"document.body.style.padding = '1%';"];
    [js2 appendString:@"document.body.style.whiteSpace = 'pre-line';"];
    [_webView stringByEvaluatingJavaScriptFromString:js2];
}

// 清空广告
- (void)button5 {
    isFilter = !isFilter;
    [_webView reload];
    if (isFilter) {
        [filterItem setTitle:@"内容已过滤"];
    } else {
        [filterItem setTitle:@"内容未过滤"];
    }
}

- (void)naviBarChange:(NSNotification *)notify {
    NSDictionary *dict = notify.userInfo;
    if ([dict[@"isHidden"] isEqualToString: @"1"]) {
        _webView.frame = CGRectMake(0, 20, kScreenWidth, kScreenHeight-20-49);
    } else {
        _webView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64-49);
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
    [self contentSetup];
    if (isFilter) {
        timer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(contentFilter) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"didFailLoadWithError: %@", error.localizedDescription);
    [self hideAllHUD];
    NSString *msg = [NSString stringWithFormat:@"加载失败: %@", error.localizedDescription];
    [self showStringHUD:msg second:3];
}

#pragma mark WebView Events
- (void)contentSetup {
    // 获取网页的title
    NSString *js = @"document.title";
    NSString *resultJS = [_webView stringByEvaluatingJavaScriptFromString:js];
    self.title = resultJS;
    // 页面能否返回
    item1.enabled = _webView.canGoBack;
    item2.enabled = _webView.canGoForward;
    // 保存网址
    if (_webView.canGoBack) {
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

- (void)contentFilter {
    if (count > 6) {
        [timer invalidate];
        timer = nil;
    } else {
        count++;
    }
    NSMutableString *js = [NSMutableString string];
    // 删除页面上的广告悬浮框
    [js appendString:@"var array1 = document.getElementsByTagName('div');"];
    [js appendString:@"for(var i=0; i<array1.length; i++) {"];
    [js appendString:@"    var element = array1[i];"];
    [js appendString:@"    if (element.style.zIndex>0 || element.style.position=='fixed') {"];
    [js appendString:@"        element.remove();"];
    [js appendString:@"    }"];
    [js appendString:@"}"];
    // 隐藏所有图片
    [js appendString:@"var array2 = document.getElementsByTagName('img');"];
    [js appendString:@"for (var i = 0; i < array2.length; i++) {"];
    [js appendString:@"    var element = array2[i];"];
    [js appendString:@"    element.remove();"];
    [js appendString:@"}"];
    [_webView stringByEvaluatingJavaScriptFromString:js];
}


@end
