//
//  FourViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/9.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "FourViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface FourViewController ()<AVCaptureFileOutputRecordingDelegate>
{
    AVCaptureSession *captureSession;
    AVCaptureDeviceInput *captureDeviceInput;
    AVCaptureMovieFileOutput *captureMovieFileOutput; // 视频输出流
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    
    BOOL isUseFrontFacingCamera; // 是否使用前置摄像头
    
    NSTimer *timer;
    NSInteger timeCount;
    
    UILabel *timeLabel;
    UIButton *recordButton;
}
@end

@implementation FourViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自定义录像";

    timeCount = 0;
    
    [self configCamara];
    [self configCamaraButton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (captureSession) {
        [captureSession startRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (captureSession) {
        [captureSession stopRunning];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.navigationController.navigationBar.hidden == YES) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [UIView animateWithDuration:0.25 animations:^{
            timeLabel.frame = CGRectMake(15, 64, kScreenWidth - 30, 40);
        }];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:0.25 animations:^{
            timeLabel.frame = CGRectMake(15, 20, kScreenWidth - 30, 40);
        }];
    }
}

#pragma mark Setup
- (void)configCamara {
    // 1-AVCaptureSession
    captureSession = [[AVCaptureSession alloc]init];
    captureSession.sessionPreset = AVCaptureSessionPreset1280x720;

    // 2-AVCaptureDeviceInput
    // 相机输入设备
    AVCaptureDevice *camaraCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
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
    captureVideoPreviewLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.view.layer addSublayer:captureVideoPreviewLayer];
}

- (void)configCamaraButton {
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 64, kScreenWidth - 30, 40)];
    timeLabel.text = @"00";
    timeLabel.textColor = [UIColor redColor];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:timeLabel];
    
    for (NSInteger i = 0; i < 2; i++) {
        CGFloat width = (kScreenWidth - 60) / 2;
        CGRect frame = CGRectMake(20 * (i % 2 + 1) + width * (i % 2), 590 + 80 * ceil(i / 2), width, 60);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        if (i == 0) {
            recordButton = button;
            [button setTitle:@"开始录制" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(tackCamara) forControlEvents:UIControlEventTouchUpInside];
        } else if (i == 1)  {
            [button setTitle:@"切换摄像头" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
        }
        [button setBackgroundColor:[UIColor lightGrayColor]];
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
    }
}

#pragma mark Events
// 视频录制
- (void)tackCamara {
    AVCaptureConnection *captureConnection = [captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if (![captureMovieFileOutput isRecording]) {
        // 预览图层和视频方向保持一致
        captureConnection.videoOrientation = [captureVideoPreviewLayer connection].videoOrientation;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *rootPaht = [paths objectAtIndex:0];
        NSString *name = [self returnName];
        NSString *outputFielPath = [NSString stringWithFormat:@"%@/郭龙飞/%@.mp4", rootPaht, name];
        NSLog(@"save path is: %@", outputFielPath);
        NSURL *fileUrl = [NSURL fileURLWithPath:outputFielPath];
        [captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        // 定时器
        [self timerState:YES];
    } else {
        [captureMovieFileOutput stopRecording]; // 停止录制
        [self timerState:NO]; // 定时器
    }
}

// 切换前后摄像头
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
    [self timerState:NO];
    if ([captureMovieFileOutput isRecording]) {
        NSString *info = @"上段视频已保存至相簿\n如需再次录制,请重新点击【开始录制】按钮";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:info message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)timerState:(BOOL)isStart {
    if (isStart) {
        timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(showTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [recordButton setTitle:@"结束录制" forState:UIControlStateNormal];
    } else {
        [timer invalidate];
        timeCount = 00;
        timeLabel.text = @"00";
        [recordButton setTitle:@"开始录制" forState:UIControlStateNormal];
    }
}

- (void)showTimer {
    timeCount++;
    timeLabel.text = [self timeFormatted:timeCount];
}

#pragma mark AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制...");
    [self showStringHUD:@"开始录制..." second:2];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"视频录制完成.");
    [self showStringHUD:@"视频录制完成." second:2];
    // 视频录制完成后将视频存储到相簿
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"保存视频到相簿过程中发生错误: %@", error.localizedDescription);
            [self showStringHUD:error.localizedDescription second:2];
        } else {
            NSLog(@"成功保存视频到相簿.");
            [self showStringHUD:@"成功保存视频到相簿." second:2];
        }
    }];
}

#pragma mark 私有方法
// 转换成时分秒
- (NSString *)timeFormatted:(NSInteger)totalSeconds {
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    if (totalSeconds >= 3600) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else if (totalSeconds >= 60) {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02ld", (long)seconds];
    }
}

// 生成唯一不重复名称
- (NSString *)returnName {
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormat2 stringFromDate:[NSDate date]];
    return dateStr;
}


@end
