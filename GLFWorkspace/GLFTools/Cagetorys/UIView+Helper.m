//
//  UIView+Helper.m
//  PADMUP001
//
//  Created by Mac on 13-6-21.
//  Copyright (c) 2013年 Meige. All rights reserved.
//

#import "UIView+Helper.h"

@implementation UIView (Helper)

// 截屏
- (UIImage *)takeSnapshot {
    @autoreleasepool {
        UIGraphicsBeginImageContext(self.bounds.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.layer renderInContext:context];
        UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultingImage;
    }
}

// 裁剪图片
// mCGRect: 裁剪大小
// centerBool: 是否从中心点开始裁剪
+ (UIImage *)getSubImage:(UIImage *)image mCGRect:(CGRect)mCGRect centerBool:(BOOL)centerBool {
    float imgwidth = image.size.width;
    float imgheight = image.size.height;
    float viewwidth = mCGRect.size.width;
    float viewheight = mCGRect.size.height;
    CGRect rect;
    if(centerBool) {
        rect = CGRectMake((imgwidth-viewwidth)/2, (imgheight-viewheight)/2, viewwidth, viewheight);
    } else {
        if (viewheight < viewwidth) {
            if (imgwidth <= imgheight) {
                rect = CGRectMake(0, 0, imgwidth, imgwidth*viewheight/viewwidth);
            } else {
                float width = viewwidth*imgheight/viewheight;
                float x = (imgwidth - width)/2 ;
                if (x > 0) {
                    rect = CGRectMake(x, 0, width, imgheight);
                }else {
                    rect = CGRectMake(0, 0, imgwidth, imgwidth*viewheight/viewwidth);
                }
            }
        } else {
            if (imgwidth <= imgheight) {
                float height = viewheight*imgwidth/viewwidth;
                if (height < imgheight) {
                    rect = CGRectMake(0, 0, imgwidth, height);
                }else {
                    rect = CGRectMake(0, 0, viewwidth*imgheight/viewheight, imgheight);
                }
            }else {
                float width = viewwidth*imgheight/viewheight;
                if (width < imgwidth) {
                    float x = (imgwidth - width)/2 ;
                    rect = CGRectMake(x, 0, width, imgheight);
                }else {
                    rect = CGRectMake(0, 0, imgwidth, imgheight);
                }
            }
        }
    }
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}

@end
