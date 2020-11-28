//
//  WKWebViewController.m
//  UIWebView
//
//  Created by guolongfei on 2020/3/9.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>
#import "WKWebViewController+RegisterHandler.h"

@interface WKWebViewController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
{
    WKWebView *_wkWebView;
    UIProgressView *_progressView;
    UIBarButtonItem *item1;
    UIBarButtonItem *item2;

    NSTimer *timer;
    NSInteger count; // 过滤次数
    NSInteger errorCount; // 加载失败次数
    
    NSString *isSameOriginPolicy;
    NSURL *currentURL;
    
    NSMutableArray *blackIPArray;
}
@end

@implementation WKWebViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(button5)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"黑名单" style:UIBarButtonItemStylePlain target:self action:@selector(button6)];
    self.navigationItem.rightBarButtonItems = @[item1, item2];
    self.view.backgroundColor = [UIColor whiteColor];
    self.canHiddenNaviBar = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naviBarChange:) name:@"NaviBarChange" object:nil];

    [self setWKWebView];
    [self setUIProgressView];
    [self addObserver];
    
    item1 = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(button1)];
    item2 = [[UIBarButtonItem alloc] initWithTitle:@"Forward" style:UIBarButtonItemStylePlain target:self action:@selector(button2)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"内容过滤" style:UIBarButtonItemStylePlain target:self action:@selector(button3)];
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithTitle:@"纯文本" style:UIBarButtonItemStylePlain target:self action:@selector(button4)];
    UIBarButtonItem *toolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]; // 特殊的一个,用来自动计算宽度
    self.toolbarItems = @[toolBarSpace, item1, toolBarSpace, item2, toolBarSpace, item3, toolBarSpace, item4, toolBarSpace];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    isSameOriginPolicy = [userDefaults objectForKey:kSameOriginPolicy];
    
    NSArray *sandboxpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [sandboxpath objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"IPBlack.plist"];
    blackIPArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    if (blackIPArray == nil) {
        blackIPArray = [[NSMutableArray alloc] init];
    }
}

- (void)dealloc {
    // 注意移除,否则页面跳转会崩溃的
    [_wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)setWKWebView {
    CGRect rect = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tabbarHidden = [userDefaults objectForKey:kTabbarHidden];
    if (tabbarHidden.integerValue) {
        rect = CGRectMake(0, 20, kScreenWidth, kScreenHeight-20);
    }
    
    NSString *isHaveBridge = [userDefaults objectForKey:kHaveBridge];
    if (isHaveBridge.integerValue) {
        [self setWKWebView1:rect];
    } else {
        [self setWKWebView2:rect];
    }
}

- (void)setWKWebView1:(CGRect)rect {
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
    
    // WKWebview设置其UserAgent
    NSString *userAgent = [NSString stringWithFormat:@"iskytrip_app signalBarHeight=%d", STATUSBAR_HEIGHT_X];
    [_wkWebView setValue:userAgent forKey:@"applicationNameForUserAgent"];
    
    NSString *sureStr;
    if ([self.urlStr containsString:@"?"]) {
        sureStr = [NSString stringWithFormat:@"%@&agent=iskytrip_app&signalBarHeight=%d&nativeLoading=1", self.urlStr, STATUSBAR_HEIGHT_X];
    } else {
        sureStr = [NSString stringWithFormat:@"%@?agent=iskytrip_app&signalBarHeight=%d&nativeLoading=1", self.urlStr, STATUSBAR_HEIGHT_X];
    }
    NSURL *url = [NSURL URLWithString:sureStr];
    // 加载请求的时候忽略缓存
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3.0];
    [_wkWebView loadRequest:request];
    
    // Bridge
    [WKWebViewJavascriptBridge enableLogging];
    
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:_wkWebView];
    [self.bridge setWebViewDelegate:self];
    
    [self registerHandlers];
}

- (void)setWKWebView2:(CGRect)rect {
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
    NSString *tabbarHidden = [userDefaults objectForKey:kTabbarHidden];
    if (tabbarHidden.integerValue) {
        rect = CGRectMake(0, 20, kScreenWidth, kScreenHeight-20);
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

#pragma mark Events
// 回退
- (void)button1 {
    if (_wkWebView.canGoBack) {
        [_wkWebView goBack];
    }
}

// 前进
- (void)button2 {
    if (_wkWebView.canGoForward) {
        [_wkWebView goForward];
    }
}

// 清空广告、图片
- (void)button3 {
    count = 0;
    timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(contentFilter) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

// 纯文本
- (void)button4 {
    // 显示纯文本
    NSString *js1 = @"document.write(document.body.innerText)";
    [_wkWebView evaluateJavaScript:js1 completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            self.title = result;
        }
    }];
    // 设置文本样式
    NSMutableString *js2 = [NSMutableString string];
    [js2 appendString:@"document.body.style.padding = '1%';"];
    [js2 appendString:@"document.body.style.whiteSpace = 'pre-line';"];
    [js2 appendString:@"document.body.style.color = '#666666';"];
    [_wkWebView evaluateJavaScript:js2 completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            self.title = result;
        }
    }];
}

// 刷新
- (void)button5 {
    [_wkWebView reload];
}

// 黑名单
- (void)button6 {
    NSString *str = [NSString stringWithFormat:@"确定将当前站点 [%@] 加入黑名单？", currentURL.host];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:str preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertVC addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSArray *sandboxpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [sandboxpath objectAtIndex:0];
        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"IPBlack.plist"];
        NSMutableArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
        BOOL isHaveSave = NO;
        if (array == nil) {
            array = [[NSMutableArray alloc] init];
        } else {
            for (NSInteger i = 0; i < array.count; i++) {
                NSString *host = array[i];
                if ([host isEqualToString:currentURL.host]) {
                    isHaveSave = YES;
                }
            }
        }
        if (!isHaveSave) {
            [blackIPArray addObject:currentURL.host];
            [array addObject:currentURL.host];
            [array writeToFile:plistPath atomically:YES];
        }
    }];
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
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
    [self contentSetup];
    errorCount = 0;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"4-页面加载失败");
    [self showStringHUD:@"页面加载失败" second:2];
    if (errorCount < 3) {
        errorCount++;
        [webView reload];
    }
}

#pragma mark 2-页面跳转
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"接收到服务器跳转请求");
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"在发送请求之前,决定是否跳转");
    
    currentURL = webView.URL;

    // 注意
    // 同源策略,暂时没有实现
    if (isSameOriginPolicy.integerValue) {

    }
    // 黑名单
    if ([blackIPArray containsObject:currentURL.host]) {
        decisionHandler(WKNavigationActionPolicyCancel); // 禁止跳转
        return;
    }
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
- (void)contentSetup {
    // 获取网页的title
    NSString *js = @"document.title";
    [_wkWebView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            self.title = result;
        }
    }];
    // 页面能否返回
    item1.enabled = _wkWebView.canGoForward;
    item2.enabled = _wkWebView.canGoBack;
    // 保存网址
    if (_wkWebView.canGoBack) {
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

- (void)contentFilter {
    if (count > 3) {
        [timer invalidate];
        timer = nil;
        return;
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
    [_wkWebView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            self.title = result;
        }
    }];
}


@end
