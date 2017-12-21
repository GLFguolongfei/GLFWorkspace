//
//  LoginViewController.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/10/2.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"

@interface LoginViewController : BaseViewController

@property (nonatomic, strong) FileModel *moveModel; // 专用于,从iCloud共享过来的数据使用

@end
