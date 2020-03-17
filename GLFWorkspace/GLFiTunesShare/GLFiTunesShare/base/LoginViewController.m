//
//  LoginViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/10/2.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "LoginViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "RootViewController.h"

@interface LoginViewController ()<UITextFieldDelegate>
{
    UITextField *textField;
    UIButton *button;
    BOOL isSu;
}
@end

@implementation LoginViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    // Logo
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2.0, 64, 150, 150)];
    imageView.image = [UIImage imageNamed:@"jing"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    // 密码框
    textField = [[UITextField alloc] initWithFrame:CGRectMake(30, 240, kScreenWidth-60, 50)];
    textField.font = KFontBold(18);
    textField.placeholder = @"请输入6位密码？";
    textField.secureTextEntry = YES;
    textField.clearButtonMode = UIKeyboardTypeASCIICapable;
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.layer.cornerRadius = 5;
    textField.layer.borderWidth = 1;
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    textField.delegate = self;
    [self.view addSubview:textField];
    // 左侧加View
    CGRect frame = [textField frame];
    frame.size.width = 10;
    UIView *leftview = [[UIView alloc] initWithFrame:frame];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = leftview;
    // 登陆
    button = [[UIButton alloc] initWithFrame:CGRectMake(30, 320, kScreenWidth-60, 50)];
    [button setTitle:@"登录" forState:UIControlStateNormal];
    button.titleLabel.font = KFontBold(20);
    button.backgroundColor = [UIColor blackColor];
    button.layer.cornerRadius = 5;
    [self.view addSubview:button];
    [button addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    // 名言警句-背景
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 290, kScreenWidth, kScreenWidth)];
    backImageView.image = [UIImage imageNamed:@"地图"];
    backImageView.contentMode = UIViewContentModeScaleAspectFill;
    backImageView.alpha = 0.3;
    backImageView.clipsToBounds = YES;
    [self.view addSubview:backImageView];
    // 名言警句
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 420, kScreenWidth, 120)];
    label.text = @"放下了做诗的笔，拿起了战斗的剑，\n\n民族处于危难，祖国迫切召唤！\n\n耻辱需要用鲜血来洗刷，愤怒只能让死亡去平息！\n\n龙的传人终将砸开锁链，翱翔九天！";
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.alpha = 0.6;
    label.font = KFontBold(14);
    [self.view addSubview:label];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 3;
    tapGesture.numberOfTouchesRequired = 3;
    [tapGesture addTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    isSu = NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark Events
- (void)loginAction {
    [self.view endEditing:YES];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"GLF" ofType:@"plist"];
    NSMutableDictionary *searchdata = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *password = searchdata[@"passwordKey"];
    NSString *decodedStr = [password base64DecodedString];
    NSString *str = [textField.text lowercaseString];
    if ([str isEqualToString:decodedStr] && isSu) {
        textField.text = @"";
        RootViewController *rootVC = [[RootViewController alloc] init];
        rootVC.moveModel = self.moveModel;
        [self.navigationController pushViewController:rootVC animated:YES];
    } else {
        if (str.length == 0) {
            [self showStringHUD:@"请输入密码" second:1.5];
        } else {
            [self showStringHUD:@"密码错误" second:1.5];
        }
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    isSu = YES;
    if (textField.text.length == 0) {
        // 1.判断系统版本
        if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
            [self showStringHUD:@"对不起,该手机不支持指纹识别" second:1.5];
        }
        // 2.LAContext: 本地验证对象上下文
        LAContext *context = [LAContext new];
        context.localizedFallbackTitle = @"";
        // 3.判断生物识别技术是否可用
        NSError *error;
        if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            [self showStringHUD:error.localizedDescription second:1.5];
        }
        // 4.开始使用指纹识别
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"开启了指纹识别,将打开隐藏功能" reply:^(BOOL success, NSError * _Nullable error) {
            if (success) { // 指纹识别成功,回主线程更新UI,弹出提示框
                dispatch_async(dispatch_get_main_queue(), ^{
                    RootViewController *rootVC = [[RootViewController alloc] init];
                    rootVC.moveModel = self.moveModel;
                    [self.navigationController pushViewController:rootVC animated:YES];
                });
            }
            if (error) { // 指纹识别出现错误,回主线程更新UI,弹出提示框
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showStringHUD:error.localizedDescription second:1.5];
                });
            }
        }];
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length > 5) {
        return NO;
    }
    return YES;
}


@end
