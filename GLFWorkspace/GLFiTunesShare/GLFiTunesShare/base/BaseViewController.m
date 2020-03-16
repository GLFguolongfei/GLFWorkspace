//
//  BaseViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/10/17.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "BaseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface BaseViewController ()<AVCaptureFileOutputRecordingDelegate>
{
    AVCaptureSession *captureSession;
    AVCaptureDeviceInput *captureDeviceInput;
    AVCaptureMovieFileOutput *captureMovieFileOutput;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    
    CAEmitterLayer *colorBallLayer;
    CAEmitterLayer *snowEmitterLayer;
    
    BOOL isUseFrontFacingCamera; // 是否使用前置摄像头
    BOOL isCanRecord;    
}
@end

@implementation BaseViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // 不需要添加额外的滚动区域
    self.automaticallyAdjustsScrollViewInsets = NO;

    isCanRecord = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    [manager setVideosImage:5];
    [manager setScaleImage:2];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *record = [userDefaults objectForKey:kRecord];
    if ([record isEqualToString:@"1"] && isCanRecord) {
        if (![self.title hasPrefix:@":"]) {
            self.title = [NSString stringWithFormat:@":%@", self.title];
        }
    } else {
        if ([self.title hasPrefix:@":"]) {
            NSArray *array = [self.title componentsSeparatedByString:@":"];
            if (array.count >= 2) {
                self.title = array[1];
            }
        }
    }

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if ([record isEqualToString:@"1"] && isCanRecord) {
            [self configCamara:YES];
            [self startRecording];
        } else {
            [self configCamara:NO];
            [self stopRecording];
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self configCamara:NO];
    [self stopRecording];
}

#pragma mark ------- HUD指示器
// 功能:显示hud
- (void)showHUD {
    [self hideAllHUD];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.yOffset = 64;
}

- (void)showHUDsecond:(int)aSecond {
    [self hideAllHUD];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.yOffset = 64;
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:aSecond];
}

// 功能:显示字符串hud
- (void)showHUD:(NSString *)aMessage {
    [self hideAllHUD];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = aMessage;
    hud.yOffset = 64;
}

- (void)showHUD:(NSString *)aMessage animated:(BOOL)animated {
    [self hideAllHUD];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:animated];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = aMessage;
    hud.yOffset = 64;
}

- (void)showStringHUD:(NSString *)aMessage second:(int)aSecond {
    [self hideAllHUD];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = aMessage;
    hud.yOffset = 64;
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:aSecond];
}

// 功能:隐藏hud
- (void)hideHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)hideHUD:(BOOL)animated {
    [MBProgressHUD hideHUDForView:self.view animated:animated];
}

- (void)hideAllHUD {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark ------- 是否记录
- (void)canRecord:(BOOL)isYes {
    isCanRecord = isYes;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *record = [userDefaults objectForKey:kRecord];
    if ([record isEqualToString:@"1"] && isCanRecord) {
        if (captureMovieFileOutput && ![captureMovieFileOutput isRecording]) {
            [self configCamara:YES];
            [self startRecording];
        }
    } else {
        [self configCamara:NO];
        [self stopRecording];
    }
}

#pragma mark Setup
- (void)configCamara:(BOOL)isRecord {
    if (!isRecord) {
        captureSession = nil;
        captureDeviceInput = nil;
        captureMovieFileOutput = nil;
        captureVideoPreviewLayer = nil;
        [captureVideoPreviewLayer removeFromSuperlayer];
        return;
    }
    // 1-AVCaptureSession
    captureSession = [[AVCaptureSession alloc]init];
    captureSession.sessionPreset = AVCaptureSessionPreset1280x720;

    // 2-AVCaptureDeviceInput
    // 相机输入设备
    AVCaptureDevice *camaraCaptureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionFront];
    // 音频输入设备
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    
    NSError *error = nil;
    captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:camaraCaptureDevice error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    AVCaptureDeviceInput *audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    // 将设备输入添加到会话中
    if ([captureSession canAddInput:captureDeviceInput]) {
        [captureSession addInput:captureDeviceInput];
        [captureSession addInput:audioCaptureDeviceInput];
    }
    
    // 3-AVCaptureMovieFileOutput
    captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc]init];
    
    // 将设备输出添加到会话中
    if ([captureSession canAddOutput:captureMovieFileOutput]) {
        [captureSession addOutput:captureMovieFileOutput];
    }
    
    // 4-AVCaptureVideoPreviewLayer
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    captureVideoPreviewLayer.frame = CGRectMake(0, 0, 0, 0);
    [self.view.layer addSublayer:captureVideoPreviewLayer];
}

#pragma mark Events
// 开始录制
- (void)startRecording {
    AVCaptureConnection *captureConnection = [captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if (![captureMovieFileOutput isRecording]) {
        [captureSession startRunning]; // 开启摄像头
        // 预览图层和视频方向保持一致
        captureConnection.videoOrientation = [captureVideoPreviewLayer connection].videoOrientation;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *rootPaht = [paths objectAtIndex:0];
        NSString *name = [self returnName];
        NSString *outputFielPath = [NSString stringWithFormat:@"%@/郭龙飞/%@.mp4", rootPaht, name];
        //  NSLog(@"save path is: %@", outputFielPath);
        NSURL *fileUrl = [NSURL fileURLWithPath:outputFielPath];
        [captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
    }
}

// 结束录制
- (void)stopRecording {
    if ([captureMovieFileOutput isRecording]) {
        [captureMovieFileOutput stopRecording]; // 停止录制
        [captureSession stopRunning]; // 关闭摄像头
    }
}

// 切换前后摄像头
- (void)switchCamera {
    [captureSession startRunning];

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

#pragma mark AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制...");
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"视频录制完成.");
}

#pragma mark 私有方法
// 取得指定位置的摄像头
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

// 生成唯一不重复名称
- (NSString *)returnName {
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormat2 stringFromDate:[NSDate date]];
    NSString *classStr = NSStringFromClass([self class]);
    NSString *name = [NSString stringWithFormat:@"%@%@", dateStr, classStr];
    return dateStr;
}

#pragma mark -------- 发散光源
- (void)setupEmitter1 {
    // 1.设置 CAEmitterLayer
    colorBallLayer = [CAEmitterLayer layer];
    // 发射源的尺寸大小
    colorBallLayer.emitterSize = self.view.frame.size;
    // 发射源的形状
    colorBallLayer.emitterShape = kCAEmitterLayerPoint;
    // 发射模式
    colorBallLayer.emitterMode = kCAEmitterLayerPoints;
    // 粒子发射形状的中心点
    colorBallLayer.emitterPosition = CGPointMake(self.view.layer.bounds.size.width, 0.f);
    [self.view.layer addSublayer:colorBallLayer];

    // 2.配置 CAEmitterCell
    CAEmitterCell *colorBallCell = [CAEmitterCell emitterCell];
    // 粒子名称
    colorBallCell.name = @"colorBallCell";
    // 粒子产生率,默认为 0
    colorBallCell.birthRate = 20.f;
    // 粒子生命周期
    colorBallCell.lifetime = 10.f;
    // 粒子速度,默认为 0
    colorBallCell.velocity = 40.f;
    // 粒子速度平均量
    colorBallCell.velocityRange = 100.f;
    // x,y,z 方向上的加速度分量, 三者默认为 0
    colorBallCell.yAcceleration = 15.f;
    // 指定纬度, 纬度角代表在 x-z轴平面坐标系中与 x 轴之间的夹角默认为 0
    colorBallCell.emissionLongitude = M_PI;// 向左
    // 发射角度范围,默认为 0, 以锥形分布开的发射角, 角度为弧度制.粒子均匀分布在这个锥形范围内;
    colorBallCell.emissionRange = M_PI_4;// 围绕 x 轴向左90 度
    // 缩放比例, 默认 1
    colorBallCell.scale = 0.2;
    // 缩放比例范围, 默认是 0
    colorBallCell.scaleRange = 0.1;
    // 在生命周期内的缩放速度, 默认是 0
    colorBallCell.scaleSpeed = 0.02;
    // 粒子的内容, 为 CGImageRef 的对象
    colorBallCell.contents = (id)[[UIImage imageNamed:@"circle_white"] CGImage];
    // 颜色
    colorBallCell.color = [[UIColor colorWithRed:0.5 green:0.f blue:0.5 alpha:1.f] CGColor];
    // 粒子颜色 red, green, blue, alpha 能改变的范围, 默认 0
    colorBallCell.redRange = 1.f;
    colorBallCell.greenRange = 1.f;
    colorBallCell.alphaRange = 0.8f;
    // 粒子颜色 red, green, blue, alpha 在生命周期内的改变速度, 默认 0
    colorBallCell.blueSpeed = 1.f;
    colorBallCell.alphaSpeed = -0.1f;
    // 添加
    colorBallLayer.emitterCells = @[colorBallCell];
}

- (void)setupEmitter2 {
    // 1.设置 CAEmitterLayer
    snowEmitterLayer = [CAEmitterLayer layer];
    snowEmitterLayer.emitterPosition = CGPointMake(100, -30);
    snowEmitterLayer.emitterSize = CGSizeMake(self.view.bounds.size.width * 2, 0);
    snowEmitterLayer.emitterMode = kCAEmitterLayerOutline;
    snowEmitterLayer.emitterShape = kCAEmitterLayerLine;
    // 阴影的 不透明度
    snowEmitterLayer.shadowOpacity = 1;
    // 阴影化开的程度（就像墨水滴在宣纸上化开那样）
    snowEmitterLayer.shadowRadius = 8;
    // 阴影的偏移量
    snowEmitterLayer.shadowOffset = CGSizeMake(3, 3);
    // 阴影的颜色
    snowEmitterLayer.shadowColor = [[UIColor whiteColor] CGColor];
    [self.view.layer addSublayer:snowEmitterLayer];

    // 2.配置 CAEmitterCell
    CAEmitterCell *snowCell = [CAEmitterCell emitterCell];
    snowCell.contents = (__bridge id)[UIImage imageNamed:@"樱花瓣2"].CGImage;
    // 花瓣缩放比例
    snowCell.scale = 0.02;
    snowCell.scaleRange = 0.5;
    // 每秒产生的花瓣数量
    snowCell.birthRate = 7;
    snowCell.lifetime = 80;
    // 每秒花瓣变透明的速度
    snowCell.alphaSpeed = -0.01;
    // 秒速“五”厘米～～
    snowCell.velocity = 40;
    snowCell.velocityRange = 60;
    // 花瓣掉落的角度范围
    snowCell.emissionRange = M_PI;
    // 花瓣旋转的速度
    snowCell.spin = M_PI_4;
    // 添加    
    snowEmitterLayer.emitterCells = [NSArray arrayWithObject:snowCell];
}

- (void)removeEmitter {
    [colorBallLayer removeFromSuperlayer];
    [snowEmitterLayer removeFromSuperlayer];
}


@end
