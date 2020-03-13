//
//  GLFFileManager.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/9/29.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSingleton.h"

@interface GLFFileManager : NSObject

HMSingletonH(FileManager)

@property (nonatomic, strong) NSString *currentPath;

+ (NSArray *)searchSubFile:(NSString *)path andIsDepth:(BOOL)isDepth;
+ (NSInteger)fileExistsAtPath:(NSString *)path;
+ (NSDictionary *)attributesOfItemAtPath:(NSString *)path;
+ (BOOL)createFile:(NSString *)path andData:(NSData *)data;
+ (BOOL)createFolder:(NSString *)path;
+ (BOOL)fileCopy:(NSString *)fromePath toPath:(NSString *)toPath;
+ (BOOL)fileMove:(NSString *)fromePath toPath:(NSString *)toPath;
+ (BOOL)fileDelete:(NSString *)path;

+ (float)fileSize:(NSString *)path;
+ (float)fileSizeForDir:(NSString *)path;

+ (NSString *)returenSizeStr:(CGFloat)size;

@end
