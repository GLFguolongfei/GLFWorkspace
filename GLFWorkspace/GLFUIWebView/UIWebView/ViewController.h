//
//  ViewController.h
//  UIWebView
//
//  Created by guolongfei on 2017/10/27.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : BaseViewController

@property (nonatomic, strong) UITextView *ipTextView;
@property (nonatomic, assign) NSInteger action; // 1-扫描 2-百度

- (void)goURLVC:(NSString *)urlStr;
- (void)goURLVC:(NSString *)urlStr andType:(NSInteger)type;

@end

