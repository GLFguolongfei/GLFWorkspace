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
    [self hideAllHUD];
    NSLog(@"webViewDidFinishLoad");
    [self setWebView:webView];
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
            [js appendString:@"var mmmDivArray = document.getElementsByTagName('div');"];
            [js appendString:@"for(var i=0;i<mmmDivArray.length;i++) {"];
            [js appendString:@"    var element = mmmDivArray[i];"];
            [js appendString:@"    if (element.style.zIndex>0 || element.style.position=='fixed') {"];
            [js appendString:@"        element.style.display = 'none';"];
            [js appendString:@"    }"];
            [js appendString:@"}"];
        }
        if (img.integerValue) {
            // 隐藏所有图片
            [js appendString:@"var mmmImgArray = document.getElementsByTagName('img');"];
            [js appendString:@"for (var i = 0; i < mmmImgArray.length; i++) {"];
            [js appendString:@"    var element = mmmImgArray[i];"];
            [js appendString:@"    element.style.display = 'none';"];
            [js appendString:@"}"];
        }
        if (font.integerValue) {
            // div标签字体大小
            [js appendString:@"var nnnDivArray = document.getElementsByTagName('div');"];
            [js appendString:@"for(var i=0;i<nnnDivArray.length;i++) {"];
            [js appendString:@"    var element = nnnDivArray[i];"];
            [js appendString:@"    if (element.style.fontSize < 28) {"];
            [js appendString:@"        element.style.fontSize = '28px';"];
            [js appendString:@"        element.style.lineHeight = '40px';"];
            [js appendString:@"    } else {"];
            [js appendString:@"        element.style.fontSize = '32px';"];
            [js appendString:@"        element.style.lineHeight = '45px';"];
            [js appendString:@"    }"];
            [js appendString:@"}"];
            // p标签字体变大
            [js appendString:@"var mmmPArray = document.getElementsByTagName('p');"];
            [js appendString:@"for (var i = 0; i < mmmPArray.length; i++) {"];
            [js appendString:@"    var element = mmmPArray[i];"];
            [js appendString:@"    if (element.style.fontSize < 28) {"];
            [js appendString:@"        element.style.fontSize = '28px';"];
            [js appendString:@"        element.style.lineHeight = '40px';"];
            [js appendString:@"    } else {"];
            [js appendString:@"        element.style.fontSize = '32px';"];
            [js appendString:@"        element.style.lineHeight = '45px';"];
            [js appendString:@"    }"];
            [js appendString:@"}"];
        }
        if (border.integerValue) {
            // 内容距离边界一定距离
            [js appendString:@"document.body.style.padding = '20px';"];
        }
        [webView stringByEvaluatingJavaScriptFromString:js];
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
