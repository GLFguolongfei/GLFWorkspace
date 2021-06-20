//
//  WebViewController.m
//  UIWebView
//
//  Created by guolongfei on 2017/10/27.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "WebViewController.h"
#import "WebViewController+RegisterHandler.h"

@interface WebViewController ()<UIWebViewDelegate, UIScrollViewDelegate>
{
    UIWebView *_webView;
    UIBarButtonItem *toolItem1;
    UIBarButtonItem *toolItem2;
    
    NSTimer *timer;
    NSInteger count; // 过滤次数
    NSInteger errorCount; // 加载失败次数
    
    NSString *isSameOriginPolicy;
    NSURL *currentURL;
    
    NSMutableArray *blackIPArray;
    
    CGPoint startContentOffset;
}
@end

@implementation WebViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(button5)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"黑名单" style:UIBarButtonItemStylePlain target:self action:@selector(button6)];
    self.navigationItem.rightBarButtonItems = @[item1, item2];
    self.view.backgroundColor = [UIColor whiteColor];
    self.canHiddenNaviBar = YES;
    self.canHiddenToolBar = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naviBarChange:) name:@"NaviBarChange" object:nil];

    [self setWebView];
    
    toolItem1 = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(button1)];
    toolItem2 = [[UIBarButtonItem alloc] initWithTitle:@"Forward" style:UIBarButtonItemStylePlain target:self action:@selector(button2)];
    UIBarButtonItem *toolItem3 = [[UIBarButtonItem alloc] initWithTitle:@"内容过滤" style:UIBarButtonItemStylePlain target:self action:@selector(button3)];
    UIBarButtonItem *toolItem4 = [[UIBarButtonItem alloc] initWithTitle:@"纯文本" style:UIBarButtonItemStylePlain target:self action:@selector(button4)];
    UIBarButtonItem *toolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]; // 特殊的一个,用来自动计算宽度
    self.toolbarItems = @[toolBarSpace, toolItem1, toolBarSpace, toolItem2, toolBarSpace, toolItem3, toolBarSpace, toolItem4, toolBarSpace];
    [self.navigationController setToolbarHidden:YES animated:YES];
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

#pragma mark Setup
- (void)setWebView {
    CGRect rect = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tabbarHidden = [userDefaults objectForKey:kNavigationBarHidden];
    if (tabbarHidden.integerValue) {
        rect = CGRectMake(0, 20, kScreenWidth, kScreenHeight-20);
    }

    NSString *isHaveBridge = [userDefaults objectForKey:kHaveBridge];
    if (isHaveBridge.integerValue) {
        [self setWebView1:rect];
    } else {
        [self setWebView2:rect];
    }
    
    // 轻扫手势
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] init];
    [swipeGesture addTarget:self action:@selector(swipeAction:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    _webView.userInteractionEnabled = YES;
    [_webView addGestureRecognizer:swipeGesture];
}

- (void)setWebView1:(CGRect)rect {
    _webView = [[UIWebView alloc] initWithFrame:rect];
    _webView.dataDetectorTypes = UIDataDetectorTypeAll; // 设定使电话号码、网址、电子邮件和符合格式的日期等文字变为链接文字
    _webView.scalesPageToFit = YES;
    _webView.allowsInlineMediaPlayback = YES; // 允许不全屏播放视频
    [_webView setKeyboardDisplayRequiresUserAction: NO]; // 设置iOS H5可以自动聚焦
    _webView.delegate = self;
    _webView.scrollView.delegate = self;
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
    _webView.allowsInlineMediaPlayback = YES; // 允许不全屏播放视频
    [_webView setKeyboardDisplayRequiresUserAction: NO]; // 设置iOS H5可以自动聚焦
    _webView.delegate = self;
    _webView.scrollView.delegate = self;
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
    [_webView stringByEvaluatingJavaScriptFromString:js1];
    // 设置文本样式
    NSMutableString *js2 = [NSMutableString string];
    [js2 appendString:@"document.body.style.padding = '1%';"];
    [js2 appendString:@"document.body.style.whiteSpace = 'pre-line';"];
    [js2 appendString:@"document.body.style.color = '#666666';"];
    [_webView stringByEvaluatingJavaScriptFromString:js2];
}

// 刷新
- (void)button5 {
    [_webView reload];
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
        _webView.frame = CGRectMake(0, 20, kScreenWidth, kScreenHeight-20);
    } else {
        _webView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    }
}

- (void)swipeAction:(UISwipeGestureRecognizer *)gesture {
    if(gesture.direction==UISwipeGestureRecognizerDirectionLeft){
        NSLog(@"轻扫手势: 向左");
        [self button1];
    } else if (gesture.direction==UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"轻扫手势: 向右");
        [self button2];
    }
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"路径: %@", request.URL.path);
    NSLog(@"完整的URL字符串: %@", request.URL.absoluteString);
    
    currentURL = request.URL;
    
    // 注意
    // 同源策略,暂时没有实现
    if (isSameOriginPolicy.integerValue) {

    }
    // 黑名单
    if ([blackIPArray containsObject:currentURL.host]) {
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
    [self showHUDsecond:5];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
    errorCount = 0;
    [self hideAllHUD];
    [self contentSetup];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"didFailLoadWithError: %@", error.localizedDescription);
    NSString *msg = [NSString stringWithFormat:@"加载失败: %@", error.localizedDescription];
    [self showStringHUD:msg second:2];
    if (errorCount < 3) {
        errorCount++;
        [webView reload];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    startContentOffset = scrollView.contentOffset;
}

// 在滚动的时候调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
    if (startContentOffset.y > scrollView.contentOffset.y) { // 向下滑动
        [self.navigationController setToolbarHidden:NO animated:YES];
    } else { // 向上滑动或不动
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

#pragma mark WebView Events
- (void)contentSetup {
    // 获取网页的title
    NSString *js = @"document.title";
    NSString *resultJS = [_webView stringByEvaluatingJavaScriptFromString:js];
    self.title = resultJS;
    // 页面能否返回
    toolItem1.enabled = _webView.canGoBack;
    toolItem2.enabled = _webView.canGoForward;
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
    if (count >= 3) {
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
    [_webView stringByEvaluatingJavaScriptFromString:js];
}


@end
