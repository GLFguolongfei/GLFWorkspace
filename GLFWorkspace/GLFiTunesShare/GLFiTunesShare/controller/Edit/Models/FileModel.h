//
//  FileModel.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/11/3.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FileModel : NSObject

@property (nonatomic, strong) NSString *name;           // 名字(含扩展名)
@property (nonatomic, strong) NSString *path;           // 全路径(含最后的名字以及扩展名)
@property (nonatomic, strong) NSDictionary *attributes; // 属性字典
@property (nonatomic, assign) BOOL isDir;               // 是否文件夹
@property (nonatomic, assign) CGFloat size;             // 大小
@property (nonatomic, assign) NSInteger count;          // 子文件数目(只有文件夹有)

// 如果Model为图片,image就是那张图
// 如果Model为视频,image就是视频缩略图
// 如果Model为其它类型,image为nil
@property (nonatomic, copy) UIImage *image;

@end
