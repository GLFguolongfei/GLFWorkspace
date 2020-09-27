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
}
@end

@implementation WebViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
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
        rect = kScreen;
    }
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
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"didFailLoadWithError: %@", error.localizedDescription);
    [self hideAllHUD];
    NSString *msg = [NSString stringWithFormat:@"加载失败: %@", error.localizedDescription];
    [self showStringHUD:msg second:3];
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


@end
