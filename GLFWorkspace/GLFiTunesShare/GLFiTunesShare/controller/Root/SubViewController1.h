//
//  SubViewController1.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2019/10/5.
//  Copyright © 2019 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"

typedef void (^BackBlock) (void);
typedef void (^SetBackEnableBlock) (BOOL);
typedef void (^SetForwardEnableBlock) (BOOL);

NS_ASSUME_NONNULL_BEGIN

@interface SubViewController1 : UIViewController

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) FileModel *model;
@property (nonatomic, strong) BackBlock backBlock;
@property (nonatomic, strong) SetBackEnableBlock backEnableBlock;
@property (nonatomic, strong) SetForwardEnableBlock forwardEnableBlock;

@property (nonatomic, strong) UIWebView *myWebView;

@end

NS_ASSUME_NONNULL_END
