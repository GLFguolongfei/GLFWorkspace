//
//  DetailViewController.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/9/29.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

// --- 内容页
@interface DetailViewController : UIViewController

@property (nonatomic, assign) NSInteger selectIndex;  
@property (nonatomic, strong) NSArray *fileArray;

@end
