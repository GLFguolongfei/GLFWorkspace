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

// 当从iCloud共享过来数据时使用
@property (nonatomic, strong) FileModel *moveModel;

@end
