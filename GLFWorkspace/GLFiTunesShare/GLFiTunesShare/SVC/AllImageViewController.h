//
//  UIKitViewController.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/1/31.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AllImageViewController : BaseViewController

@property (nonatomic, assign) BOOL isPageShow;
@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, assign) NSInteger pageCount;

@end

NS_ASSUME_NONNULL_END
