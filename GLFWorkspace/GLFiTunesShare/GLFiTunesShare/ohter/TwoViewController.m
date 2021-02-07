//
//  TwoViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/3.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "TwoViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface TwoViewController ()<UICollisionBehaviorDelegate>
{
    UIImageView *bgImageView;
    UIImageView *showImageView;

    UIDynamicAnimator *animator;            // 动画者
    UIGravityBehavior *gravityBeahvior;     // 仿真行为_重力
    UICollisionBehavior *collisionBehavior; // 仿真行为_碰撞
    UIDynamicItemBehavior *itemBehavior;    // 辅助行为
    
    NSMutableArray *allImagesArray;
    
    NSInteger tag;
    
    CMMotionManager *motionManager; // 运动传感器
    
    CGRect currentRect;
    CGAffineTransform currentTransform;
}
@end

@implementation TwoViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setVCTitle:@"UIKit动力学"];
    self.canHiddenNaviBar = YES;

    // 设置背景图片
    bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.image = [DocumentManager getBackgroundImage];
    [self.view addSubview:bgImageView];
    UIVisualEffectView *visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEfView.frame = kScreen;
    visualEfView.alpha = 0.5;
    [bgImageView addSubview:visualEfView];
    
    showImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    showImageView.contentMode = UIViewContentModeScaleAspectFit;
    showImageView.frame = CGRectMake(0, 0, 0, 0);
    showImageView.hidden = YES;
    showImageView.userInteractionEnabled = YES;
    [self.view addSubview:showImageView];
        
    // 1-动画者
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    // 2-重力仿真行为
    gravityBeahvior = [[UIGravityBehavior alloc] init];
    // 3-碰撞仿真行为
    // 注意
    // 1-界面上的Views,当位置有重合时,几个元素间就会引起碰撞
    // 2-代码没有显式地添加边界坐标,而是设置translatesReferenceBoundsIntoBoundary属性为YES
    //   这意味着用提供给UIDynamicAnimator的视图的bounds作为边界
    collisionBehavior = [[UICollisionBehavior alloc] init];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionDelegate = self;
    // 4-辅助行为
    itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:nil];
    itemBehavior.elasticity = 0.6; // 弹性
    itemBehavior.friction = 0.5;   // 摩擦力
    itemBehavior.resistance = 0.5; // 阻尼
    // 4-添加仿真行为
    [animator addBehavior:gravityBeahvior];
    [animator addBehavior:collisionBehavior];
    [animator addBehavior:itemBehavior];
    
    [DocumentManager getAllImagesArray:^(NSArray * array) {
        allImagesArray = [array mutableCopy];
    }];
    
    // 运动传感器
    [self coreMotionPush];
    
    // 点击手势
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:gesture];
    
    UITapGestureRecognizer *imageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageGesture:)];
    [showImageView addGestureRecognizer:imageGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 设置背景图片
    bgImageView.image = [DocumentManager getBackgroundImage];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 暂停获取
    [motionManager stopAccelerometerUpdates];
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
    }
    UIImage *image = [UIImage imageNamed:name];
    if (allImagesArray.count > 0) {
        NSInteger mmm = arc4random() % allImagesArray.count;
        FileModel *model = allImagesArray[mmm];
        image = [UIImage imageWithContentsOfFile:model.path];
    }

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    NSInteger width = arc4random() % ((NSInteger) kScreenWidth / 3);
    if (width < 60) {
        width = 60;
    }
    NSInteger height = width * image.size.height / image.size.width;
    imageView.frame = CGRectMake(0, 0, width, height);
    imageView.tag = tag++;
    imageView.center = [gesture locationInView:gesture.view];
    [self.view addSubview:imageView];
    // 为仿真行为添加动力学元素
    [gravityBeahvior addItem:imageView];
    [collisionBehavior addItem:imageView];
    [itemBehavior addItem:imageView];
    // 手势
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageGesture:)];
    [imageView addGestureRecognizer:imageGesture];
}

- (void)imageGesture:(UITapGestureRecognizer *)gesture {
    UIImageView *imageView = (UIImageView *)gesture.view;
    NSLog(@"%ld", imageView.tag);
    if (showImageView.hidden == NO) {
        [UIView animateWithDuration:0.6 animations:^{
            showImageView.transform = currentTransform;
            showImageView.frame = currentRect;
        } completion:^(BOOL finished) {
            showImageView.hidden = YES;
        }];
    } else {
        [self.view bringSubviewToFront:showImageView];
        showImageView.hidden = NO;
        showImageView.image = imageView.image;
        showImageView.frame = imageView.frame;
        showImageView.transform = imageView.transform;
        currentRect = imageView.frame;
        currentTransform = imageView.transform;
        [UIView animateWithDuration:0.6 animations:^{
            showImageView.transform = CGAffineTransformIdentity;
            showImageView.frame = kScreen;
        }];
    }
}

#pragma mark UICollisionBehaviorDelegate
- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id )item withBoundaryIdentifier:(id )identifier atPoint:(CGPoint)p
{
//    UIImageView *imageView = (UIImageView *)item;
//    NSLog(@"开始碰撞 %ld", imageView.tag);
}

- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id )item withBoundaryIdentifier:(id )identifier
{
//    UIImageView *imageView = (UIImageView *)item;
//    NSLog(@"结束碰撞 %ld", imageView.tag);
}

#pragma mark Core Motion Push 实时采集所有数据(采集频率高)
- (void)coreMotionPush {
    // 1-创建运动管理者对象
    motionManager = [[CMMotionManager alloc] init];
    // 2-判断加速计是否可用(最好判断)
    if (motionManager.isAccelerometerAvailable) {
        // 3-设置采样时间
        motionManager.accelerometerUpdateInterval = 1/10;
        // 4-开始采样(采样到数据就会调用handler,handler会在queue中执行)
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            if (error) {
                return;
            }
            CMAcceleration acceleration = accelerometerData.acceleration;
            double ra = atan2(-acceleration.y, acceleration.x); // 返回值的单位为弧度
            gravityBeahvior.angle = ra; // 使用弧度设置重力的方向
        }];
    }
}


@end
