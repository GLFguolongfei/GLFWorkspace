//
//  TwoViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/3.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "TwoViewController.h"

@interface TwoViewController ()<UICollisionBehaviorDelegate>
{
    UIImageView *bgImageView;
    
    UIDynamicAnimator *animator;            // 动画者
    UIGravityBehavior *gravityBeahvior;     // 仿真行为_重力
    UICollisionBehavior *collisionBehavior; // 仿真行为_碰撞
    UIDynamicItemBehavior *itemBehavior;    // 辅助行为
    
    NSMutableArray *allImagesArray;
    NSInteger maxWidth;
    BOOL isMax;
}
@end

@implementation TwoViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"大图" style:UIBarButtonItemStylePlain target:self action:@selector(button)];
    self.navigationItem.rightBarButtonItem = item;
    [self setVCTitle:@"UIKit动力学"];
    
    // 设置背景图片
    bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.image = [DocumentManager getBackgroundImage];
    [self.view addSubview:bgImageView];
    UIVisualEffectView *visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEfView.frame = kScreen;
    visualEfView.alpha = 0.5;
    [bgImageView addSubview:visualEfView];

    maxWidth = kScreenWidth / 4;
    isMax = NO;
    
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
    
    // 点击手势
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:gesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 设置背景图片
    bgImageView.image = [DocumentManager getBackgroundImage];
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
    NSInteger width = arc4random() % maxWidth;
    if (width < 10) {
        width = 10;
    }
    NSInteger height = width * image.size.height / image.size.width;
    imageView.frame = CGRectMake(0, 0, width, height);
    imageView.tag = mmm++;
    imageView.center = [gesture locationInView:gesture.view];
    [self.view addSubview:imageView];
    // 为仿真行为添加动力学元素
    [gravityBeahvior addItem:imageView];
    [collisionBehavior addItem:imageView];
    [itemBehavior addItem:imageView];
}

- (void)button {
    if (isMax) {
        maxWidth = kScreenWidth / 4;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"大图" style:UIBarButtonItemStylePlain target:self action:@selector(button)];
        self.navigationItem.rightBarButtonItem = item;
    } else {
        maxWidth = kScreenWidth / 2;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"小图" style:UIBarButtonItemStylePlain target:self action:@selector(button)];
        self.navigationItem.rightBarButtonItem = item;
    }
    isMax = !isMax;
}

#pragma mark UICollisionBehaviorDelegate
- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id )item withBoundaryIdentifier:(id )identifier atPoint:(CGPoint)p
{
    UIImageView *imageView = (UIImageView *)item;
    NSLog(@"开始碰撞 %ld", imageView.tag);
}

- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id )item withBoundaryIdentifier:(id )identifier
{
    UIImageView *imageView = (UIImageView *)item;
    NSLog(@"结束碰撞 %ld", imageView.tag);
}


@end
