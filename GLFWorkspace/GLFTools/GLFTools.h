//
//  GLFTools.h
//  MyDemo1
//
//  Created by guolongfei on 2017/9/27.
//  Copyright © 2017年 shanghaimeike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface GLFTools : NSObject

#pragma mark 模糊
+ (UIImage *)blurryImage1:(UIImage *)image withBlurLevel:(CGFloat)blur;
+ (UIImage *)blurryImage2:(UIImage *)image withBlurLevel:(CGFloat)blur;
#pragma mark 计算字符串宽高
+ (CGSize)calculatingStringSizeWithString:(NSString *)string ByFont:(UIFont *)font andSize:(CGSize)contentSize;
#pragma mark 字典字符串转换
// 字典转json格式字符串
+ (NSString *)dictionaryToJson:(NSDictionary *)dic;
// json格式字符串转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
#pragma mark 压缩图片质量
+ (UIImage *)scaleImage:(UIImage *)image toCompression:(float)pression;
#pragma mark 压缩图片尺寸
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize; // 等比缩放
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)reSize; // 自定长宽
+ (UIImage *)scaleImage:(UIImage *)image toWidth:(float)width; // 自定宽度(高度自定义)

#pragma mark 获取IP地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
#pragma mark 获取视频缩略图
// 截取指定时间的视频缩略图
+ (UIImage *)thumbnailImageRequest:(CGFloat)timeBySecond andVideoPath:(NSString *)path;
#pragma mark 获取视频尺寸
+ (CGSize)videoSizeWithPath:(NSString *)path;

#pragma mark 转换成时分秒
+ (NSString *)timeFormatted:(NSInteger)totalSeconds;

+ (UIColor *)randomColor;

@end
