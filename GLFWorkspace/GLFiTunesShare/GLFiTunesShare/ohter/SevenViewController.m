//
//  SevenViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/8/22.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "SevenViewController.h"

@interface SevenViewController ()<UIActionSheetDelegate>
{
    UIImageView *imageView;
}
@end

@implementation SevenViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"选取图片" style:UIBarButtonItemStylePlain target:self action:@selector(button)];
    self.navigationItem.rightBarButtonItem = item;
    self.view.backgroundColor = [UIColor whiteColor];

    // CoreImage类中提供了一个CIDetector类来给我们提供两种类型的检测器
    // 1-人脸检测: 就是检测出图像中是否包含人脸,可以给你指出图像中每一个人脸的位置,还有人脸中眼见、嘴巴的位置
    // 2-人脸识别: 是更加高级的技术,可以告诉你几张照片中的人是不是同一人
    // CIDetector类可以做到人脸检测,但做不到人脸识别
    
    // 原图
    imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
}

- (void)button {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机", @"图库", nil];
    [action showInView:self.view];
}

- (void)logFaceInfosWithImage:(UIImage *)image {
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                  context:nil
                                                  options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [faceDetector featuresInImage:ciImage];
    for (CIFaceFeature *faceFeature in features) {
        NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 人脸位置: %@", NSStringFromCGRect(faceFeature.bounds));
        if (faceFeature.hasLeftEyePosition) {
            NSLog(@"左眼: %@", NSStringFromCGPoint(faceFeature.leftEyePosition));
            [self addPoint:faceFeature.leftEyePosition];
        }
        if (faceFeature.hasRightEyePosition) {
            NSLog(@"右眼: %@", NSStringFromCGPoint(faceFeature.rightEyePosition));
            [self addPoint:faceFeature.rightEyePosition];
        }
        if (faceFeature.hasMouthPosition) {
            NSLog(@"嘴巴: %@", NSStringFromCGPoint(faceFeature.mouthPosition));
            [self addPoint:faceFeature.mouthPosition];
        }
        
        if (faceFeature.hasTrackingID) {
            NSLog(@"追踪ID: %d", faceFeature.trackingID);
        }
        if (faceFeature.hasTrackingFrameCount) {
            NSLog(@"追踪帧数: %d", faceFeature.trackingFrameCount);
        }
        
        if (faceFeature.hasFaceAngle) {
            NSLog(@"面角: %f", faceFeature.faceAngle);
        }
        
        NSLog(@"是否微笑: %d", faceFeature.hasSmile);
        NSLog(@"左眼是否闭合: %d", faceFeature.leftEyeClosed);
        NSLog(@"右眼是否闭合: %d", faceFeature.rightEyeClosed);
    }
}

// CI框架的坐标系跟CG框架一样,跟UIKit框架的坐标系不一样
- (void)addPoint:(CGPoint)point {
    CGSize imageSize = imageView.image.size;
    CGSize deviceSize = [UIScreen mainScreen].bounds.size;
    CGFloat x = point.x * deviceSize.width / imageSize.width;
    CGFloat y = (imageSize.height - point.y) * deviceSize.height / imageSize.height;
    UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
    pointView.center = CGPointMake(x, y);
    pointView.backgroundColor = [UIColor redColor];
    [self.view addSubview:pointView];
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
        imageView.image = editedImage;
        // 人脸识别
        [self logFaceInfosWithImage:imageView.image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}



@end
