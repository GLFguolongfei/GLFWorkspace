//
//  GLFLewPopupViewAnimationSlide.h
//  LewPopupViewController
//
//  Created by guolongfei on 16/6/16.
//  Copyright © 2016年 pljhonglu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LewPopupViewController.h"

// 自定义动画
// 在三林全科医生居民版项目中,要求地址从屏幕下方弹出,弹出后底部紧贴屏幕下方
// 而系统库弹出的视图都是弹到了中央,因此需要自定义
@interface GLFLewPopupViewAnimationSlide : NSObject<LewPopupAnimation>

@property (nonatomic,assign)LewPopupViewAnimationSlideType type;

@end
