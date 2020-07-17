//
//  SubViewController.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/10/6.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BackBlock) (void);
typedef void (^SetBackEnableBlock) (BOOL);
typedef void (^SetForwardEnableBlock) (BOOL);

// --- 内容子页
@interface SubViewController : BaseViewController

@property (nonatomic, assign) NSInteger currentIndex;   
@property (nonatomic, strong) FileModel *model;
@property (nonatomic, strong) BackBlock backBlock;
@property (nonatomic, strong) SetBackEnableBlock backEnableBlock;
@property (nonatomic, strong) SetForwardEnableBlock forwardEnableBlock;

@property (nonatomic, strong) UIWebView *myWebView;

@end
