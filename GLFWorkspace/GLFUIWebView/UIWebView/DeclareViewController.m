//
//  DeclareViewController.m
//  UIWebView
//
//  Created by guolongfei on 2018/1/31.
//  Copyright © 2018年 GuoLongfei. All rights reserved.
//

#import "DeclareViewController.h"

@interface DeclareViewController ()

@end

@implementation DeclareViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"说明";

    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendString:@""];
    [str appendString:@""];
    [str appendString:@""];
    [str appendString:@""];
    [str appendString:@""];
    [str appendString:@""];
    [str appendString:@""];
    [str appendString:@""];
    [str appendString:@""];
    [str appendString:@""];
    [str appendString:@""];
    [str appendString:@""];
    [str appendString:@""];
    [str appendString:@""];
    [str appendString:@""];

    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 15, kScreenWidth-30, kScreenHeight-30)];
    textView.text = str;
    [self.view addSubview:textView];
}


@end
