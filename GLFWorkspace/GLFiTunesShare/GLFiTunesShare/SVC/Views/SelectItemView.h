//
//  SelectItemView.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/4/23.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYViewController.h"
#import "DYNextViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectItemView : UIView

@property (nonatomic, weak) UIViewController *parentVC;
@property (nonatomic, assign) NSInteger pageType; // 1-DYViewController 2-DYNextViewController
@property (nonatomic, assign) NSMutableArray *dataArray;
@property (nonatomic, assign) FileModel *currentModel;

@end

NS_ASSUME_NONNULL_END
