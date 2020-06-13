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
    @synchronized(self) { // ------ 加互斥锁
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        
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
                NSArray *names = [array[i] componentsSeparatedByString:@"/"];
                if ([CHiddenPaths containsObject:names.firstObject]) {
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
                        // model.image = [UIImage imageWithContentsOfFile:model.path];
                        [allImagesArray addObject:model];
                    } else if ([CvideoTypeArray containsObject:lowerType]) {
                        model.type = 3;
                        // #if FirstTarget
                        //      model.image = [GLFTools thumbnailImageRequest:9 andVideoPath:model.path];
                        // #else
                        //      model.image = [GLFTools thumbnailImageRequest:90 andVideoPath:model.path];
                        // #endif
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
            NSLog(@"全局遍历完成,一共用时: %ld分%ld秒", cmps.minute, cmps.second);
            // 本地推送
            CGFloat allSize = 0;
            for (NSInteger i = 0; i < allArray.count; i++) {
                FileModel *model = allArray[i];
                allSize += model.size;
            }
            NSString *sizeStr = [GLFFileManager returenSizeStr:allSize];
            NSString *str = [NSString stringWithFormat:@"遍历完成 总用时: %ld分%ld秒 总大小: %@", cmps.minute, cmps.second, sizeStr];
            
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.title = @"遍历完成";
//            content.subtitle = [NSString stringWithFormat:@"存储过大"];
            content.body = str;
            content.badge = @1;
            content.sound = [UNNotificationSound defaultSound];
            content.userInfo = @{@"key1":@"value1",@"key2":@"value2"};
            
            UNTimeIntervalNotificationTrigger *intervalTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
            NSString *requestIdentifier = @"Dely.X.time";
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:intervalTrigger];
            
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"本地推送添加成功: %@", requestIdentifier);
                }
            }];
            
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
        });
    }
}

+ (void)updateDocumentPaths {
    @synchronized(self) { // ------ 加互斥锁
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [paths objectAtIndex:0];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSArray *array = [GLFFileManager searchSubFile:documentPath andIsDepth:YES];
            NSMutableArray *documentPathArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < array.count; i++) {
                NSString *path = [NSString stringWithFormat:@"%@/%@", documentPath, array[i]];
                NSInteger fileType = [GLFFileManager fileExistsAtPath:path];
                if (fileType == 2) { // 只显示文件夹
                    NSArray *names = [array[i] componentsSeparatedByString:@"/"];
                    if ([CHiddenPaths containsObject:names.firstObject]) {
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

+ (void)addFavoriteModel:(FileModel *)model {
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

+ (void)removeFavoriteModel:(FileModel *)model {
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

+ (void)addRemoveModel:(FileModel *)model {
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

+ (void)removeRemoveModel:(FileModel *)model {
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

+ (void)getNetworkData {
    __block NSInteger startIndex = 4000;
    NSInteger endIndex = startIndex + 200;

    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    for (NSInteger i = startIndex; i < endIndex; i++) {
        NSString *urlStr = [NSString stringWithFormat:@"http://www.38ppd.com/zpmp4.x?stype=zpmp4&zpmp4id=%ld", i];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            startIndex++;
            if (str != nil) {
                NSRange range1 = [str rangeOfString:@"<source src="];
                NSRange range2 = [str rangeOfString:@"type=\"video/mp4\""];
                if (range1.length > 0 && range2.length > 0 && range2.location - range1.location > 0) {
                    NSRange range = NSMakeRange(range1.location, range2.location - range1.location + 10);
                    NSString *resultStr = [str substringWithRange:range];
                    [resultArray addObject:resultStr];
                    NSLog(@"endIndex: %ld, startIndex: %ld, resultArray.count: %ld", endIndex, startIndex, resultArray.count);
                    if (startIndex >= endIndex - 1 || (startIndex >= endIndex - 100 && startIndex % 50 == 0)) {
                        NSLog(@"网络数据爬取成功,总数: %ld", resultArray.count);
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *path = [paths objectAtIndex:0];
                        NSString *filePath = [path stringByAppendingPathComponent:@"data.txt"];
                        BOOL isSuccess = [resultArray writeToFile:filePath atomically:YES];
                        if (isSuccess) {
                            NSLog(@"网络数据保存成功");
                        } else {
                            NSLog(@"网络数据保存失败");
                        }
                    }
                }
            }
        }];
    }
}

+ (void)getNetworkDataTest {
    // https://www.7027d62825fed025.com/play.x?stype=mlmovie&movieid=8398
    // https://www.7027d62825fed025.com/play.x?stype=mlmovie&movieid=8405
    // https://www.7027d62825fed025.com/play.x?stype=mlmovie&movieid=8395
    // https://www.7027d62825fed025.com/play.x?stype=mlvideo&movieid=14706
    // https://www.7027d62825fed025.com/play.x?stype=mlvideo&movieid=14702
    // https://www.7027d62825fed025.com/play.x?stype=mlvideo&movieid=14707
    NSString *urlStr = @"http://www.38ppd.com/zpmp4.x?stype=zpmp4&zpmp4id=%ld";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", str);
        if (str != nil) {
            NSRange range1 = [str rangeOfString:@"<source src="];
            NSRange range2 = [str rangeOfString:@"type=\"video/mp4\""];
            if (range1.length > 0 && range2.length > 0 && range2.location - range1.location > 0) {
                NSRange range = NSMakeRange(range1.location, range2.location - range1.location + 10);
                NSString *resultStr = [str substringWithRange:range];
                NSLog(@"%@", resultStr);
            }
        }
    }];
}


// 公司上班登陆
+ (void)iskytripLogin {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *bodyStr = @"username=0060&password=xKu18V7RRnntrPV8fvHlQA==&token_jpush=appstore 141fe1da9e3c87113aa&type=odoo";
    
    NSURL *url = [NSURL URLWithString:@"https://iskytrip.peoplus.cn/api/ERoadIDs/Session"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@ : %@", dict, [NSThread currentThread]);
        NSString *token = dict[@"token"];
        [self iskytripDaka:token];
    }];
    
    [task resume];
}

// 公司上班打卡
+ (void)iskytripDaka:(NSString *)token {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSDictionary *dict = @{
        @"cur_latitude": @(31.22428772837452),
        @"cur_longitude": @(121.3604059906495),
        @"wifi_array": @[@"20:28:3e:18:33:b0"],
        @"beaconArray": @[],
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:0];
    NSString *bodyStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *urlStr = [NSString stringWithFormat:@"https://iskytrip.peoplus.cn/api/Attendances/clock?access_token=%@&action=", token];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@ : %@", dict, [NSThread currentThread]);
    }];
    
    [task resume];
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
