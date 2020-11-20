//
//  TestViewController2.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/11/20.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "TestViewController2.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TestViewController2 ()<AVCaptureFileOutputRecordingDelegate>
{
    AVCaptureSession *captureSession;
    AVCaptureDeviceInput *captureDeviceInput;
    AVCaptureDeviceInput *audioCaptureDeviceInput;
    AVCaptureMovieFileOutput *captureMovieFileOutput;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    
    AVCaptureSession *captureSession2;
    AVCaptureDeviceInput *captureDeviceInput2;
    AVCaptureDeviceInput *audioCaptureDeviceInput2;
    AVCaptureMovieFileOutput *captureMovieFileOutput2;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer2;
    
    NSTimer *timer;
    NSInteger timeCount;
    
    UILabel *timeLabel;
    UIButton *recordButton;
}
@end

@implementation TestViewController2


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setVCTitle:@"自定义录像"];
    self.canHiddenNaviBar = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naviBarChange:) name:@"NaviBarChange" object:nil];
    
    timeCount = 0;
    
    // 注意
    // 同时开启两个自定义相机,只有一个会起作用
    // 不知道是不是因为只有一个摄像头的缘故
    [self configCamara];
    [self configCamara2];
    [self configCamaraButton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (captureSession || captureSession2) {
        [captureSession startRunning];
        [captureSession2 startRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (captureSession || captureSession2) {
        [captureSession stopRunning];
        [captureSession2 stopRunning];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
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

- (void)naviBarChange:(NSNotification *)notify {
    NSDictionary *dict = notify.userInfo;
    if ([dict[@"isHidden"] isEqualToString: @"1"]) {
        [UIView animateWithDuration:0.25 animations:^{
            timeLabel.frame = CGRectMake(15, 20, kScreenWidth - 30, 40);
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            timeLabel.frame = CGRectMake(15, 64, kScreenWidth - 30, 40);
        }];
    }
}

#pragma mark Setup
- (void)configCamara {
    // 1-AVCaptureSession
    captureSession = [[AVCaptureSession alloc] init];
    captureSession.sessionPreset = AVCaptureSessionPreset1280x720;

    // 2-AVCaptureDeviceInput
    // 相机输入设备(默认就是后置摄像头)
    // AVCaptureDevice *camaraCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // AVCaptureDevicePositionBack、AVCaptureDevicePositionFront
    AVCaptureDevice *camaraCaptureDevice = [self cameraWithPosition:AVCaptureDevicePositionFront];
    // 音频输入设备
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    
    NSError *error = nil;
    captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:camaraCaptureDevice error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
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
    // 默认值就是10秒,解决录制超过10秒没声音的Bug
    captureMovieFileOutput.movieFragmentInterval = kCMTimeInvalid;
    
    // 将设备输出添加到会话中
    if ([captureSession canAddOutput:captureMovieFileOutput]) {
        [captureSession addOutput:captureMovieFileOutput];
    }
    
    // 4-AVCaptureVideoPreviewLayer
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    captureVideoPreviewLayer.frame = CGRectMake(0, 0, kScreenWidth / 2, kScreenHeight);
    [self.view.layer addSublayer:captureVideoPreviewLayer];
}

- (void)configCamara2 {
    // 1-AVCaptureSession
    captureSession2 = [[AVCaptureSession alloc] init];
    captureSession2.sessionPreset = AVCaptureSessionPreset1280x720;

    // 2-AVCaptureDeviceInput
    // 相机输入设备
    AVCaptureDevice *camaraCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 音频输入设备
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    
    NSError *error = nil;
    captureDeviceInput2 = [[AVCaptureDeviceInput alloc] initWithDevice:camaraCaptureDevice error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    audioCaptureDeviceInput2 = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    // 将设备输入添加到会话中
    if ([captureSession2 canAddInput:captureDeviceInput2]) {
        [captureSession2 addInput:captureDeviceInput2];
        [captureSession2 addInput:audioCaptureDeviceInput2];
    }
    
    // 3-AVCaptureMovieFileOutput
    captureMovieFileOutput2 = [[AVCaptureMovieFileOutput alloc]init];
    // 默认值就是10秒,解决录制超过10秒没声音的Bug
    captureMovieFileOutput2.movieFragmentInterval = kCMTimeInvalid;
    
    // 将设备输出添加到会话中
    if ([captureSession2 canAddOutput:captureMovieFileOutput2]) {
        [captureSession2 addOutput:captureMovieFileOutput2];
    }
    
    // 4-AVCaptureVideoPreviewLayer
    captureVideoPreviewLayer2 = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession2];
    [captureVideoPreviewLayer2 setVideoGravity:AVLayerVideoGravityResizeAspect];
    captureVideoPreviewLayer2.frame = CGRectMake(kScreenWidth / 2, 0, kScreenWidth / 2, kScreenHeight);
    [self.view.layer addSublayer:captureVideoPreviewLayer2];
}

- (void)configCamaraButton {
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 64, kScreenWidth - 30, 40)];
    timeLabel.text = @"00";
    timeLabel.textColor = [UIColor redColor];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:timeLabel];
    
    CGRect frame = CGRectMake(kScreenWidth / 4, kScreenHeight - 80, kScreenWidth / 2, 60);
    recordButton = [[UIButton alloc] initWithFrame:frame];
    [recordButton setTitle:@"开始录制" forState:UIControlStateNormal];
    [recordButton setBackgroundColor:[UIColor lightGrayColor]];
    recordButton.layer.cornerRadius = 5;
    recordButton.layer.masksToBounds = YES;
    [self.view addSubview:recordButton];
    [recordButton addTarget:self action:@selector(tackCamara) forControlEvents:UIControlEventTouchUpInside];
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
    
    AVCaptureConnection *captureConnection2 = [captureMovieFileOutput2 connectionWithMediaType:AVMediaTypeVideo];
    if (![captureMovieFileOutput isRecording]) {
        // 预览图层和视频方向保持一致
        captureConnection.videoOrientation = [captureVideoPreviewLayer2 connection].videoOrientation;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *rootPaht = [paths objectAtIndex:0];
        NSString *name = [self returnName];
        NSString *outputFielPath = [NSString stringWithFormat:@"%@/郭龙飞/%@.mp4", rootPaht, name];
        NSLog(@"save path is: %@", outputFielPath);
        NSURL *fileUrl = [NSURL fileURLWithPath:outputFielPath];
        [captureMovieFileOutput2 startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        // 定时器
        [self timerState:YES];
    } else {
        [captureMovieFileOutput stopRecording]; // 停止录制
        [self timerState:NO]; // 定时器
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
    timeLabel.text = [GLFTools timeFormatted:timeCount];
}

#pragma mark AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制...");
    [self showStringHUD:@"开始录制..." second:1.5];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"视频录制完成.");
    [self showStringHUD:@"视频录制完成." second:1.5];
    // 视频录制完成后将视频存储到相簿
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"保存视频到相簿过程中发生错误: %@", error.localizedDescription);
            [self showStringHUD:error.localizedDescription second:1.5];
        } else {
            NSLog(@"成功保存视频到相簿.");
            [self showStringHUD:@"成功保存视频到相簿." second:1.5];
        }
    }];
}

#pragma mark 私有方法
// 生成唯一不重复名称
- (NSString *)returnName {
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormat2 stringFromDate:[NSDate date]];
    return dateStr;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}


@end
