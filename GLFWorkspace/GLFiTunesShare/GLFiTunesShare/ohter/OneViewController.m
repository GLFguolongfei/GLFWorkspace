//
//  OneViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/3.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "OneViewController.h"

@interface OneViewController ()
{
    UIDynamicAnimator *animator;          // 动画者
    UIGravityBehavior *gravityBeahvior;   // 仿真行为_重力
    UIImageView *imageView;
    UIViewContentMode *contentMode;
    UILabel *label;
    
    NSMutableArray *allImagesArray;
}
@end

@implementation OneViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"ImageModel" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction)];
    self.navigationItem.rightBarButtonItem = item;
    [self setVCTitle:@"UIKit动力学"];
    self.canHiddenNaviBar = YES;
    
    contentMode = UIViewContentModeScaleAspectFit;
    
    CGRect labelRect = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    label = [[UILabel alloc] initWithFrame:labelRect];
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    
    label.text = @"试着点击屏幕";
    label.textColor = [UIColor colorWithHexString:@"E3170D"];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    
    label.font = KFontBold(36);
    label.font = [UIFont fontWithName:@"Zapfino" size:28];
    
    label.shadowColor = [UIColor colorWithHexString:@"FF7F50"];
    label.shadowOffset = CGSizeMake(2, 2);

    // 1-动画者
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    // 2-重力仿真行为
    gravityBeahvior = [[UIGravityBehavior alloc] init];
    // 3-添加重力仿真行为
    [animator addBehavior:gravityBeahvior];
    
    [DocumentManager getAllImagesArray:^(NSArray * array) {
        allImagesArray = [array mutableCopy];
    }];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self showImage];
    label.hidden = YES;
    [UIView animateWithDuration:1 animations:^{
        self.view.backgroundColor = [UIColor blackColor];
    }];
}

- (void)buttonAction {
    if (contentMode == UIViewContentModeScaleAspectFill) {
        contentMode = UIViewContentModeScaleAspectFit;
    } else {
        contentMode = UIViewContentModeScaleAspectFill;
    }
    if (imageView) {
        imageView.contentMode = contentMode;
    }
}

- (void)showImage {
    if (imageView) {
        // 为重力仿真行为添加动力学元素
        [gravityBeahvior addItem:imageView];
    }
    NSInteger mmm = arc4random() % 3;
    NSString *name = @"bgview1";
    if (mmm == 0) {
        NSInteger nnn = arc4random() % 9;
        name = [NSString stringWithFormat:@"bgview%ld", nnn];
    } else if (mmm == 1) {
        NSInteger nnn = arc4random() % 13;
        name = [NSString stringWithFormat:@"mv%ld", nnn];
    }
    UIImage *image = [UIImage imageNamed:name];
    if (allImagesArray.count > 0) {
        NSInteger mmm = arc4random() % allImagesArray.count;
        FileModel *model = allImagesArray[mmm];
        image = [UIImage imageWithContentsOfFile:model.path];
    }
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = contentMode;
    imageView.frame = CGRectMake(0, 0, 0, 0);
    imageView.center = CGPointMake(kScreenWidth / 2.0, (kScreenHeight-64) / 2.0 + 64);
    imageView.alpha = 0;
    [self.view addSubview:imageView];
    [UIView animateWithDuration:1 animations:^{
        imageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        imageView.alpha = 1;
    }];
}


@end
