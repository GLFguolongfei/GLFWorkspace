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
}
@end

@implementation WebViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"W前进" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction1:)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"W回退" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction2:)];
    self.navigationItem.rightBarButtonItems = @[item1, item2];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-64)];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    if (self.type == 1) {
//        _webView.scrollView.bounces = NO;
        _webView.scrollView.scrollEnabled = YES;
    } else if (self.type == 2) {
        _webView.scrollView.scrollEnabled = YES;
    } else if (self.type == 3) {
        _webView.scrollView.scrollEnabled = NO;
    }
    [self.view addSubview:_webView];
    
    NSURL *url = [NSURL URLWithString:self.urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
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
    [self showHUD];
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideAllHUD];
    NSLog(@"webViewDidFinishLoad");
    [self setup:webView];
    if (self.type == 1) {
        [self setHTMLInfo1:webView];
    } else if (self.type == 2) {
        [self setHTMLInfo2:webView];
    } else if (self.type == 3) {
        [self setHTMLAccount:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideAllHUD];
    NSLog(@"didFailLoadWithError: %@", error.localizedDescription);
}

#pragma mark WebView Events
- (void)setup:(UIWebView *)webView {
    // 获取网页的title
    NSString *js = @"document.title";
    NSString *resultJS = [webView stringByEvaluatingJavaScriptFromString:js];
    self.title = resultJS;
    // 页面能否返回
    UIBarButtonItem *item1 = self.navigationItem.rightBarButtonItems[0];
    UIBarButtonItem *item2 = self.navigationItem.rightBarButtonItems[1];
    item1.enabled = webView.canGoForward;
    item2.enabled = webView.canGoBack;
    // 保存
    if (webView.canGoBack) {
        return; // 能返回,就表示不是第一个页面,就不必再保存了
    }
    BOOL isSave = YES;
    NSArray *sandboxpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [sandboxpath objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"IP.plist"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    if (array == nil) {
        array = [[NSMutableArray alloc] init];
    } else {
        for (NSInteger i = 0; i < array.count; i++) {
            NSMutableDictionary *dict = array[i];
            if ([dict[@"ipStr"] isEqualToString:self.urlStr]) {
                isSave = NO;
                dict[@"isLastSelect"] = @"1";
            } else {
                dict[@"isLastSelect"] = @"0";
            }
            [array replaceObjectAtIndex:i withObject:dict];
        }
    }
    if (isSave) {
        NSDictionary *dict = @{@"ipStr": self.urlStr,
                               @"ipDescribe": self.title,
                               @"isLastSelect": @"1"
                               };
        [array addObject:dict];
        [array writeToFile:plistPath atomically:YES];
    } else {
        [array writeToFile:plistPath atomically:YES];
    }
    [self showStringHUD:@"已保存" second:1.5];
}

- (void)setHTMLInfo1:(UIWebView *)webView {
    // 设置扫码需要的信息
    NSDictionary *dict = @{
                           @"idCard" : @"34260119950409463",
                           @"isAuth" : @"1",
                           @"phoneNum" : @"18301930275",
                           @"source" : @"iOS",
                           @"userId" : @"2321a7ab-b0ef-4f20-b9e3-5fee45bd9143",
                           @"userName" : @"沈文华",
                           @"versionNumber" : @"2.0.1",
                           @"zjType" : @"1"
                           };
    NSString *str = [GLFTools dictionaryToJson:dict];
    NSString *jsStr = [NSString stringWithFormat:@"getUserInfo(%@)", str];
    [webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (void)setHTMLInfo2:(UIWebView *)webView {
    // 设置扫码需要的信息
//    NSDictionary *dict = @{
//                           @"idCard" : @"34260119950409463",
//                           @"isAuth" : @"1",
//                           @"phoneNum" : @"18301930275",
//                           @"source" : @"iOS",
//                           @"userId" : @"2321a7ab-b0ef-4f20-b9e3-5fee45bd9143",
//                           @"userName" : @"沈文华",
//                           @"versionNumber" : @"2.0.1",
//                           @"zjType" : @"1"
//                           };
    NSDictionary *dict = @{
                           @"idCard" : @"342426199304214611",
                           @"isAuth" : @"1",
                           @"phoneNum" : @"17681332329",
                           @"source" : @"iOS",
                           @"userId" : @"1cf14ff2d2164730a992a4af421eb63b",
                           @"userName" : @"汪磊",
                           @"versionNumber" : @"2.0.1",
                           @"zjType" : @"1"
                           };
    NSString *str = [GLFTools dictionaryToJson:dict];
    NSString *jsStr = [NSString stringWithFormat:@"getUserInfo(%@)", str];
    [webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (void)setHTMLAccount:(UIWebView *)webView {
    // 设置用户名和密码
    // 13955391593 陶月英 医师
    // 18055548068 唐荣刚 医师
    // 13955382578 朱培金 中心主任
    NSMutableString *js2 = [NSMutableString string];
    [js2 appendString:@"var abcuserName = document.getElementById('userName');"];
    [js2 appendString:@"var abcpassword = document.getElementById('password');"];
    [js2 appendString:@"abcuserName.value = '13955391593';"];
    [js2 appendString:@"abcpassword.value = '13955391593';"];
    [webView stringByEvaluatingJavaScriptFromString:js2];
}


@end