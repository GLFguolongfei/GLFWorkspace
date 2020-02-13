//
//  ThreeViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/9.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "ThreeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ThreeViewController ()<UIGestureRecognizerDelegate>
{
    AVCaptureSession *captureSession;                       // 输入设备和输出设备之间的数据传递
    AVCaptureDeviceInput *captureDeviceInput;               // 输入设备,例如摄像头和麦克风
    AVCaptureStillImageOutput *captureStillImageOutput;     // 照片输出流
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;   // 镜头捕捉到得预览图层
    
    BOOL isUseFrontFacingCamera; // 是否使用前置摄像头
    
    CGFloat startScale; // 记录开始的缩放比例
    CGFloat endScale;   // 最后的缩放比例
}
@end

@implementation ThreeViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自定义拍照";
    [self canRecord:NO];

    endScale = 1;

    [self configCamara];
    [self configCamaraButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (captureSession) {
        [captureSession startRunning]; // 开启摄像头
    }
    // 监听相机的对焦事件
    AVCaptureDevice *camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    int flags = NSKeyValueObservingOptionNew;
    [camDevice addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    if (captureSession) {
        [captureSession stopRunning]; // 关闭摄像头
    }
    // 移除监听相机的对焦事件
    AVCaptureDevice *camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [camDevice removeObserver:self forKeyPath:@"adjustingFocus"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.navigationController.navigationBar.hidden == YES) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

#pragma mark Setup
- (void)configCamara {
    // 1-AVCaptureSession
    captureSession = [[AVCaptureSession alloc] init];
    captureSession.sessionPreset = AVCaptureSessionPreset1280x720; // 设置像素
    
    // 2-AVCaptureDeviceInput
    // 相机输入设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 更改这个设置的时候必须先锁定设备,修改完后再解锁,否则崩溃
    [device lockForConfiguration:nil];
    // 必须判定是否有闪光灯,否则会崩溃
    if ([device hasFlash]) {
        // 设置闪光灯为自动
        device.flashMode = AVCaptureFlashModeAuto;
    }
    [device unlockForConfiguration];
    
    NSError *error;
    captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    if ([captureSession canAddInput:captureDeviceInput]) {
        [captureSession addInput:captureDeviceInput];
    }
    
    // 3-AVCaptureStillImageOutput
    captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    // 输出设置,AVVideoCodecJPEG,输出jpeg格式图片
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [captureStillImageOutput setOutputSettings:outputSettings];
    
    if ([captureSession canAddOutput:captureStillImageOutput]) {
        [captureSession addOutput:captureStillImageOutput];
    }
    
    // 4-AVCaptureVideoPreviewLayer
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    captureVideoPreviewLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.view.layer addSublayer:captureVideoPreviewLayer];
}

- (void)configCamaraButton {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, kScreenWidth-100, 200)];
    label.numberOfLines = 0;
    label.text = @"那年清秋 燕落桥边巧相会；\n脉脉如水 云剪青山翠；\n低眉莞尔 此生欲与醉；\n便从此 痴痴长坐 夜夜雨声碎";
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    
    for (NSInteger i = 0; i < 2; i++) {
        CGFloat width = (kScreenWidth - 60) / 2;
        CGRect frame = CGRectMake(20 * (i % 2 + 1) + width * (i % 2), 580 + 80 * ceil(i / 2), width, 60);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        if (i == 0) {
            [button setTitle:@"拍照" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(tackCamara) forControlEvents:UIControlEventTouchUpInside];
        } else if (i == 1)  {
            [button setTitle:@"切换摄像头" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
        }
        [button setBackgroundColor:[UIColor lightGrayColor]];
        button.tag = i + 100;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
    }
    
    // 捏合手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
}

#pragma mark Events
// 拍照
- (void)tackCamara {
    AVCaptureConnection *captureConnection = [captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation captureVideoOrientation = [self avOrientationForDeviceOrientation:deviceOrientation];
    [captureConnection setVideoOrientation:captureVideoOrientation]; // 设置视频方向
    [captureConnection setVideoScaleAndCropFactor:endScale]; // 设置视频比例
    
    [captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:data];
        // 将图片保存到本地手机相册
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        // 保存到沙盒
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *rootPaht = [paths objectAtIndex:0];
        NSString *name = [self returnName];
        NSString *outputFielPath = [NSString stringWithFormat:@"%@/郭龙飞/%@.png", rootPaht, name];
        NSLog(@"save path is: %@", outputFielPath);
        [data writeToFile:outputFielPath atomically:YES];
    }];
}

// 切换摄像头
- (void)switchCamera {
    AVCaptureDevicePosition desiredPosition;
    if (isUseFrontFacingCamera) {
        desiredPosition = AVCaptureDevicePositionBack;
    } else {
        desiredPosition = AVCaptureDevicePositionFront;
    }
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([device position] == desiredPosition) {
            [captureVideoPreviewLayer.session beginConfiguration];
            for (AVCaptureInput *oldInput in captureVideoPreviewLayer.session.inputs) {
                [[captureVideoPreviewLayer session] removeInput:oldInput];
            }
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            [captureVideoPreviewLayer.session addInput:input];
            [captureVideoPreviewLayer.session commitConfiguration];
            break;
        }
    }
    isUseFrontFacingCamera = !isUseFrontFacingCamera;
}

// 缩放手势(用于调整焦距)
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.view];
        CGPoint convertedLocation = [captureVideoPreviewLayer convertPoint:location fromLayer:captureVideoPreviewLayer.superlayer];
        if ( ! [captureVideoPreviewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    if (allTouchesAreOnThePreviewLayer) {
        CGFloat maxScaleAndCropFactor = [[captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        endScale = startScale * recognizer.scale;
        if (endScale < 1.0){
            endScale = 1.0;
        }
        if (endScale > maxScaleAndCropFactor) {
            endScale = maxScaleAndCropFactor;
        }
        NSLog(@"%f --> %f --> %f --> %f", maxScaleAndCropFactor, startScale, endScale, recognizer.scale);
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [captureVideoPreviewLayer setAffineTransform:CGAffineTransformMakeScale(endScale, endScale)];
        [CATransaction commit];
    }
}

// KVO(监听相机的对焦事件)
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    // 在这里做你想做的事~~~
    NSLog(@"对焦成功");
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        startScale = endScale;
    }
    return YES;
}

#pragma mark 私有方法
// 获取设备方向的方法
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft ) {
        result = AVCaptureVideoOrientationLandscapeRight;
    } else if ( deviceOrientation == UIDeviceOrientationLandscapeRight ) {
        result = AVCaptureVideoOrientationLandscapeLeft;
    }
    return result;
}

// 生成唯一不重复名称
- (NSString *)returnName {
    CFUUIDRef uuidRef =CFUUIDCreate(NULL);
    CFStringRef uuidStringRef =CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uniqueId = (__bridge NSString *)uuidStringRef;
    return uniqueId;
}


@end
