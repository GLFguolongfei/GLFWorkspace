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

@interface DocumentManager()
{
    BOOL isEaching;
    BOOL isVideoSeting;
    BOOL isScaleImageSeting;
    AVPlayer *player; // 千万不要用作局部变量
}
@end

@implementation DocumentManager

HMSingletonM(DocumentManager)

- (void)eachAllFiles:(BOOL)isForce {
    if (isEaching && !isForce) {
        return;
    }
    isEaching = YES;
    self.allArray = [[NSMutableArray alloc] init];
    self.allFoldersArray = [[NSMutableArray alloc] init];
    self.allFilesArray = [[NSMutableArray alloc] init];
    self.allImagesArray = [[NSMutableArray alloc] init];
    self.allVideosArray = [[NSMutableArray alloc] init];
    self.allDYVideosArray = [[NSMutableArray alloc] init];
    self.allNoDYVideosArray = [[NSMutableArray alloc] init];
    
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
                    model.image = [UIImage imageWithContentsOfFile:model.path];
                    if (model.size > 1000000) { // 大于1M
                        model.scaleImage = nil;
                    } else {
                        model.scaleImage = model.image;
                    }
                    [allImagesArray addObject:model];
                } else if ([CvideoTypeArray containsObject:lowerType]) {
                    model.type = 3;
//                    #if FirstTarget
//                        model.image = [GLFTools thumbnailImageRequest:9 andVideoPath:model.path];
//                    #else
//                        model.image = [GLFTools thumbnailImageRequest:90 andVideoPath:model.path];
//                    #endif
                    model.image = nil;
                    [allVideosArray addObject:model];
                    CGSize size = [GLFTools videoSizeWithPath:model.path];
                    model.videoSize = size;
                    
                    NSArray *array = [model.name componentsSeparatedByString:@"/"];
                    NSString *name = array.firstObject;
                    if ([name isEqualToString:@"抖音"]) {
                        [allDYVideosArray addObject:model];
                    } else if (size.width / size.height < (kScreenWidth + 200) / kScreenHeight) {
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
        // 赋值
        self.allArray = allArray;
        self.allFoldersArray = allFoldersArray;
        self.allFilesArray = allFilesArray;
        self.allImagesArray = allImagesArray;
        self.allVideosArray = allVideosArray;
        self.allDYVideosArray = allDYVideosArray;
        self.allNoDYVideosArray = allNoDYVideosArray;
        NSDate *endDate = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *cmps = [calendar components:type fromDate:startDate toDate:endDate options:0];
        NSLog(@"全局遍历完成,一共用时: %ld分钟%ld秒", cmps.minute, cmps.second);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            isEaching = NO;
        });
    });
}

- (void)setVideosImage:(NSInteger)maxCount {
    if (isVideoSeting) {
        return;
    }
    isVideoSeting = YES;
    if (maxCount <= 0) {
        maxCount = 10;
    }
    __block NSInteger count = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < self.allVideosArray.count; i++) {
            if (count >= maxCount) {
                break;
            }
            FileModel *model = self.allVideosArray[i];
            if (model.image == nil) {
                count++;
                #if FirstTarget
                    model.image = [GLFTools thumbnailImageRequest:9 andVideoPath:model.path];
                #else
                    model.image = [GLFTools thumbnailImageRequest:90 andVideoPath:model.path];
                #endif
                [self.allVideosArray replaceObjectAtIndex:i withObject:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            isVideoSeting = NO;
        });
    });
}

- (void)setScaleImage:(NSInteger)maxCount {
    if (isScaleImageSeting) {
        return;
    }
    isScaleImageSeting = YES;
    if (maxCount <= 0) {
        maxCount = 10;
    }
    __block NSInteger count = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < self.allImagesArray.count; i++) {
            if (count >= maxCount) {
                break;
            }
            FileModel *model = self.allImagesArray[i];
            if (model.scaleImage == nil) {
                NSLog(@"原尺寸: %f", model.size / 1000000.0);
                count++;
                CGFloat scale = [self returnScaleSize:model.size];
                UIImage *scaleImage = [GLFTools scaleImage:model.image toScale:scale];
                model.scaleImage = scaleImage;
                [self.allImagesArray replaceObjectAtIndex:i withObject:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            isScaleImageSeting = NO;
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

#pragma mark -------- 背景音乐
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

#pragma mark Private Method
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
