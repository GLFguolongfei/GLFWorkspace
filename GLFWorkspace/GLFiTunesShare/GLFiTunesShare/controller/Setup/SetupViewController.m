//
//  SetupViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/10/9.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "SetupViewController.h"
#import "MyView.h"
#import "WaterView2.h"
#import "PhotoLibraryViewController.h"
#import "ImageSubViewController.h"
#import "WebSetupViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "OtherViewController.h"
#import "AllImageViewController.h"
#import "AllVideoViewController.h"

@interface SetupViewController ()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImageView *bgImageView;
}
@end

@implementation SetupViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"有趣功能" style:UIBarButtonItemStylePlain target:self action:@selector(button3)];
    self.navigationItem.rightBarButtonItem = item;
    self.title = @"设置";

    // 设置背景图片
    bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:bgImageView];
    
    // 文字
    CGRect labelRect = CGRectMake(0, kScreenWidth, kScreenWidth, 100);
    UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    
    label.text = @"凛冬将至";
    label.textColor = [UIColor colorWithHexString:@"E3170D"];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    
    label.font = KFontBold(36);
    label.font = [UIFont fontWithName:@"Zapfino" size:36];
    
    label.shadowColor = [UIColor colorWithHexString:@"FF7F50"];
    label.shadowOffset = CGSizeMake(2, 2);
    
    // 太极图
    MyView *view = [[MyView alloc]initWithFrame:CGRectMake(50, 90, kScreenWidth-100, kScreenWidth-100)];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    
    // 水波
    WaterView2 *waterView2 = [[WaterView2 alloc] initWithFrame:self.view.bounds];
    waterView2.backgroundColor = [UIColor clearColor];
    [self.view addSubview:waterView2];
    
    // 选取背景
    CGFloat space = kScreenWidth / 2;
    for (int i = 0; i < 2; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(space*i, kScreenHeight-100, space, 80)];
        if (i == 0) {
            [button setTitle:@"设置背景图像" forState:UIControlStateNormal];
        } else if (i == 1) {
            [button setTitle:@"设置内容显示" forState:UIControlStateNormal];
        }
        [self.view addSubview:button];
        button.tag = 100 + i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *pictureItem = [[UIBarButtonItem alloc] initWithTitle:@"所有图片" style:UIBarButtonItemStylePlain target:self action:@selector(button1)];
    UIBarButtonItem *videoItem = [[UIBarButtonItem alloc] initWithTitle:@"所有视频" style:UIBarButtonItemStylePlain target:self action:@selector(button2)];
    UIBarButtonItem *toolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]; // 特殊的一个,用来自动计算宽度
    self.toolbarItems = @[toolBarSpace, pictureItem, toolBarSpace, videoItem, toolBarSpace];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *isUseBackImagePath = [userDefaults objectForKey:IsUseBackImagePath];
    NSString *backName = [userDefaults objectForKey:BackImageName];
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    NSString *filePath = [cachePath stringByAppendingString:@"/image.png"];
    UIImage *backImage;
    if (isUseBackImagePath.integerValue) {
        backImage = [UIImage imageWithContentsOfFile:filePath];
    } else {
        backImage = [UIImage imageNamed:backName];
    }
    if (backImage == nil) {
        backImage = [UIImage imageNamed:@"bgView2"];
        [userDefaults setObject:@"bgView2" forKey:BackImageName];
        [userDefaults synchronize];
    }
    bgImageView.image = backImage;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.navigationController.toolbar.hidden ) {
        [self.navigationController setToolbarHidden:NO animated:YES];
    } else {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

- (void)buttonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == 100) {
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机", @"图库", @"系统背景", nil];
        [action showInView:self.view];
    } else if (button.tag == 101) {
        WebSetupViewController *webSetupVC = [[WebSetupViewController alloc] init];
        [self.navigationController pushViewController:webSetupVC animated:YES];
    }
}

- (void)button1 {
    AllImageViewController *imageVC = [[AllImageViewController alloc] init];
    [self.navigationController pushViewController:imageVC animated:YES];
}

- (void)button2 {
    AllVideoViewController *videoVC = [[AllVideoViewController alloc] init];
    [self.navigationController pushViewController:videoVC animated:YES];
}

- (void)button3 {
    OtherViewController *otherVC = [[OtherViewController alloc] init];
    [self.navigationController pushViewController:otherVC animated:YES];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: { // 相机
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [self pickImageWithType:UIImagePickerControllerSourceTypeCamera mediaType:kUTTypeImage];
            } else {
                NSLog(@"************* 不支持相机");
            }
        }
            break;
        case 1: { // 图库
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                [self pickImageWithType:UIImagePickerControllerSourceTypePhotoLibrary mediaType:kUTTypeImage];
            } else {
                NSLog(@"************* 不支持图库");
            }
        }
            break;
        case 2: { // 系统背景
            PhotoLibraryViewController *vc = [[PhotoLibraryViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)pickImageWithType:(UIImagePickerControllerSourceType)type mediaType:(CFStringRef)mediaType {
    // 1-初始化UIImagePickerController
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    // 2-设置设置代理属性
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    // 3-设置来源与需求
    picker.sourceType = type; // 设置图像选取控制器的来源模式
    picker.mediaTypes = @[(__bridge NSString *)mediaType]; // 设置图像选取控制器的类型
    
    if (type == UIImagePickerControllerSourceTypeCamera) {
        // 设置拍照时的下方的工具栏是否显示，如果需要自定义拍摄界面，则可把该工具栏隐藏
        picker.showsCameraControls  = YES;
        // 设置使用后置摄像头，可以使用前置摄像头
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        // 设置闪光灯模式
        picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        // 获取用户编辑之后的图像
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        ImageSubViewController *detailVC = [[ImageSubViewController alloc] init];
        detailVC.image = editedImage;
        [self.navigationController pushViewController:detailVC animated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
