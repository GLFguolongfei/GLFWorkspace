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
// Tools
#import "LewPopupViewController.h"

@interface ViewController ()<UITextViewDelegate>

@end

@implementation ViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"HTML5";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(declareAction)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"扫码" style:UIBarButtonItemStylePlain target:self action:@selector(scanQrCode)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    CGRect textViewRect = CGRectMake(15, 80, kScreenWidth-30, 100);
    self.ipTextView = [[UITextView alloc] initWithFrame:textViewRect];
    self.ipTextView.backgroundColor = [UIColor lightGrayColor];
    self.ipTextView.layer.cornerRadius = 5;
    self.ipTextView.layer.masksToBounds = YES;
    self.ipTextView.font = [UIFont systemFontOfSize:16];
    self.ipTextView.text = [NSString stringWithFormat:@"http://%@:8080/", [GLFTools getIPAddress:YES]];
    self.ipTextView.returnKeyType = UIReturnKeyGo;
    self.ipTextView.delegate = self;
    [self.view addSubview:self.ipTextView];
    
    for (NSInteger i = 0; i < 2; i++) {
        CGFloat width = (kScreenWidth - 60) / 3;
        CGRect frame = CGRectMake(15 * (i % 3 + 1) + width * (i % 3), 200 + 80 * ceil(i / 3), width, 50);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        if (i == 0) {
            [button setTitle:@"选择地址" forState:UIControlStateNormal];
        } else if (i == 1)  {
            [button setTitle:@"清除缓存" forState:UIControlStateNormal];
        } else {
            [button setTitle:@"导航栏" forState:UIControlStateNormal];
        }
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        button.backgroundColor = [UIColor lightGrayColor];
        [button setTitleColor:KNavgationBarColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction1:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i + 10;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
    }
    
    for (NSInteger i = 0; i < 3; i++) {
        CGFloat width = (kScreenWidth - 60) / 3;
        CGRect frame = CGRectMake(15 * (i % 3 + 1) + width * (i % 3), 270 + 80 * ceil(i / 3), width, 50);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        if (i == 0) {
            [button setTitle:@"Test1" forState:UIControlStateNormal];
        } else if (i == 1)  {
            [button setTitle:@"Test2" forState:UIControlStateNormal];
        } else {
            [button setTitle:@"测试" forState:UIControlStateNormal];
        }
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        button.backgroundColor = [UIColor lightGrayColor];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction2:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i + 100;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tabbarHidden = [userDefaults objectForKey:@"tabbarHidden"];
    if (tabbarHidden.integerValue) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)goURLVC:(NSString *)urlStr {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"前往页面" message:urlStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    UIAlertAction *okAction1 = [UIAlertAction actionWithTitle:@"UIWebView" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.ipTextView.text = urlStr;
        WebViewController *vc = [[WebViewController alloc] init];
        vc.urlStr = urlStr;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [alertVC addAction:okAction1];
    UIAlertAction *okAction2 = [UIAlertAction actionWithTitle:@"WKWebView" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.ipTextView.text = urlStr;
        WKWebViewController *vc = [[WKWebViewController alloc] init];
        vc.urlStr = urlStr;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [alertVC addAction:okAction2];
    UIAlertAction *okAction3 = [UIAlertAction actionWithTitle:@"SFSafariViewController" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.ipTextView.text = urlStr;
        NSURL *url = [NSURL URLWithString:urlStr];
        SFSafariViewController *sfViewControllr = [[SFSafariViewController alloc] initWithURL:url];
//      sfViewControllr.delegate = self;
        [self presentViewController:sfViewControllr animated:YES completion:^{
            
        }];
    }];
    [alertVC addAction:okAction3];
    [self presentViewController:alertVC animated:YES completion:nil];
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
        SelectIPView *ipView = [[SelectIPView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/4*3, kScreenHeight/4*3)];
        ipView.parentVC = self;
        ipView.backgroundColor = [UIColor whiteColor];
        [self lew_presentPopupView:ipView animation:[LewPopupViewAnimationSpring new] dismissed:^{
            NSLog(@"动画结束");
        }];
    } else if (button.tag == 11) {
        [self cleanCacheAndCookie];
        [self clearCache];
        [self showStringHUD:@"缓存清理完成" second:1.5];
    } else if (button.tag == 12) {

    }
}

- (void)buttonAction2:(UIButton *)button {
    [self.view endEditing:YES];
    NSString *urlStr = @"";
    if (button.tag == 100) {
        urlStr = @"http://192.168.1.123:60108/abroadDetail?productId=174";
    } else if (button.tag == 101) {
        urlStr = @"http://192.168.1.121:60108/abroadDetail?productId=174";
    } else {
        urlStr = @"http://www.baidu.com";
    }
    [self goURLVC:urlStr];
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

#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // 如果为回车则将键盘收起
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        if (self.ipTextView.text.length == 0) {
            return NO;
        }
        WKWebViewController *vc = [[WKWebViewController alloc] init];
        vc.urlStr = self.ipTextView.text;
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }
    return YES;
}


@end
