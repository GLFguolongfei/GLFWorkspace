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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    [manager setVideosImage:5];
    
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

#pragma mark HUD透明指示器
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

#pragma mark 是否可以记录
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
//        NSLog(@"save path is: %@", outputFielPath);
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


@end
