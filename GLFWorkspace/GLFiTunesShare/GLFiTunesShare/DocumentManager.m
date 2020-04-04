//
//  DocumentManager.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/15.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "DocumentManager.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface DocumentManager()<AVCaptureFileOutputRecordingDelegate>
{
    BOOL isVideoSeting;
    BOOL isScaleImageSeting;
    
    // 背景音乐
    AVPlayer *player;
    
    // 历史记录
    AVCaptureSession *captureSession;
    AVCaptureDeviceInput *captureDeviceInput;
    AVCaptureDeviceInput *audioCaptureDeviceInput;
    AVCaptureMovieFileOutput *captureMovieFileOutput;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
        
    UIView *videoView;
}
@end

@implementation DocumentManager

HMSingletonM(DocumentManager)


#pragma mark - 文件操作
+ (void)eachAllFiles {    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *hidden = [userDefaults objectForKey:kContentHidden];
    
    NSDate *startDate = [NSDate date];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSLog(@"全局遍历开始");
        NSMutableArray *allArray = [[NSMutableArray alloc] init];
        NSMutableArray *allFoldersArray = [[NSMutableArray alloc] init];
        NSMutableArray *allFilesArray = [[NSMutableArray alloc] init];
        NSMutableArray *allImagesArray = [[NSMutableArray alloc] init];
        NSMutableArray *allVideosArray = [[NSMutableArray alloc] init];
        NSMutableArray *allDYVideosArray = [[NSMutableArray alloc] init];
        NSMutableArray *allNoDYVideosArray = [[NSMutableArray alloc] init];
        NSArray *array = [GLFFileManager searchSubFile:path andIsDepth:YES];
        for (int i = 0; i < array.count; i++) {
            // 当其他程序让本程序打开文件时,会自动生成一个Inbox文件夹
            // 这个文件夹是系统权限,不能删除,只可以删除里面的文件,因此这里隐藏好了
            if ([array[i] isEqualToString:@"Inbox"]) {
                continue;
            }
            if ([hidden isEqualToString:@"0"] && [CHiddenPaths containsObject:array[i]]) {
                continue;
            }
            FileModel *model = [[FileModel alloc] init];
            model.name = array[i];
            model.path = [NSString stringWithFormat:@"%@/%@", path, model.name];
            model.attributes = [GLFFileManager attributesOfItemAtPath:model.path];
            NSInteger fileType = [GLFFileManager fileExistsAtPath:model.path];
            if (fileType == 1) { // 文件
                model.size = [GLFFileManager fileSize:model.path];
                NSArray *array = [model.name componentsSeparatedByString:@"."];
                NSString *lowerType = [array.lastObject lowercaseString];
                if ([CimgTypeArray containsObject:lowerType]) {
                    model.type = 2;
//                    model.image = [UIImage imageWithContentsOfFile:model.path];
                    [allImagesArray addObject:model];
                } else if ([CvideoTypeArray containsObject:lowerType]) {
                    model.type = 3;
//                    #if FirstTarget
//                        model.image = [GLFTools thumbnailImageRequest:9 andVideoPath:model.path];
//                    #else
//                        model.image = [GLFTools thumbnailImageRequest:90 andVideoPath:model.path];
//                    #endif
                    [allVideosArray addObject:model];
                    CGSize size = [GLFTools videoSizeWithPath:model.path];
                    model.videoSize = size;
                    
                    NSArray *array = [model.name componentsSeparatedByString:@"/"];
                    NSString *name = array.firstObject;
                    if ([name isEqualToString:@"抖音"]) {
                        [allDYVideosArray addObject:model];
                    } else if ((size.width / size.height) < ((kScreenWidth + 200) / kScreenHeight)) {
                        [allDYVideosArray addObject:model];
                    } else {
                        [allNoDYVideosArray addObject:model];
                    }
                } else {
                    model.type = 4;
                }
                [allFilesArray addObject:model];
            } else if (fileType == 2) { // 文件夹
                model.type = 1;
                model.size = [GLFFileManager fileSizeForDir:model.path];
                model.count = [model.attributes[@"NSFileReferenceCount"] integerValue];
                [allFoldersArray addObject:model];
                if ([model.name isEqualToString:@"郭龙飞"] && model.size > 1000000000) {
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.title = @"存储通知";
                    content.subtitle = [NSString stringWithFormat:@"存储过大"];
                    content.body = @"存储的东西太多了";
                    content.badge = @1;
                    content.sound = [UNNotificationSound defaultSound];
                    content.userInfo = @{@"key1":@"value1",@"key2":@"value2"};
                    
                    UNTimeIntervalNotificationTrigger *intervalTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
                    NSString *requestIdentifier = @"Dely.X.time";
                    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:intervalTrigger];
                    
                    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                        if (!error) {
                            NSLog(@"本地推送添加成功: %@", requestIdentifier);
                        }
                    }];
                }
            }
        }
        // 显示文件夹排在前面
        [allArray addObjectsFromArray:allFoldersArray];
        [allArray addObjectsFromArray:allFilesArray];
        // 遍历用时
        NSDate *endDate = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *cmps = [calendar components:type fromDate:startDate toDate:endDate options:0];
        NSLog(@"全局遍历完成,一共用时: %ld分钟%ld秒", cmps.minute, cmps.second);
        
        NSString *archiverPath1 = [path stringByAppendingPathComponent:@"GLFConfig/allArray.plist"];
        BOOL isSuccess1 = [NSKeyedArchiver archiveRootObject:allArray toFile:archiverPath1];
        NSString *archiverPath2 = [path stringByAppendingPathComponent:@"GLFConfig/allFoldersArray.plist"];
        BOOL isSuccess2 = [NSKeyedArchiver archiveRootObject:allFoldersArray toFile:archiverPath2];
        NSString *archiverPath3 = [path stringByAppendingPathComponent:@"GLFConfig/allFilesArray.plist"];
        BOOL isSuccess3 = [NSKeyedArchiver archiveRootObject:allFilesArray toFile:archiverPath3];
        NSString *archiverPath4 = [path stringByAppendingPathComponent:@"GLFConfig/allImagesArray.plist"];
        BOOL isSuccess4 = [NSKeyedArchiver archiveRootObject:allImagesArray toFile:archiverPath4];
        NSString *archiverPath5 = [path stringByAppendingPathComponent:@"GLFConfig/allVideosArray.plist"];
        BOOL isSuccess5 = [NSKeyedArchiver archiveRootObject:allVideosArray toFile:archiverPath5];
        NSString *archiverPath6 = [path stringByAppendingPathComponent:@"GLFConfig/allDYVideosArray.plist"];
        BOOL isSuccess6 = [NSKeyedArchiver archiveRootObject:allDYVideosArray toFile:archiverPath6];
        NSString *archiverPath7 = [path stringByAppendingPathComponent:@"GLFConfig/allNoDYVideosArray.plist"];
        BOOL isSuccess7 = [NSKeyedArchiver archiveRootObject:allNoDYVideosArray toFile:archiverPath7];
        if (isSuccess1 & isSuccess2 & isSuccess3 & isSuccess4 & isSuccess5 & isSuccess6 & isSuccess7) {
            NSLog(@"archiver success");
        } else {
            NSLog(@"archiver error");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
}

- (void)addFavoriteModel:(FileModel *)model {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteArray = [userDefaults objectForKey:kFavorite];
    if (!favoriteArray) {
        favoriteArray = [[NSMutableArray alloc] init];
    } else {
        favoriteArray = [favoriteArray mutableCopy];
    }
    [favoriteArray addObject:model.name];
    [userDefaults setObject:favoriteArray forKey:kFavorite];
    [userDefaults synchronize];
}

- (void)removeFavoriteModel:(FileModel *)model {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteArray = [userDefaults objectForKey:kFavorite];
    if (!favoriteArray) {
        favoriteArray = [[NSMutableArray alloc] init];
    } else {
        favoriteArray = [favoriteArray mutableCopy];
    }
    [favoriteArray removeObject:model.name];
    [userDefaults setObject:favoriteArray forKey:kFavorite];
    [userDefaults synchronize];
}

- (void)addRemoveModel:(FileModel *)model {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *removeArray = [userDefaults objectForKey:kRemove];
    if (!removeArray) {
        removeArray = [[NSMutableArray alloc] init];
    } else {
        removeArray = [removeArray mutableCopy];
    }
    [removeArray addObject:model.name];
    [userDefaults setObject:removeArray forKey:kRemove];
    [userDefaults synchronize];
}

- (void)removeRemoveModel:(FileModel *)model {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *removeArray = [userDefaults objectForKey:kRemove];
    if (!removeArray) {
        removeArray = [[NSMutableArray alloc] init];
    } else {
        removeArray = [removeArray mutableCopy];
    }
    [removeArray removeObject:model.name];
    [userDefaults setObject:removeArray forKey:kRemove];
    [userDefaults synchronize];
}

+ (void)updateDocumentPaths {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    // 遍历
    @synchronized(self) { // ------ 加互斥锁
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *hidden = [userDefaults objectForKey:kContentHidden];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSArray *array = [GLFFileManager searchSubFile:documentPath andIsDepth:YES];
            NSMutableArray *documentPathArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < array.count; i++) {
                NSString *path = [NSString stringWithFormat:@"%@/%@", documentPath, array[i]];
                NSInteger fileType = [GLFFileManager fileExistsAtPath:path];
                if (fileType == 2) { // 只显示文件夹
                    if ([hidden isEqualToString:@"0"] && [CHiddenPaths containsObject:array[i]]) {
                        continue;
                    } else {
                        [documentPathArray addObject:array[i]];
                    }
                }
            }
            [[NSUserDefaults standardUserDefaults] setObject:documentPathArray forKey:DocumentPathArray];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:DocumentPathArrayUpdate object:self userInfo:nil];
            });
        });
    }
}

#pragma mark - 背景音乐
- (void)startPlay {
    if (player) {
        [player play];
    } else {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"陈一发儿-童话镇.mp3" withExtension:nil];
        player = [[AVPlayer alloc] initWithURL:url];
        [player play];
    }
}

- (void)stopPlay {
    [player pause];
}

#pragma mark - 历史记录
- (BOOL)isRecording {
    if (captureMovieFileOutput) {
        return [captureMovieFileOutput isRecording];
    } else {
        return NO;
    }
}

// 开始录制
- (void)startRecording {
    [self configCamara:YES];
    AVCaptureConnection *captureConnection = [captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if (![captureMovieFileOutput isRecording]) {
        [captureSession startRunning]; // 开启摄像头
        // 预览图层和视频方向保持一致
        captureConnection.videoOrientation = [captureVideoPreviewLayer connection].videoOrientation;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *rootPaht = [paths objectAtIndex:0];
        NSString *name = [self returnName];
        NSString *outputFielPath = [NSString stringWithFormat:@"%@/郭龙飞/%@.mp4", rootPaht, name];
        // NSLog(@"save path is: %@", outputFielPath);
        NSURL *fileUrl = [NSURL fileURLWithPath:outputFielPath];
        [captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
    }
}

// 结束录制
- (void)stopRecording {
    if ([captureMovieFileOutput isRecording]) {
        [captureMovieFileOutput stopRecording]; // 停止录制
        [captureSession stopRunning]; // 关闭摄像头
        [self configCamara:NO];
    }
}

// 切换前后摄像头
- (void)switchCamera {
    self.isUseBackFacingCamera = !self.isUseBackFacingCamera;
    [self startRecording];
}

- (void)configCamara:(BOOL)isRecord {
    if (!isRecord) {
        captureSession = nil;
        captureDeviceInput = nil;
        audioCaptureDeviceInput = nil;
        captureMovieFileOutput = nil;
        captureVideoPreviewLayer = nil;
        [captureVideoPreviewLayer removeFromSuperlayer];
        return;
    }
    // 1-AVCaptureSession
    captureSession = [[AVCaptureSession alloc] init];
    captureSession.sessionPreset = AVCaptureSessionPreset1280x720;

    // 2-AVCaptureDeviceInput
    // 相机输入设备
    AVCaptureDevicePosition desiredPosition;
    if (self.isUseBackFacingCamera) {
        desiredPosition = AVCaptureDevicePositionBack;
    } else {
        desiredPosition = AVCaptureDevicePositionFront;
    }
    AVCaptureDevice *camaraCaptureDevice = [self getCameraDeviceWithPosition:desiredPosition];
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
    captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    // 默认值就是10秒,解决录制超过10秒没声音的Bug
    captureMovieFileOutput.movieFragmentInterval = kCMTimeInvalid;
    
    // 将设备输出添加到会话中
    if ([captureSession canAddOutput:captureMovieFileOutput]) {
        [captureSession addOutput:captureMovieFileOutput];
    }
    
    // 4-AVCaptureVideoPreviewLayer
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    captureVideoPreviewLayer.frame = CGRectMake(0, 0, 0, 0);
    
    videoView = [[UIView alloc] init];
    [videoView.layer addSublayer:captureVideoPreviewLayer];
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
    return dateStr;
}

// 返回压缩比例
- (CGFloat)returnScaleSize:(CGFloat)fileSize {
    CGFloat scale = 0.1;
    if (fileSize < 1000000) {
        scale = 1;
    } else if (fileSize < 5000000) {
        scale = 0.2;
    } else {
        scale = 0.1;
    }
    return scale;
}


@end
