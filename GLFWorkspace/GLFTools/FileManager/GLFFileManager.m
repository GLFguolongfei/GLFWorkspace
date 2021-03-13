//
//  GLFFileManager.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/9/29.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "GLFFileManager.h"

@implementation GLFFileManager

HMSingletonM(FileManager)

#pragma mark NSFileManager方法
// 遍历路径下的文件夹和路径
+ (NSArray *)searchSubFile:(NSString *)path andIsDepth:(BOOL)isDepth {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array = [[NSArray alloc] init];
    if (isDepth) { // 读取路径下的所有内容(文件夹和文件,会深层递归)
        array = [fileManager subpathsOfDirectoryAtPath:path error:nil];
    } else { // 读取路径下的所有内容(文件夹和文件,不会深层递归)
        array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    }
    // 不用显示里面的隐藏文件
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    [mutableArray addObjectsFromArray:array];
    for (NSString *str in array) {
        NSString *sss = [str substringToIndex:1];
        if ([sss isEqualToString:@"."]) {
            [mutableArray removeObject:str];
        }
    }
    return mutableArray;
}

// 返回 0:文件不存在 1:是文件 2:是文件夹
+ (NSInteger)fileExistsAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSInteger type = 0;
    // 检查指定的路径是否存在,同时它是否是文件夹
    BOOL isDerectary;
    BOOL exist = [fileManager fileExistsAtPath:path isDirectory:&isDerectary];
    if (exist) {
        if (isDerectary) { // 指定路径是文件夹
            type = 2;
        } else { 
            type = 1;
        }
    }
    return type;
}

+ (NSDictionary *)attributesOfItemAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 获得文件/文件夹的属性
    NSDictionary *dict = [fileManager attributesOfItemAtPath:path error:nil];
    for (NSString *key in dict) {
//        NSLog(@"%@ : %@", key, [dict objectForKey:key]);
    }
    return dict;
}

+ (BOOL)createFile:(NSString *)path andData:(NSData *)data {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager createFileAtPath:path contents:data attributes:nil];
    NSLog(@"文件创建: %@", success ? @"成功" : @"失败");
    return success;
}

+ (BOOL)createFolder:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 创建文件夹
    //   参数1: 要创建的文件/文件夹路径
    //   参数2: 如果父目录不存在是否创建
    //   参数3: 文件夹的属性,我们暂时为空
    //   参数4: 创建失败的原因,是一个二级指针
    NSError *error;
    BOOL success = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (success) {
        NSLog(@"文件夹创建: 成功");
    } else {
        NSLog(@"文件夹创建: %@ %@", @"失败", error);
    }
    return success;
}

+ (BOOL)fileCopy:(NSString *)fromePath toPath:(NSString *)toPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 拷贝
    // 注意: 拷贝到的路径必须指定一个名字(它不会默认为原来的名字)
    // 注意: 重复拷贝就会出错
    // 注意: 文件拷贝的时候可以改名,文件夹同样可以
    // 列fromePath @"/Users/qianfeng/Desktop/郭龙飞/baidu.html"
    // 列toPath @"/Users/qianfeng/Desktop/guo.html"
    NSError *error;
    BOOL success = [fileManager copyItemAtPath:fromePath toPath:toPath error:&error];
    if (success) {
        NSLog(@"拷贝文件或文件夹: 成功");
    } else {
        NSLog(@"拷贝文件或文件夹: %@ %@", @"失败", error);
    }
    return success;
}

+ (BOOL)fileMove:(NSString *)fromePath toPath:(NSString *)toPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 移动替换(其实也是重命名)
    NSError *error;
    BOOL success = [fileManager moveItemAtPath:fromePath toPath:toPath error:&error];
    NSLog(@"移动文件或文件夹: %@", success ? @"成功" : @"失败");
    return success;
}

+ (BOOL)fileDelete:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 删除文件/文件夹
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:path error:&error];
    NSLog(@"删除文件或文件夹: %@", success ? @"成功" : @"失败");
    return success;
}

#pragma mark NSFileManager综合方法
+ (float)fileSize:(NSString *)path {
    NSDictionary *dict = [self attributesOfItemAtPath:path];
    float size = [dict[@"NSFileSize"] floatValue];
    return size;
}

+ (float)fileSizeForDir:(NSString *)path {
    float size = 0;
    NSArray *array = [self searchSubFile:path andIsDepth:YES];
    for(int i = 0; i < array.count; i++) {
        NSString *subPath = array[i];
        NSString *fullPath = [path stringByAppendingPathComponent:subPath];
        BOOL type = [self fileExistsAtPath:fullPath];
        if (type == 1) {
            float subSize = [self fileSize:fullPath];
            size += subSize;
        }
    }
    return size;
}

#pragma mark Method
+ (NSString *)returenSizeStr:(CGFloat)size {
    if (size / 1000.0 > 1000) {
        if (size / 1000000.0 > 1000) {
            if (size / 1000000000.0 > 1000) {
                return @"> 1T";
            } else {
                return [NSString stringWithFormat:@"%.1f GB", size/1000000000.0];
            }
        } else {
            return [NSString stringWithFormat:@"%.1f MB", size/1000000.0];
        }
    } else {
        return [NSString stringWithFormat:@"%.1f KB", size/1000.0];
    }
}


@end
