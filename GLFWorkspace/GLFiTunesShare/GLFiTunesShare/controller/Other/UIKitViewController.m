//
//  UIKitViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/1/31.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "UIKitViewController.h"

@interface UIKitViewController ()
{
    UIDynamicAnimator *animator;          // 动画者
    UIGravityBehavior *gravityBeahvior;   // 仿真行为_重力
    NSArray *imageArray;
}
@end

@implementation UIKitViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"所有图片" style:UIBarButtonItemStylePlain target:self action:@selector(testAction:)];
    self.navigationItem.rightBarButtonItem = item;
    self.title = @"UIKit动力学";

    // 1-动画者
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    // 2-重力仿真行为
    gravityBeahvior = [[UIGravityBehavior alloc] init];
    // 3-添加重力仿真行为
    [animator addBehavior:gravityBeahvior];
    
    // 点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self prepareData];
}

- (void)prepareData {
    [self showHUD];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        NSArray *array = [GLFFileManager searchSubFile:path andIsDepth:YES];
        for (int i = 0; i < array.count; i++) {
            // 当其他程序让本程序打开文件时,会自动生成一个Inbox文件夹
            // 这个文件夹是系统权限,不能删除,只可以删除里面的文件,因此这里隐藏好了
            if ([array[i] isEqualToString:@"Inbox"]) {
                continue;
            }
            FileModel *model = [[FileModel alloc] init];
            model.name = array[i];
            model.path = [NSString stringWithFormat:@"%@/%@", path,model.name];
            NSInteger fileType = [GLFFileManager fileExistsAtPath:model.path];
            if (fileType == 1) { // 文件
                model.isDir = NO;
                NSArray *array = [model.name componentsSeparatedByString:@"."];
                NSString *lowerType = [array.lastObject lowercaseString];
                if ([CimgTypeArray containsObject:lowerType]) {
                    model.image = [UIImage imageWithContentsOfFile:model.path];
                    [resultArray addObject:model];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAllHUD];
            imageArray = resultArray;
        });
    });
}

- (void)tapped:(UITapGestureRecognizer *)gesture {
    NSInteger mmm = arc4random() % 3;
    NSString *name = @"bgview1";
    if (mmm == 0) {
        NSInteger nnn = arc4random() % 9;
        name = [NSString stringWithFormat:@"bgview%ld", nnn];
    } else if (mmm == 1) {
        NSInteger nnn = arc4random() % 13;
        name = [NSString stringWithFormat:@"mv%ld", nnn];
    } else if (mmm == 2) {
        NSInteger nnn = arc4random() % 32;
        name = [NSString stringWithFormat:@"nv%ld", nnn];
    }
    UIImage *image = [UIImage imageNamed:name];
    if (imageArray.count > 0) {
        NSInteger mmm = arc4random() % imageArray.count;
        FileModel *model = imageArray[mmm];
        image = [UIImage imageWithContentsOfFile:model.path];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = CGRectMake(0, 0, kScreenWidth, 200);
    imageView.center = [gesture locationInView:gesture.view];
    imageView.center = CGPointMake(kScreenWidth / 2.0, kScreenHeight / 2.0);
    [self.view addSubview:imageView];
    // 为重力仿真行为添加动力学元素
    [gravityBeahvior addItem:imageView];
}

- (void)testAction:(id)sender {
    [self showStringHUD:@"暂未实现" second:2];
}


@end
