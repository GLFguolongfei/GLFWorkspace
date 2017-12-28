//
//  ViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/9/29.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
  
    // 用到的知识点
    // 1. [iTunes共享] 通过iTunes共享文件到Document目录
    // 2. [AirDrop共享] 使用UIActivityViewController分享功能
    // 3. [iOS数据共享] info.plist中添加CFBundleDocumentTypes(Document types)
    //                 注册可用类型,为你的App提供把文件传输给其它App和接收其它App传来的文件的功能
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
 
}


@end
