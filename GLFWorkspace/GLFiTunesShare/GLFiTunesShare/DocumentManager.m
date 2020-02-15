//
//  DocumentManager.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/15.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "DocumentManager.h"

@interface DocumentManager()
{
    BOOL isEaching;
}
@end

@implementation DocumentManager

HMSingletonM(DocumentManager)

- (void)eachAllFiles:(BOOL) isForce {
    if (isEaching && !isForce) {
        return;
    }
    isEaching = YES;
    
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
                model.isDir = NO;
                model.size = [GLFFileManager fileSize:model.path];
                NSArray *array = [model.name componentsSeparatedByString:@"."];
                NSString *lowerType = [array.lastObject lowercaseString];
                if ([CimgTypeArray containsObject:lowerType]) {
                    model.image = [UIImage imageWithContentsOfFile:model.path];
                    [allImagesArray addObject:model];
                } else if ([CvideoTypeArray containsObject:lowerType]) {
//                    #if FirstTarget
//                        model.image = [GLFTools thumbnailImageRequest:9 andVideoPath:model.path];
//                    #else
//                        model.image = [GLFTools thumbnailImageRequest:90 andVideoPath:model.path];
//                    #endif
                    model.image = nil;
                    [allVideosArray addObject:model];
                    if ([model.name isEqualToString:@"抖音"]) {
                        [allDYVideosArray addObject:model];
                    } else {
                        CGSize size = [GLFTools videoSizeWithPath:model.path];
                        if (size.width / size.height < (kScreenWidth + 200) / kScreenHeight) {
                            [allDYVideosArray addObject:model];
                        }
                    }
                }
                [allFilesArray addObject:model];
            } else if (fileType == 2) { // 文件夹
                model.isDir = YES;
                model.size = [GLFFileManager fileSizeForDir:model.path];
                model.count = [model.attributes[@"NSFileReferenceCount"] integerValue];
                [allFoldersArray addObject:model];
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
        NSDate *endDate = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *cmps = [calendar components:type fromDate:startDate toDate:endDate options:0];
        NSLog(@"全局遍历完成,一共用时: %ld分钟%ld秒", cmps.minute, cmps.second);
    });
}

+ (void)updateDocumentPaths {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    // 遍历
    @synchronized(self) { // ------ 加互斥锁
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSArray *array = [GLFFileManager searchSubFile:documentPath andIsDepth:YES];
            NSMutableArray *documentPathArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < array.count; i++) {
                NSString *path = [NSString stringWithFormat:@"%@/%@", documentPath, array[i]];
                NSInteger fileType = [GLFFileManager fileExistsAtPath:path];
                if (fileType == 2) { // 只显示文件夹
                    [documentPathArray addObject:array[i]];
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



@end
