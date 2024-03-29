//
//  ViewController.m
//  UIWebView
//
//  Created by guolongfei on 2017/10/27.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>
// VCs
#import "WebViewController.h"
#import "WKWebViewController.h"
#import "SetupViewController.h"
#import "MMScanViewController.h"
// Views
#import "SelectIPView.h"
#import "BlackIPView.h"
// Tools
#import "LewPopupViewController.h"

@interface ViewController ()<UITextViewDelegate,SFSafariViewControllerDelegate>
{
    UIImageView *bgImageView;
    NSString *currentUrlStr;
}
@end

@implementation ViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"HTML5";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(declareAction)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"扫码" style:UIBarButtonItemStylePlain target:self action:@selector(scanQrCode)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    // 设置背景图片(加上图片不好看思密达)
    bgImageView = [[UIImageView alloc] initWithFrame:kScreen];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.image = [UIImage imageNamed:@"bg3"];
    [self.view addSubview:bgImageView];
    
    // 输入框
    CGRect textViewRect = CGRectMake(15, 80, kScreenWidth-30, 100);
    self.ipTextView = [[UITextView alloc] initWithFrame:textViewRect];
    self.ipTextView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
    self.ipTextView.layer.cornerRadius = 5;
    self.ipTextView.layer.masksToBounds = YES;
    self.ipTextView.font = [UIFont systemFontOfSize:18];
    self.ipTextView.text = [NSString stringWithFormat:@"http://%@:8080/", [GLFTools getIPAddress:YES]];
    self.ipTextView.textColor = [UIColor whiteColor];
    self.ipTextView.returnKeyType = UIReturnKeyGo;
    self.ipTextView.delegate = self;
    [self.view addSubview:self.ipTextView];
    
    for (NSInteger i = 0; i < 3; i++) {
        CGFloat width = (kScreenWidth - 60) / 3;
        CGRect frame = CGRectMake(15 * (i % 3 + 1) + width * (i % 3), 200 + 70 * ceil(i / 3), width, 50);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        if (i == 0) {
            [button setTitle:@"历史记录" forState:UIControlStateNormal];
        } else if (i == 1) {
            [button setTitle:@"清除缓存" forState:UIControlStateNormal];
        } else if (i == 2) {
            [button setTitle:@"黑名单" forState:UIControlStateNormal];
        }
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        [button setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction1:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i + 10;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
    }
    
    for (NSInteger i = 0; i < 4; i++) {
        CGFloat width = (kScreenWidth - 60) / 3;
        CGRect frame = CGRectMake(15 * (i % 3 + 1) + width * (i % 3), 270 + 70 * ceil(i / 3), width, 50);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        if (i == 0) {
            [button setTitle:@"Test1" forState:UIControlStateNormal];
        } else if (i == 1)  {
            [button setTitle:@"Test2" forState:UIControlStateNormal];
        } else if (i == 2)  {
            [button setTitle:@"Antd Mobile" forState:UIControlStateNormal];
        } else {
            [button setTitle:@"测试" forState:UIControlStateNormal];
        }
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction2:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i + 100;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *isNORecord = [userDefaults objectForKey:kNORecord];
    for (NSInteger i = 0; i < 2; i++) {
        CGFloat width = (kScreenWidth - 60) / 3;
        CGRect frame = CGRectMake(15 * (i % 3 + 1) + width * (i % 3), kScreenHeight - 80, width, 50);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        if (i == 0) {
            [button setTitle:@"百度一下" forState:UIControlStateNormal];
        } else if (i == 1) {
            [button setTitle:@"历史浏览" forState:UIControlStateNormal];
            if (isNORecord.integerValue != 1) {
                button.hidden = YES;
            }
        }
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        [button setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction3:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i + 1000;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    UIButton *button = [self.view viewWithTag:1001];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *isNORecord = [userDefaults objectForKey:kNORecord];
    if (isNORecord.integerValue == 1) {
        button.hidden = NO;
    } else {
        button.hidden = YES;
    }
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    if (self.action == 1) {
        [self scanQrCode];
    } else if (self.action == 2) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *type = [userDefaults objectForKey:kWebViewType];
        if (type.integerValue <= 0) {
            type = @"1";
        }
        NSString *urlStr = @"http://www.baidu.com";
        [self goURLVC:urlStr andType:type.integerValue];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tabbarHidden = [userDefaults objectForKey:kNavigationBarHidden];
    if (tabbarHidden.integerValue) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    self.action = 0;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark Events
- (void)declareAction {
    SetupViewController *vc = [[SetupViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scanQrCode {
    MMScanViewController *scanVc = [[MMScanViewController alloc] initWithQrType:MMScanTypeAll onFinish:^(NSString *result, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            [self showStringHUD:error.localizedDescription second:2];
        } else {
            NSLog(@"扫描结果：%@", result);
            [self goURLVC:result];
        }
    }];
    [scanVc setHistoryCallBack:^(NSArray *result) {
        NSLog(@"%@", result);
    }];
    [self.navigationController pushViewController:scanVc animated:YES];
}

- (void)buttonAction1:(UIButton *)button {
    [self.view endEditing:YES];
    if (button.tag == 10) {
        SelectIPView *ipView = [[SelectIPView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/4*3, kScreenHeight/3*2)];
        ipView.parentVC = self;
        ipView.isSecret = NO;
        ipView.backgroundColor = [UIColor whiteColor];
        [self lew_presentPopupView:ipView animation:[LewPopupViewAnimationSpring new] dismissed:^{
            NSLog(@"动画结束");
        }];
    } else if (button.tag == 11) {
        [self cleanCacheAndCookie];
        [self clearCache];
        [self showStringHUD:@"缓存清理完成" second:1.5];
    } else if (button.tag == 12) {
        BlackIPView *ipView = [[BlackIPView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/4*3, kScreenHeight/3*2)];
        ipView.parentVC = self;
        ipView.backgroundColor = [UIColor whiteColor];
        [self lew_presentPopupView:ipView animation:[LewPopupViewAnimationSpring new] dismissed:^{
            NSLog(@"动画结束");
        }];
    }
}

- (void)buttonAction2:(UIButton *)button {
    [self.view endEditing:YES];
    NSString *urlStr = @"";
    if (button.tag == 100) {
        urlStr = @"http://192.168.1.123:60108/abroadDetail?productId=174";
    } else if (button.tag == 101) {
        urlStr = @"http://192.168.1.121:60108/abroadDetail?productId=174";
    } else if (button.tag == 102) {
        urlStr = @"https://mobile.ant.design/kitchen-sink/";
    } else {
        urlStr = @"http://www.baidu.com";
    }
    [self goURLVC:urlStr];
}

- (void)buttonAction3:(UIButton *)button {
    [self.view endEditing:YES];
    if (button.tag == 1000) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *type = [userDefaults objectForKey:kWebViewType];
        if (type.integerValue <= 0) {
            type = @"1";
        }
        NSString *urlStr = @"http://www.baidu.com";
        [self goURLVC:urlStr andType:type.integerValue];
    } else if (button.tag == 1001) {
        SelectIPView *ipView = [[SelectIPView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/4*3, kScreenHeight/3*2)];
        ipView.parentVC = self;
        ipView.isSecret = YES;
        ipView.backgroundColor = [UIColor whiteColor];
        [self lew_presentPopupView:ipView animation:[LewPopupViewAnimationSpring new] dismissed:^{
            NSLog(@"动画结束");
        }];
    }
}

#pragma mark Tools
// 清除缓存和cookie
- (void)cleanCacheAndCookie{
    // 清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    // 清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

// 清除缓存
- (void)clearCache {
    if ([[[UIDevice currentDevice]systemVersion]intValue ] >= 9.0) {
        NSArray * types =@[WKWebsiteDataTypeMemoryCache,WKWebsiteDataTypeDiskCache]; // 9.0之后才有的
        NSSet *websiteDataTypes = [NSSet setWithArray:types];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{

        }];
    }else{
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSLog(@"%@", cookiesFolderPath);
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    }
}

- (void)goURLVC:(NSString *)urlStr {
    currentUrlStr = urlStr;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *isNORecord = [userDefaults objectForKey:kNORecord];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"前往页面" message:urlStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    UIAlertAction *okAction1 = [UIAlertAction actionWithTitle:@"UIWebView" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (isNORecord.integerValue != 1) {
            self.ipTextView.text = urlStr;
        }
        WebViewController *vc = [[WebViewController alloc] init];
        vc.urlStr = urlStr;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [alertVC addAction:okAction1];
    UIAlertAction *okAction2 = [UIAlertAction actionWithTitle:@"WKWebView" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (isNORecord.integerValue != 1) {
            self.ipTextView.text = urlStr;
        }
        WKWebViewController *vc = [[WKWebViewController alloc] init];
        vc.urlStr = urlStr;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [alertVC addAction:okAction2];
    UIAlertAction *okAction3 = [UIAlertAction actionWithTitle:@"SFSafariViewController" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (isNORecord.integerValue != 1) {
            self.ipTextView.text = urlStr;
        }
        if (![urlStr hasPrefix:@"http://"] && ![urlStr hasPrefix:@"https://"]) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"注意" message:@"SFSafariViewController Only HTTP and HTTPS URLs are supported." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self goURLVC:urlStr];
            }];
            [alertVC addAction:okAction];
            [self presentViewController:alertVC animated:YES completion:nil];
            return;
        }
        NSURL *url = [NSURL URLWithString:urlStr];
        SFSafariViewController *sfViewControllr = [[SFSafariViewController alloc] initWithURL:url];
        sfViewControllr.delegate = self;
        sfViewControllr.modalPresentationStyle = UIModalPresentationFullScreen; // 适配 iOS 14.7, 之前默认是全屏, 现在不是了
        [self presentViewController:sfViewControllr animated:YES completion:^{
            
        }];
    }];
    [alertVC addAction:okAction3];
    [self presentViewController:alertVC animated:YES completion:nil];
}

// 1-UIWebView 2-WKWebView 3-SFSafariViewController
- (void)goURLVC:(NSString *)urlStr andType:(NSInteger)type {
    if (type == 1) {
        WebViewController *vc = [[WebViewController alloc] init];
        vc.urlStr = urlStr;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (type == 2) {
        WKWebViewController *vc = [[WKWebViewController alloc] init];
        vc.urlStr = urlStr;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSURL *url = [NSURL URLWithString:urlStr];
        SFSafariViewController *sfViewControllr = [[SFSafariViewController alloc] initWithURL:url];
        sfViewControllr.delegate = self;
        sfViewControllr.modalPresentationStyle = UIModalPresentationFullScreen; // 适配 iOS 14.7, 之前默认是全屏, 现在不是了
        [self presentViewController:sfViewControllr animated:YES completion:^{
            
        }];
    }
}

#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // 如果为回车则将键盘收起
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        if (self.ipTextView.text.length == 0) {
            return NO;
        }
        [self goURLVC:self.ipTextView.text];
        return NO;
    }
    return YES;
}

#pragma mark SFSafariViewControllerDelegate
// 会在用户点击动作(Action)按钮(底部工具栏中间的按钮)的时候调用
// 可以传入UIActivity的数组,创建添加一些自定义的各类插件式的服务,比如分享到微信、微博什么的
- (NSArray<UIActivity *> *)safariViewController:(SFSafariViewController *)controller activityItemsForURL:(NSURL *)URL title:(nullable NSString *)title {
    NSLog(@"点击Action按钮: %@ %@", URL, title);
    return nil;
}

// Done按钮
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    NSLog(@"点击Done按钮");
}

// 页面加载完成
- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    NSLog(@"页面加载完成");
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *dict = @{
            @"ipStr": currentUrlStr,
            @"ipDescribe": @"",
            @"isLastSelect": @"1"
        };
        [manager addURL:dict];
    });
}


@end
