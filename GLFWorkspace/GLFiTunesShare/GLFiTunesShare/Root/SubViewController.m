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
        NSArray *array = [self.model.path componentsSeparatedByString:@"."];
        NSString *lowerType = [array.lastObject lowercaseString];
        if ([lowerType isEqualToString:@"webarchive"]) {
            NSData *plistData = [NSData dataWithContentsOfFile:self.model.path];
            NSString *error;
            NSPropertyListFormat format;
            NSMutableDictionary *plist;
            plist = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:plistData
                                                     mutabilityOption: NSPropertyListMutableContainersAndLeaves
                                                               format: &format
                                                     errorDescription: &error];
            if(plist) {
                NSLog(@"%@", plist.allKeys);
                NSDictionary *webMainResource = [plist objectForKey:@"WebMainResource"];
                NSData *webResourceData = [webMainResource objectForKey:@"WebResourceData"];
                NSString *htmlStr = [NSString stringWithUTF8String:[webResourceData bytes]];
                NSLog(@"%@", htmlStr);
                [self.myWebView loadHTMLString:htmlStr baseURL:nil];
                return;
            }
        }
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
//    [self hideAllHUD];
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
        if (border.integerValue) {
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
            // 设置viewport
//            [js appendString:@"var viewport = document.createElement('meta');"];
//            [js appendString:@"viewport.name = 'viewport';"];
//            [js appendString:@"viewport.content = 'width=device-width,initial-scale=1.0';"];
//            [js appendString:@"document.head.appendChild(viewport);"];
            // 内容距离边界一定距离
            [js appendString:@"document.body.style.padding = '20px';"];
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
            [webView stringByEvaluatingJavaScriptFromString:js];
        }
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
