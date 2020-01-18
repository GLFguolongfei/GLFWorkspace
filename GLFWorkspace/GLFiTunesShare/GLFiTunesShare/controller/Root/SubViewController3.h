//
//  SubViewController3.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2018/5/30.
//  Copyright © 2018年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

// --- 内容子页(视频)
@interface SubViewController3 : UIViewController

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) FileModel *model;
@property (nonatomic, assign) BOOL isRotate;

- (void)rotatePlayer:(BOOL)flag;

@end
