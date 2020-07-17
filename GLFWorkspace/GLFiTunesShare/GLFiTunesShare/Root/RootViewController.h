//
//  RootViewController.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/9/29.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

// --- 首页
@interface RootViewController : BaseViewController

@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) NSString *pathStr;
// 当从iCloud共享过来数据时使用
@property (nonatomic, strong) FileModel *moveModel;

@end
