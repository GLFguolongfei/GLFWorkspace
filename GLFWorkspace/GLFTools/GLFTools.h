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
#pragma mark 缩放
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize; // 等比率缩放
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize; // 自定长宽
+ (UIImage *)reSizeImage:(UIImage *)image toWidth:(float)width; // 自定最大宽(按比例缩放)

#pragma mark 获取IP地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
    
@end
