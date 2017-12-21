//
//  UIView+Helper.h
//  PADMUP001
//
//  Created by Mac on 13-6-21.
//  Copyright (c) 2013年 Meige. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (Helper)

- (UIImage *)takeSnapshot; // 截屏
+ (UIImage *)getSubImage:(UIImage *)image mCGRect:(CGRect)mCGRect centerBool:(BOOL)centerBool; // 裁剪图片

@end
