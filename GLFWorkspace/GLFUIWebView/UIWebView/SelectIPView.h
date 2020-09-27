//
//  SelectIPView.h
//  UIWebView
//
//  Created by guolongfei on 2017/12/8.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface SelectIPView : UIView

@property (nonatomic, weak) ViewController *parentVC;
@property (nonatomic, assign) BOOL isSecret;

@end
