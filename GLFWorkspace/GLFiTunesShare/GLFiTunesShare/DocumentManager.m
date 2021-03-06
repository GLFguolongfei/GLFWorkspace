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

static NSString *kQueueOperationsChanged = @"kQueueOperationsChanged";

@interface DocumentManager()<AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL isVideoSeting;
    BOOL isScaleImageSeting;
    
    // 背景音乐
    AVPlayer *player;
    
    // 历史记录
    AVCaptureSession *captureSession;
    AVCaptureDeviceInput *videoCaptureDeviceInput;
    AVCaptureDeviceInput *audioCaptureDeviceInput;
    AVCaptureMovieFileOutput *captureMovieFileOutput;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    
    dispatch_queue_t sample;
    dispatch_queue_t faceQueue;

    UIView *videoView;
}
@end

@implementation DocumentManager

HMSingletonM(DocumentManager)


#pragma mark - 文件操作
+ (void)eachAllFiles {
    @synchronized(self) { // ------ 加互斥锁
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
            NSMutableArray *allOthersArray = [[NSMutableArray alloc] init]; // 非图片、非视频，即为其它
            NSMutableArray *allDYVideosArray = [[NSMutableArray alloc] init];
            NSMutableArray *allNoDYVideosArray = [[NSMutableArray alloc] init];
            CGFloat allSize = 0;
            CGFloat allImagesSize = 0;
            CGFloat allVideosSize = 0;
            CGFloat allOthersSize = 0;
            CGFloat allDYVideosSize = 0;
            CGFloat allNoDYVideosSize = 0;
            NSArray *array = [GLFFileManager searchSubFile:path andIsDepth:YES];
            for (int i = 0; i < array.count; i++) {
                // 当其他程序让本程序打开文件时,会自动生成一个Inbox文件夹
                // 这个文件夹是系统权限,不能删除,只可以删除里面的文件,因此这里隐藏好了
                if ([array[i] isEqualToString:@"Inbox"]) {
                    continue;
                }
                NSArray *names = [array[i] componentsSeparatedByString:@"/"];
                if ([hidden isEqualToString:@"0"] && [CHiddenPaths containsObject:names.firstObject]) {
                    continue;
                }
                FileModel *model = [[FileModel alloc] init];
                model.name = array[i];
                model.path = [NSString stringWithFormat:@"%@/%@", path, model.name];
                model.attributes = [GLFFileManager attributesOfItemAtPath:model.path];
                // 是否为隐藏目录(注意：Inbox目录不是隐藏目录)
                NSNumber *isHidden = (NSNumber *)model.attributes[@"NSFileExtensionHidden"];
                if (isHidden.integerValue == 1) {
                    continue;
                }
                // 文件类型
                NSInteger fileType = [GLFFileManager fileExistsAtPath:model.path];
                if (fileType == 1) { // 文件
                    model.size = [GLFFileManager fileSize:model.path];
                    NSArray *array = [model.name componentsSeparatedByString:@"."];
                    NSString *lowerType = [array.lastObject lowercaseString];
                    if ([CimgTypeArray containsObject:lowerType]) {
                        // model.image = [UIImage imageWithContentsOfFile:model.path];
                        model.type = 2;
                        allImagesSize += model.size;
                        [allImagesArray addObject:model];
                    } else if ([CvideoTypeArray containsObject:lowerType]) {
                        // #if FirstTarget
                        //      model.image = [GLFTools thumbnailImageRequest:9 andVideoPath:model.path];
                        // #else
                        //      model.image = [GLFTools thumbnailImageRequest:90 andVideoPath:model.path];
                        // #endif
                        model.type = 3;
                        allVideosSize += model.size;
                        [allVideosArray addObject:model];
                        CGSize size = [GLFTools videoSizeWithPath:model.path];
                        model.videoSize = size;
                        
                        if ((size.width / size.height) < ((kScreenWidth + kScreenWidth / 3) / kScreenHeight)) {
                            allDYVideosSize += model.size;
                            [allDYVideosArray addObject:model];
                        } else {
                            allNoDYVideosSize += model.size;
                            [allNoDYVideosArray addObject:model];
                        }
                    } else {
                        model.type = 4;
                        allOthersSize += model.size;
                        [allOthersArray addObject:model];
                    }
                    allSize += model.size;
                    [allFilesArray addObject:model];
                } else if (fileType == 2) { // 文件夹
                    model.type = 1;
                    model.size = [GLFFileManager fileSizeForDir:model.path];
                    model.count = [model.attributes[@"NSFileReferenceCount"] integerValue];
                    [allFoldersArray addObject:model];
                }
            }
            // 排序为：文件夹、视频、图片、其它
            [allArray addObjectsFromArray:allFoldersArray];
            [allArray addObjectsFromArray:allVideosArray];
            [allArray addObjectsFromArray:allImagesArray];
            [allArray addObjectsFromArray:allOthersArray];
            // 遍历用时
            NSDate *endDate = [NSDate date];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            NSDateComponents *cmps = [calendar components:type fromDate:startDate toDate:endDate options:0];
            // 本地推送
            NSString *allSizeStr = [GLFFileManager returenSizeStr:allSize];
            NSString *str = [NSString stringWithFormat:@"总用时: %ld分%ld秒 总大小: %@", cmps.minute, cmps.second, allSizeStr];
            NSLog(@"全局遍历完成, %@", str);

//            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//            content.title = @"全局遍历完成";
//            content.body = str;
//            // content.sound = [UNNotificationSound defaultSound];
//            content.userInfo = @{@"key1":@"value1",@"key2":@"value2"};
//
//            UNTimeIntervalNotificationTrigger *intervalTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
//            NSString *requestIdentifier = @"Dely.X.time";
//            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:intervalTrigger];
//
//            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//                if (!error) {
//                    NSLog(@"本地推送添加成功: %@", requestIdentifier);
//                }
//            }];
//
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
            NSString *archiverPath6 = [path stringByAppendingPathComponent:@"GLFConfig/allOthersArray.plist"];
            BOOL isSuccess6 = [NSKeyedArchiver archiveRootObject:allOthersArray toFile:archiverPath6];
            NSString *archiverPath7 = [path stringByAppendingPathComponent:@"GLFConfig/allDYVideosArray.plist"];
            BOOL isSuccess7 = [NSKeyedArchiver archiveRootObject:allDYVideosArray toFile:archiverPath7];
            NSString *archiverPath8 = [path stringByAppendingPathComponent:@"GLFConfig/allNoDYVideosArray.plist"];
            BOOL isSuccess8 = [NSKeyedArchiver archiveRootObject:allNoDYVideosArray toFile:archiverPath8];
            if (isSuccess1 & isSuccess2 & isSuccess3 & isSuccess4 & isSuccess5 & isSuccess6 & isSuccess7 & isSuccess8) {
                NSLog(@"archiver success");
                NSDictionary *userInfo = @{@"time": str};
                [[NSNotificationCenter defaultCenter] postNotificationName:DocumentFileArrayUpdate object:self userInfo:userInfo];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                // 数量
                [userDefaults setInteger:allArray.count forKey:@"AllCount"];
                [userDefaults setInteger:allFoldersArray.count forKey:@"AllFoldersCount"];
                [userDefaults setInteger:allFilesArray.count forKey:@"AllFilesCount"];
                [userDefaults setInteger:allImagesArray.count forKey:@"AllImagesCount"];
                [userDefaults setInteger:allVideosArray.count forKey:@"AllVideosCount"];
                [userDefaults setInteger:allOthersArray.count forKey:@"AllOthersCount"];
                [userDefaults setInteger:allDYVideosArray.count forKey:@"AllDYVideosCount"];
                [userDefaults setInteger:allNoDYVideosArray.count forKey:@"AllNoDYVideosCount"];
                // 大小
                [userDefaults setValue:@(allSize) forKey:@"AllSize"];
                [userDefaults setValue:@(allImagesSize) forKey:@"AllImagesSize"];
                [userDefaults setValue:@(allVideosSize) forKey:@"AllVideosSize"];
                [userDefaults setValue:@(allOthersSize) forKey:@"AllOthersSize"];
                [userDefaults setValue:@(allDYVideosSize) forKey:@"AllDYVideosSize"];
                [userDefaults setValue:@(allNoDYVideosSize) forKey:@"AllNoDYVideosSize"];
                [userDefaults synchronize];
            } else {
                NSLog(@"archiver error");
            }
        });
    }
}

+ (void)updateDocumentPaths {
    @synchronized(self) { // ------ 加互斥锁
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [paths objectAtIndex:0];
        
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
                    NSArray *names = [array[i] componentsSeparatedByString:@"/"];
                    if ([hidden isEqualToString:@"0"] && [CHiddenPaths containsObject:names.firstObject]) {
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

+ (void)favoriteModel:(FileModel *)model {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteArray = [userDefaults objectForKey:kFavorite];
    if (!favoriteArray) {
        favoriteArray = [[NSMutableArray alloc] init];
    } else {
        favoriteArray = [favoriteArray mutableCopy];
    }
    if ([favoriteArray containsObject:model.name]) {
        [favoriteArray removeObject:model.name];
    } else {
        [favoriteArray addObject:model.name];
    }
    [userDefaults setObject:favoriteArray forKey:kFavorite];
    [userDefaults synchronize];
}

+ (void)removeModel:(FileModel *)model {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *removeArray = [userDefaults objectForKey:kRemove];
    if (!removeArray) {
        removeArray = [[NSMutableArray alloc] init];
    } else {
        removeArray = [removeArray mutableCopy];
    }
    if ([removeArray containsObject:model.name]) {
        [removeArray removeObject:model.name];
    } else {
        [removeArray addObject:model.name];
    }
    [userDefaults setObject:removeArray forKey:kRemove];
    [userDefaults synchronize];
}

+ (void)getAllArray:(CallBack)callBack {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *archiverPath = [path stringByAppendingPathComponent:@"GLFConfig/allArray.plist"];
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:archiverPath];
        for (NSInteger i = 0; i < array.count; i++) {
            FileModel *model = array[i];
            // 注意: 每次运行path的哈希码都会变化,因此要重新赋值
            model.path = [NSString stringWithFormat:@"%@/%@", path, model.name];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBack) {
                callBack(array);
            }
        });
    });
}
+ (void)getAllFoldersArray:(CallBack)callBack {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *archiverPath = [path stringByAppendingPathComponent:@"GLFConfig/allFoldersArray.plist"];
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:archiverPath];
        for (NSInteger i = 0; i < array.count; i++) {
            FileModel *model = array[i];
            // 注意: 每次运行path的哈希码都会变化,因此要重新赋值
            model.path = [NSString stringWithFormat:@"%@/%@", path, model.name];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBack) {
                callBack(array);
            }
        });
    });
}
+ (void)getAllFilesArray:(CallBack)callBack {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *archiverPath = [path stringByAppendingPathComponent:@"GLFConfig/allFilesArray.plist"];
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:archiverPath];
        for (NSInteger i = 0; i < array.count; i++) {
            FileModel *model = array[i];
            // 注意: 每次运行path的哈希码都会变化,因此要重新赋值
            model.path = [NSString stringWithFormat:@"%@/%@", path, model.name];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBack) {
                callBack(array);
            }
        });
    });
}
+ (void)getAllImagesArray:(CallBack)callBack {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *archiverPath = [path stringByAppendingPathComponent:@"GLFConfig/allImagesArray.plist"];
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:archiverPath];
        for (NSInteger i = 0; i < array.count; i++) {
            FileModel *model = array[i];
            // 注意: 每次运行path的哈希码都会变化,因此要重新赋值
            model.path = [NSString stringWithFormat:@"%@/%@", path, model.name];
            model.image = [UIImage imageWithContentsOfFile:model.path];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBack) {
                callBack(array);
            }
        });
    });
}
+ (void)getAllImagesArray:(CallBack)callBack startIndex:(NSInteger)imgStart lengthCount:(NSInteger)imgLength {
    __block NSInteger imgIndex = imgStart;
    __block NSInteger count = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *archiverPath = [path stringByAppendingPathComponent:@"GLFConfig/allImagesArray.plist"];
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:archiverPath];
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        if (imgIndex > array.count-1) {
            imgIndex = 0;
        }
        for (NSInteger i = imgIndex; i < array.count; i++) {
            if (count > imgLength) {
                break;
            }
            count++;
            FileModel *model = array[i];
            // 注意: 每次运行path的哈希码都会变化,因此要重新赋值
            model.path = [NSString stringWithFormat:@"%@/%@", path, model.name];
            model.image = [UIImage imageWithContentsOfFile:model.path];
            [resultArray addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBack) {
                callBack(resultArray);
            }
        });
    });
}
+ (void)getAllVideosArray:(CallBack)callBack {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *archiverPath = [path stringByAppendingPathComponent:@"GLFConfig/allVideosArray.plist"];
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:archiverPath];
        for (NSInteger i = 0; i < array.count; i++) {
            FileModel *model = array[i];
            // 注意: 每次运行path的哈希码都会变化,因此要重新赋值
            model.path = [NSString stringWithFormat:@"%@/%@", path, model.name];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBack) {
                callBack(array);
            }
        });
    });
}
+ (void)getAllDYVideosArray:(CallBack)callBack {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *archiverPath = [path stringByAppendingPathComponent:@"GLFConfig/allDYVideosArray.plist"];
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:archiverPath];
        for (NSInteger i = 0; i < array.count; i++) {
            FileModel *model = array[i];
            // 注意: 每次运行path的哈希码都会变化,因此要重新赋值
            model.path = [NSString stringWithFormat:@"%@/%@", path, model.name];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBack) {
                callBack(array);
            }
        });
    });
}
+ (void)getAllNoDYVideosArray:(CallBack)callBack {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *archiverPath = [path stringByAppendingPathComponent:@"GLFConfig/allNoDYVideosArray.plist"];
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:archiverPath];
        for (NSInteger i = 0; i < array.count; i++) {
            FileModel *model = array[i];
            // 注意: 每次运行path的哈希码都会变化,因此要重新赋值
            model.path = [NSString stringWithFormat:@"%@/%@", path, model.name];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBack) {
                callBack(array);
            }
        });
    });
}

#pragma mark - 其它
// 获取背景图
+ (UIImage *)getBackgroundImage {
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
        backImage = [UIImage imageNamed:@"bgview"];
        [userDefaults setObject:@"bgview" forKey:BackImageName];
        [userDefaults synchronize];
    }
    return backImage;
}

// 获取文件mimeType
+ (NSString *)mimeTypeForFileAtPath1:(NSString *)path {
    // 1-创建一个请求
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 2-发送请求(返回响应)
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    // 3-获得MIMEType
    return response.MIMEType;
}

+ (NSString *)mimeTypeForFileAtPath2:(NSString *)path {
    if (![[[NSFileManager alloc] init] fileExistsAtPath:path]) {
        return nil;
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)(MIMEType);
}

// 视频合并
+ (void)mergeVideos:(NSArray *)videosPathArray withOutPath:(NSString*)outpath andCallBack:(CallBack)callBack {
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    // 音频轨道
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    // 视频轨道
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime totalDuration = kCMTimeZero;
    for(int i = 0; i < videosPathArray.count; i++) {
        // AVURLAsset
        // AVAsset的子类,主要用于获取多媒体的信息,包括视频、音频的类型、时长、每秒帧数
        // 其实还可以用来获取视频的指定位置的缩略图
        NSURL *url = [NSURL fileURLWithPath:videosPathArray[i]];
        AVURLAsset *asset = [AVURLAsset assetWithURL:url];
        NSError *erroraudio = nil;
        NSError *errorVideo = nil;
        // 获取AVAsset中的音频
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        // 向通道内加入音频
        BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetAudioTrack atTime:totalDuration error:&erroraudio];
        if (!ba) {
            NSLog(@"erroraudio:%@ %d", erroraudio, ba);
        }
        // 获取AVAsset中的视频
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
        // 向通道内加入视频
        BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetVideoTrack atTime:totalDuration error:&errorVideo];
        if (!bl) {
            NSLog(@"errorVideo:%@ %d", errorVideo, bl);
        }
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
    }
    // 创建合成后写入的路劲
    NSURL *mergeFileURL = [NSURL fileURLWithPath:outpath];
    if([[NSFileManager defaultManager] fileExistsAtPath:outpath]) {
        NSLog(@"有文件");
        return;
    }
    // 这里开始导出合成后的视频
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset640x480];
    exporter.outputURL = mergeFileURL;
    NSLog(@"%@", exporter.supportedFileTypes);
//    if([self.type isEqualToString:@"mp4"]) {
        exporter.outputFileType = AVFileTypeMPEG4;
//    } else {
//        exporter.outputFileType = AVFileTypeQuickTimeMovie;
//    }
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch(exporter.status) {
            case AVAssetExportSessionStatusUnknown: {
                NSLog(@"exporter Unknow");
                break;
            }
            case AVAssetExportSessionStatusWaiting: {
                NSLog(@"exporter Waiting");
                break;
            }
            case AVAssetExportSessionStatusExporting: {
                NSLog(@"exporter Exporting");
                break;
            }
            case AVAssetExportSessionStatusCompleted: { // 导出成功
                NSLog(@"exporter Completed");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callBack) {
                        callBack(@[]);
                    }
                });
                break;
            }
            case AVAssetExportSessionStatusFailed: {
                NSLog(@"exporter Failed");
                break;
            }
            case AVAssetExportSessionStatusCancelled: {
                NSLog(@"exporter Canceled");
                break;
            }
        }
    }];
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
        
        // 获取路径
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr = [dateFormat stringFromDate:[NSDate date]];
        [dateFormat setDateFormat:@"HH:mm:ss"];
        NSString *timeStr = [dateFormat stringFromDate:[NSDate date]];
        NSString *outputFielPath = [NSString stringWithFormat:@"%@/郭龙飞/%@/%@.mp4", rootPaht, dateStr, timeStr];
        NSLog(@"save path is: %@", outputFielPath);
        
        // 如果不是文件夹,那就创建,创建失败就用以前的
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [NSString stringWithFormat:@"%@/郭龙飞/%@", rootPaht, dateStr];
        BOOL isDerectary;
        BOOL exist = [fileManager fileExistsAtPath:path isDirectory:&isDerectary];
        if (exist && isDerectary) {
            NSURL *fileUrl = [NSURL fileURLWithPath:outputFielPath];
            [captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        } else {
            BOOL success = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            if (success) {
                NSURL *fileUrl = [NSURL fileURLWithPath:outputFielPath];
                [captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
            } else {
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *str = [dateFormat stringFromDate:[NSDate date]];
                outputFielPath = [NSString stringWithFormat:@"%@/郭龙飞/%@.mp4", rootPaht, str];
                
                NSURL *fileUrl = [NSURL fileURLWithPath:outputFielPath];
                [captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CamerIsRecording" object:self userInfo:nil];
}

// 结束录制
- (void)stopRecording {
    if ([captureMovieFileOutput isRecording]) {
        [captureMovieFileOutput stopRecording]; // 停止录制
        [captureSession stopRunning]; // 关闭摄像头
        [self configCamara:NO];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CamerIsRecording" object:self userInfo:nil];
}

// 切换前后摄像头
- (void)switchCamera {
    self.isUseBackFacingCamera = !self.isUseBackFacingCamera;
    [self startRecording];
}

- (void)configCamara:(BOOL)isRecord {
    if (!isRecord) {
        captureSession = nil;
        videoCaptureDeviceInput = nil;
        audioCaptureDeviceInput = nil;
        captureMovieFileOutput = nil;
        captureVideoPreviewLayer = nil;
        [captureVideoPreviewLayer removeFromSuperlayer];
        return;
    }
    
    sample = dispatch_queue_create("sample", NULL);
    faceQueue = dispatch_queue_create("face", NULL);
    
    // 1-AVCaptureDeviceInput
    // 相机输入设备
    AVCaptureDevicePosition desiredPosition;
    if (self.isUseBackFacingCamera) {
        desiredPosition = AVCaptureDevicePositionBack;
    } else {
        desiredPosition = AVCaptureDevicePositionFront;
    }
    AVCaptureDevice *videoCaptureDevice = [self getCameraDeviceWithPosition:desiredPosition];
    // 音频输入设备
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    
    NSError *error = nil;
    videoCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoCaptureDevice error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    // 2-AVCaptureMovieFileOutput
    captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    // 默认值就是10秒,解决录制超过10秒没声音的Bug
    captureMovieFileOutput.movieFragmentInterval = kCMTimeInvalid;
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [output setSampleBufferDelegate:self queue:sample];
    
    AVCaptureMetadataOutput *metaout = [[AVCaptureMetadataOutput alloc] init];
    [metaout setMetadataObjectsDelegate:self queue:faceQueue];
    
    // 3-AVCaptureSession
    captureSession = [[AVCaptureSession alloc] init];
    captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    
    [captureSession beginConfiguration];

    // 将设备输入添加到会话中
    if ([captureSession canAddInput:videoCaptureDeviceInput]) {
        [captureSession addInput:videoCaptureDeviceInput];
        [captureSession addInput:audioCaptureDeviceInput];
    }
    
    // 将设备输出添加到会话中
    if ([captureSession canAddOutput:captureMovieFileOutput]) {
        [captureSession addOutput:captureMovieFileOutput];
    }
    
    if ([captureSession canAddOutput:output]) {
        [captureSession addOutput:output];
    }
    if ([captureSession canAddOutput:metaout]) {
        [captureSession addOutput:metaout];
    }
    
    [captureSession commitConfiguration];

    // 其它
    NSString *key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
    NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [output setVideoSettings:videoSettings];
    
    // 这里我们告诉要检测到人脸就给我一些反应,里面还有QRCode等,都可以放进去
    // 就是如果视频流检测到了你要的,就会出发下面第二个代理方法
    [metaout setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
    
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

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSMutableArray *bounds = [NSMutableArray arrayWithCapacity:0];
    // 每一帧,我们都看一下self.currentMetadata里面有没有东西
    // 然后将里面的AVMetadataFaceObject转换成AVMetadataObject
    // 其中AVMetadataObject的bouns就是人脸的位置,我们将bouns存到数组中
    for (AVMetadataFaceObject *faceobject in self.currentMetadata) {
        AVMetadataObject *face = [output transformedMetadataObjectForMetadataObject:faceobject connection:connection];
        [bounds addObject:[NSValue valueWithCGRect:face.bounds]];
    }
    if (bounds.count > 0) {
        self.isHaveFace = YES;
//        NSLog(@"人脸位置 %@", bounds);
    } else {
        self.isHaveFace = NO;
    }
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 当检测到了人脸会走这个回调
    self.currentMetadata = metadataObjects;
    if (metadataObjects.count > 0) {
        self.isHaveFace = YES;
//        NSLog(@"检测到了人脸 %@", self.currentMetadata);
    } else {
        self.isHaveFace = NO;
    }
}

#pragma mark - 私有方法
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
