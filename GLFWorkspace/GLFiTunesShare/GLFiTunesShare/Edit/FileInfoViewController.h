//
//  FileInfoViewController.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/10/24.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"

// --- 信息页
@interface FileInfoViewController : UIViewController

@property (nonatomic, strong) FileModel *model;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel; // 路径
@property (weak, nonatomic) IBOutlet UILabel *label1;    // 种类
@property (weak, nonatomic) IBOutlet UILabel *label2;    // 大小
@property (weak, nonatomic) IBOutlet UILabel *label3;    // 创建日期
@property (weak, nonatomic) IBOutlet UILabel *label4;    // 修改日期

@end
