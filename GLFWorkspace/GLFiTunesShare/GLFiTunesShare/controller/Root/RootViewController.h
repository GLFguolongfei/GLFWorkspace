//
//  RootViewController.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/9/29.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"

// --- 首页
@interface RootViewController : BaseViewController

@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) FileModel *moveModel; // 专用于,从iCloud共享过来的数据使用

@end
