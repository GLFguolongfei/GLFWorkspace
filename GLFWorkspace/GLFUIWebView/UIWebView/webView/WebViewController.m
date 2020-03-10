//
//  WebViewController.m
//  UIWebView
//
//  Created by guolongfei on 2017/10/27.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "WebViewController.h"

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
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-64)];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    NSURL *url = [NSURL URLWithString:self.urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 加载请求的时候忽略缓存
//    request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3.0];
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
    NSString *msg = [NSString stringWithFormat:@"页面加载失败: %@", error.localizedDescription];
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
    [self showStringHUD:@"已保存" second:1.5];
}


@end
