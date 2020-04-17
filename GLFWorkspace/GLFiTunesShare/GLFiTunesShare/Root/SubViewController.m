//
//  SubViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/10/6.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "SubViewController.h"

@interface SubViewController ()<UIWebViewDelegate>

@end

@implementation SubViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-64)];
    self.myWebView.scalesPageToFit = YES;
    self.myWebView.delegate = self;
    [self.view addSubview:self.myWebView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    @try {
        // 加载本地资源
        NSURL *url = [NSURL fileURLWithPath:self.model.path];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.myWebView loadRequest:request];
    }
    @catch (NSException *exception) { // 捕获抛出的异常
        NSLog(@"exception.name = %@", exception.name);
        NSLog(@"exception.reason = %@", exception.reason);
        NSLog(@"exception.userInfo = %@", exception.userInfo);
    }
    @finally {
        NSLog(@"finally!");
    }
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // URL格式: 协议头://主机名/路径
    NSLog(@"路径: %@", request.URL.path);
    NSLog(@"完整的URL字符串: %@", request.URL.absoluteString);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self showHUDsecond:10];
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self setWebView:webView];
//    [self hideAllHUD];
    NSLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideAllHUD];
    NSLog(@"didFailLoadWithError: %@", error.localizedDescription);
    [self setWebView:webView andError:error];
}

#pragma mark WebView Events
- (void)setWebView:(UIWebView *)webView {
    if (self.backEnableBlock) {
        self.backEnableBlock(webView.canGoBack);
    }
    if (self.forwardEnableBlock) {
        self.forwardEnableBlock(webView.canGoForward);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *xuanfu = [userDefaults objectForKey:kWebContentXuanFu];
        NSString *img = [userDefaults objectForKey:kWebContentImg];
        NSString *font = [userDefaults objectForKey:kWebContentFont];
        NSString *border = [userDefaults objectForKey:kWebContentBorder];
        NSMutableString *js = [NSMutableString string];
        if (xuanfu.integerValue) {
            // 删除页面上的广告悬浮框
            [js appendString:@"var array1 = document.getElementsByTagName('div');"];
            [js appendString:@"for(var i=0; i<array1.length; i++) {"];
            [js appendString:@"    var element = array1[i];"];
            [js appendString:@"    if (element.style.zIndex>0 || element.style.position=='fixed') {"];
            [js appendString:@"        element.remove();"];
            [js appendString:@"    }"];
            [js appendString:@"}"];
        }
        if (img.integerValue) {
            // 隐藏所有图片
            [js appendString:@"var array2 = document.getElementsByTagName('img');"];
            [js appendString:@"for (var i = 0; i < array2.length; i++) {"];
            [js appendString:@"    var element = array2[i];"];
            [js appendString:@"    element.remove();"];
            [js appendString:@"}"];
        }
        if (font.integerValue) {
            // div标签字体大小
            [js appendString:@"var array3 = document.getElementsByTagName('div') || [];"];
            [js appendString:@"var array4 = document.getElementsByTagName('span') || [];"];
            [js appendString:@"var array5 = document.getElementsByTagName('p') || [];"];
            [js appendString:@"var array6 = document.getElementsByTagName('a') || [];"];
            [js appendString:@"console.log(array3);"];
            [js appendString:@"for(var i=0; i<array3.length;i++) {"];
            [js appendString:@"    var element = array3[i];"];
            [js appendString:@"    if (element.innerText == '') {"];
            [js appendString:@"        element.remove();"];
            [js appendString:@"    } else {"];
            [js appendString:@"        element.style.display = 'inline-block';"];
            [js appendString:@"    }"];
            [js appendString:@"    element.style.fontSize = '48px';"];
            [js appendString:@"    element.style.lineHeight = '64px';"];
            [js appendString:@"    element.style.width = '100%';"];
            [js appendString:@"}"];
            [js appendString:@"for(var i=0; i<array4.length;i++) {"];
            [js appendString:@"    var element = array4[i];"];
            [js appendString:@"    if (element.innerText == '') {"];
            [js appendString:@"        element.remove();"];
            [js appendString:@"    } else {"];
            [js appendString:@"        element.style.display = 'inline-block';"];
            [js appendString:@"    }"];
            [js appendString:@"    element.style.fontSize = '48px';"];
            [js appendString:@"    element.style.lineHeight = '64px';"];
            [js appendString:@"    element.style.width = '100%';"];
            [js appendString:@"}"];
            [js appendString:@"for(var i=0; i<array5.length;i++) {"];
            [js appendString:@"    var element = array5[i];"];
            [js appendString:@"    if (element.innerText == '') {"];
            [js appendString:@"        element.remove();"];
            [js appendString:@"    } else {"];
            [js appendString:@"        element.style.display = 'inline-block';"];
            [js appendString:@"    }"];
            [js appendString:@"    element.style.fontSize = '48px';"];
            [js appendString:@"    element.style.lineHeight = '64px';"];
            [js appendString:@"    element.style.width = '100%';"];
            [js appendString:@"}"];
            [js appendString:@"for(var i=0; i<array6.length;i++) {"];
            [js appendString:@"    var element = array6[i];"];
            [js appendString:@"    if (element.innerText == '') {"];
            [js appendString:@"        element.remove();"];
            [js appendString:@"    } else {"];
            [js appendString:@"        element.style.display = 'inline-block';"];
            [js appendString:@"    }"];
            [js appendString:@"    element.style.fontSize = '48px';"];
            [js appendString:@"    element.style.lineHeight = '64px';"];
            [js appendString:@"    element.style.width = '100%';"];
            [js appendString:@"}"];
        }
        if (border.integerValue) {
            // 内容距离边界一定距离
            [js appendString:@"document.body.style.padding = '20px';"];
        }
        
//        [js appendString:@"var viewport = document.createElement('meta');"];
//        [js appendString:@"viewport.name = 'viewport';"];
//        [js appendString:@"viewport.content = 'width=device-width,initial-scale=1.0';"];
//        [js appendString:@"document.head.appendChild(viewport);"];
        
        [webView stringByEvaluatingJavaScriptFromString:js];
        [self hideAllHUD];
    });
}

- (void)setWebView:(UIWebView *)webView andError:(NSError *)error {
    if ([error.domain isEqualToString:@"NSURLErrorDomain"] && error.code == NSURLErrorCancelled) {
        NSLog(@"Canceled request: %@", webView.request.URL);
        return;
    } else if ([error.domain isEqualToString:@"WebKitErrorDomain"] && (error.code == 102 || error.code == 204)) {
        NSLog(@"ignore: %@", error);
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"didFailLoadWithError" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancel];
    UIAlertAction *destructAction = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (self.backBlock) {
            self.backBlock();
        }
    }];
    [alertVC addAction:destructAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}


@end
