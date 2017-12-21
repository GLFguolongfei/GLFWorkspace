//
//  UIColor+Category.h
//  MUD004
//
//  Created by MACCO on 14/11/14.
//  Copyright (c) 2014年 MACCO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Category)

+ (UIColor *)colorWithR:(int )red G:(int)green B:(int)blue Alpha:(float)alpha;

// 根据字符串返回颜色
+ (UIColor *)colorWithHexString: (NSString *) stringToConvert;

@end




@interface UIImage (colorful)

// 将颜色转换为图片
+ (UIImage *)imageWithColor:(UIColor *)color;

@end






@interface NSDate(MyDate)


+(NSDate*) convertDateFromString:(NSString*)uiDate;

+ (NSString *)stringFromDate:(NSDate *)date;
    

@end


