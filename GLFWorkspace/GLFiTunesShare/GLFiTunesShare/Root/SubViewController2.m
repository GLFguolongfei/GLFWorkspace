//
//  SubViewController2.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2018/5/30.
//  Copyright © 2018年 GuoLongfei. All rights reserved.
//

#import "SubViewController2.h"

@interface SubViewController2 ()
{

}
@end

@implementation SubViewController2


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupAVPlayer {
    
    
    
    // 点按手势
    CGRect rect = CGRectMake(10, 80, kScreenWidth-20, kScreenHeight-100);
    UIView *view = [[UIView alloc] initWithFrame:rect];
    //    view.backgroundColor = [UIColor clearColor];
    view.backgroundColor = [UIColor redColor];
    view.alpha = 0.3;
    [self.view addSubview:view];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(tapAction:)];
    [view addGestureRecognizer:tapGesture];
}

- (void)tapAction:(UITapGestureRecognizer *)gesture {
    
    
}


@end
