//
//  GLFTools.m
//  MyDemo1
//
//  Created by guolongfei on 2017/9/27.
//  Copyright © 2017年 shanghaimeike. All rights reserved.
//

#import "GLFTools.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

#define WIDTH [[UIScreen mainScreen] bounds].size.width*2/3

//首先导入头文件信息
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation GLFTools


#pragma mark 模糊
// 使用Core Image进行模糊
// 模糊等级为0到100
+ (UIImage *)blurryImage1:(UIImage *)image withBlurLevel:(CGFloat)blur {
    // 1-创建CIImage
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    // 2-创建CIContext(使用GPU,速度比CPU快)
    CIContext *context = [CIContext contextWithOptions:nil];
    // 3-创建CIFilter
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, inputImage,
                        @"inputRadius", @(blur),
                        nil];
    // 4-获得filter的输出
    CIImage *outputImage = filter.outputImage;
    CGImageRef outImage = [context createCGImage:outputImage
                                        fromRect:[outputImage extent]];
    UIImage *resultImage = [UIImage imageWithCGImage:outImage];
    
    return resultImage;
}

//2016-06-19 00:16:16.169 CoreImage[14406:2627030] ----------------------- 过滤器名字 CIGaussianBlur
//2016-06-19 00:16:16.170 CoreImage[14406:2627030] ----------------------- 过滤器属性 {
//    "CIAttributeFilterAvailable_Mac" = "10.4";
//    "CIAttributeFilterAvailable_iOS" = 6;
//    CIAttributeFilterCategories =     (
//                                       CICategoryBlur,
//                                       CICategoryStillImage,
//                                       CICategoryVideo,
//                                       CICategoryBuiltIn
//                                       );
//    CIAttributeFilterDisplayName = "Gaussian Blur";
//    CIAttributeFilterName = CIGaussianBlur;
//    CIAttributeReferenceDocumentation = "http://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIGaussianBlur";
//    inputImage =     {
//        CIAttributeClass = CIImage;
//        CIAttributeDescription = "The image to use as an input image. For filters that also use a background image, this is the foreground image.";
//        CIAttributeDisplayName = Image;
//        CIAttributeType = CIAttributeTypeImage;
//    };
//    inputRadius =     {
//        CIAttributeClass = NSNumber;
//        CIAttributeDefault = 10;
//        CIAttributeDescription = "The radius determines how many pixels are used to create the blur. The larger the radius, the blurrier the result.";
//        CIAttributeDisplayName = Radius;
//        CIAttributeIdentity = 0;
//        CIAttributeMin = 0;
//        CIAttributeSliderMax = 100;
//        CIAttributeSliderMin = 0;
//        CIAttributeType = CIAttributeTypeScalar;
//    };
//}

// 使用vImage API进行模糊
// 模糊等级为0到1
+ (UIImage *)blurryImage2:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 100);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) *
                         CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer,
                                       &outBuffer,
                                       NULL,
                                       0,
                                       0,
                                       boxSize,
                                       boxSize,
                                       NULL,
                                       kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    // 注意:
    // 这两句应该是加上的,但因为用了多线程,从而一旦加上这两句就报错,故注释掉
    // 至于怎么修改暂时还没想好
    //    CGColorSpaceRelease(colorSpace);
    //    CGImageRelease(imageRef);
    
    return returnImage;
}

#pragma mark 计算字符串宽高
+ (CGSize)calculatingStringSizeWithString:(NSString *)string ByFont:(UIFont *)font andSize:(CGSize)contentSize {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attrbute = @{
                               NSFontAttributeName           : font,
                               NSParagraphStyleAttributeName : paragraphStyle
                               };
    
    CGRect stringRect = [string boundingRectWithSize: contentSize
                                             options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                          attributes: attrbute
                                             context: nil];
    
    return stringRect.size;
}

#pragma mark 字典字符串转换
// 字典转json格式字符串
+ (NSString *)dictionaryToJson:(NSDictionary *)dic {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

// json格式字符串转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark 缩放
// 等比率缩放
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    CGFloat imageW = image.size.width * scaleSize;
    CGFloat imageH = image.size.height * scaleSize;
    UIGraphicsBeginImageContext(CGSizeMake(imageW, imageH));
    [image drawInRect:CGRectMake(0, 0, imageW, imageH)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

// 自定长宽
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize {
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

// 自定最大宽(按比例缩放)
+ (UIImage *)reSizeImage:(UIImage *)image toWidth:(float)width {
    CGFloat height = image.size.height * width / image.size.width;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

#pragma mark 获取IP地址
// 获取设备当前网络IP地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ?
    @[ /*IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6,*/ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ /*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

// 获取所有相关IP信息
+ (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

#pragma mark 获取视频缩略图
// 截取指定时间的视频缩略图
+ (UIImage *)thumbnailImageRequest:(CGFloat )timeBySecond andVideoPath:(NSString *)path {
    // 创建URL
    NSURL *url = [NSURL fileURLWithPath:path];
    // 根据url创建AVURLAsset
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:url];
    // 根据AVURLAsset创建AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    
    // 截图
    // requestTime: 缩略图创建时间
    // actualTime: 缩略图实际生成的时间
    // CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
    CMTime time = CMTimeMakeWithSeconds(timeBySecond, 10);
    CMTime actualTime;
    NSError *error = nil;
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if(error){
        NSLog(@"截取视频缩略图时发生错误，错误信息: %@",error.localizedDescription);
        return [[UIImage alloc] init];
    }
    CMTimeShow(actualTime);
    
    UIImage *image = [UIImage imageWithCGImage:cgImage]; // 转化为UIImage
    CGImageRelease(cgImage);
    return image;
}

#pragma mark 获取视频尺寸
+ (CGSize)videoSizeWithPath:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    NSArray *array = asset.tracks;
    CGSize videoSize = CGSizeZero;
    for(AVAssetTrack  *track in array) {
        if([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            videoSize = track.naturalSize;
        }
    }
    return videoSize;
}

#pragma mark 转换成时分秒
+ (NSString *)timeFormatted:(NSInteger)totalSeconds {
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    if (totalSeconds >= 3600) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else if (totalSeconds >= 60) {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02ld", (long)seconds];
    }
}

@end
