//
//  PhotoStackView.m
//
//  Created by Tom Longo on 16/08/12.
//  - Twitter: @tomlongo
//  - GitHub:  github.com/tomlongo
//

#import <QuartzCore/QuartzCore.h>
#import "PhotoStackView.h"

#pragma mark 适配
#define kScreen [[UIScreen mainScreen] bounds]
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

#pragma mark 是按宽高比例3:4写的
#define RECT1 CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)
#define RECT2 CGRectMake(5, 20, self.bounds.size.width-10, 4*(self.bounds.size.width-10)/3)
#define RECT3 CGRectMake(10, 40, self.bounds.size.width-20, 4*(self.bounds.size.width-20)/3)

#define CREATCount 4 // 只创建CREATCount个控件,循环使用

@interface PhotoStackView()
{
    BOOL isUpLocation;   // 当前手指所处位置是否在中心点以上(用于判断偏移方向)
    BOOL isLeft;         // 图片移动向左方还是右方
    
    NSInteger numberOfPhotos;
    int aDD;

    CGPoint selfCenter; // 注意: 直接使用self.center,获取的是self在屏幕的中心点坐标,这里我们要的是自己的中心点
    
    NSMutableArray *photoViewArray;
}
@end

@implementation PhotoStackView


#pragma mark - 事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // 1-取得一个触摸对象(对于多点触摸可能有多个对象)
    UITouch *touch = [touches anyObject];
    // 2-获得相对于当前self的手指坐标 并非(0, 0)
    CGPoint point = [touch locationInView:self];
    // 3-根据当前手指的位置,判断偏移方向
    if (point.y < self.frame.size.height/2.0) {
        isUpLocation = YES;
    } else {
        isUpLocation = NO;
    }
}

- (void)leftMoveAnimation {
    if ([self.delegate respondsToSelector:@selector(photoStackView:willStartMovingPhotoAtIndex:)]) {
        [self.delegate photoStackView:self willStartMovingPhotoAtIndex:[self topPhoto:1].tag];
    }
    
    // 1-第二、三张图片放大并改变位置
    [self gPhotoEndWithAnimation];

    // 2-第一张改变大小位置形变
    UIView *topPhoto = [self topPhoto:1];
    [UIView animateWithDuration:0.5 animations:^{
        topPhoto.alpha = 0;
        // 设置该属性之前最好设置一遍CGAffineTransformIdentity
        topPhoto.transform = CGAffineTransformIdentity;
        topPhoto.transform = CGAffineTransformMakeRotation(-0.15);
        topPhoto.center = CGPointMake(-2*kScreenWidth, selfCenter.y+30);
    } completion:^(BOOL finished) {
        isLeft = YES;
        
        // 3-将第一张该到最后一张位置
        [self gPhotoInsert:topPhoto];
    }];
}

- (void)rightMoveAnimation {
    if ([self.delegate respondsToSelector:@selector(photoStackView:willStartMovingPhotoAtIndex:)]) {
        [self.delegate photoStackView:self willStartMovingPhotoAtIndex:[self topPhoto:1].tag];
    }
    
    // 1-第二、三张图片放大并改变位置
    [self gPhotoEndWithAnimation];
    
    // 2-第一张改变大小位置形变
    UIView *topPhoto = [self topPhoto:1];
    [UIView animateWithDuration:0.5 animations:^{
        topPhoto.alpha = 0;
        // 设置该属性之前最好设置一遍CGAffineTransformIdentity
        topPhoto.transform = CGAffineTransformIdentity;
        topPhoto.transform = CGAffineTransformMakeRotation(0.15);
        topPhoto.center = CGPointMake(2*kScreenWidth, selfCenter.y+30);
    } completion:^(BOOL finished) {
        isLeft = NO;
        
        // 3-将第一张该到最后一张位置
        [self gPhotoInsert:topPhoto];
    }];
}

- (void)reloadData {
    // 1-添加拖动手势
    if (self.gestureRecognizers.count == 0) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(photoPanned:)];
        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(tapGestureAction:)];
        [self addGestureRecognizer:tapGesture];
    }
    
    // 2-清空数组和界面
    for (NSInteger i = photoViewArray.count-1; i >= 0; i--) {
        UIView *view = photoViewArray[i];
        [view removeFromSuperview];
        [photoViewArray removeObject:view];
    }
    
    // 3-重设数组和界面
    selfCenter = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
    photoViewArray = [[NSMutableArray alloc] init];
    aDD = 0;
    numberOfPhotos = [self.dataSource numberOfPhotosInPhotoStackView:self];
    if(numberOfPhotos > 0) {
        for (NSUInteger index = 0; index < numberOfPhotos; index++) {
            // 只创建CREATCount个控件,循环使用
            if (index >= CREATCount) {
                break;
            }
            
            // 获取frame和UIImage
            CGRect rect;
            if (index == 0) {
                rect = RECT1;
            } else if(index == 1) {
                rect = RECT2;
            } else {
                rect = RECT3;
            }
            UIImage *image = [self.dataSource photoStackView:self photoForIndex:index];
            
            // 创建View(依次放在最下面)
            UIView *backView = [[UIView alloc] initWithFrame:rect];
            backView.tag = index;
            [self insertSubview:backView atIndex:0];
    
            // 创建ImageView
            UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, rect.size.width-10, rect.size.height-10)];
            photoImageView.image = image;
            photoImageView.contentMode = UIViewContentModeScaleAspectFill;
            photoImageView.layer.cornerRadius = 5;
            photoImageView.layer.masksToBounds = YES;
            [backView addSubview:photoImageView];
            
            // 添加到数组
            [photoViewArray addObject:backView];
        }
    }
}

// 返回self上第index张图片所在的View
- (UIView *)topPhoto:(NSInteger)index {
    if (self.subviews.count >= index) {
        return [self.subviews objectAtIndex:self.subviews.count-index];
    } else {
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [UIColor redColor];
        return view;
    }
}

#pragma mark 拖动手势
- (void)photoPanned:(UIPanGestureRecognizer *)gesture {
    UIView *topPhoto = [self topPhoto:1];
    float xDistance = topPhoto.center.x-selfCenter.x;
    float yDistance = topPhoto.center.y-selfCenter.y;
    float distance = sqrtf(xDistance*xDistance + yDistance*yDistance);
    
    CGPoint velocity = [gesture velocityInView:self];
    CGPoint translation = [gesture translationInView:self];
    
    if(gesture.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(photoStackView:willStartMovingPhotoAtIndex:)]) {
            [self.delegate photoStackView:self willStartMovingPhotoAtIndex:[self topPhoto:1].tag];
        }
    }
    if(gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat xPos = topPhoto.center.x + translation.x;
        CGFloat yPos = topPhoto.center.y + translation.y;
        // 1-图随手动
        topPhoto.center = CGPointMake(xPos, yPos);
        [gesture setTranslation:CGPointMake(0, 0) inView:self];
        // 2-图片放大
        [self gPhotoMoveBigger:distance];
        // 3-图片旋转
        [self gPhotoRotation:(topPhoto.center.x-selfCenter.x) andTime:0.2];
    } else if(gesture.state==UIGestureRecognizerStateEnded || gesture.state==UIGestureRecognizerStateCancelled) {
        if(abs(velocity.x) > 200 || ABS(topPhoto.center.x-selfCenter.x) > 225) {
            if (topPhoto.frame.origin.x < self.frame.origin.x) {
                isLeft = YES;
            } else {
                isLeft = NO;
            }
            [self gPhotoInsert:topPhoto];
        } else {
            [self gPhotoReturn];
        }
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)gesture {
    if (self.operationBlock) {
        self.operationBlock();
    }
}

#pragma mark 动画
// 【拖动过程中】图片旋转
- (void)gPhotoRotation:(NSInteger)degrees andTime:(float)time {
    UIView *firstView = [self topPhoto:1];
    CGFloat radians = 0;
    if (isUpLocation) {
        radians = M_PI * degrees/10000.0;
        // 向左最大值
        if (radians > 0.15) {
            radians = 0.15;
        }
        // 向右最大值
        if (radians < -0.5) {
            radians = 0.15;
        }
    } else {
        radians = -M_PI * degrees/6000.0;
        // 向左最大值
        if (radians > 0.15) {
            radians = 0.15;
        }
        // 向右最大值
        if (radians < -0.5) {
            radians = 0.15;
        }
    }
    [UIView animateWithDuration:time animations:^{
        firstView.transform = CGAffineTransformIdentity;
        firstView.transform = CGAffineTransformMakeRotation(radians);
    }];
}

// 【拖动过程中】倒数第二、三张图片放大并改变位置
- (void)gPhotoMoveBigger:(float)distance {
    UIView *secendView = [self topPhoto:2];
    UIImageView *secImageView = (UIImageView *)[secendView subviews].firstObject;
    
    UIView *thirdView = [self topPhoto:3];
    UIImageView *thImageView = (UIImageView *)[thirdView subviews].firstObject;

    // 注意: 外部的View变大了,但上面的imageview是不会跟着改变的,因为这不是autolayout
    if (distance <= 200) {
        // 设置倒数第二个View
        CGRect rect2;
        rect2.origin.x = (RECT1.origin.x*distance + 200*RECT2.origin.x - RECT2.origin.x*distance) / 200.0;
        rect2.origin.y = (RECT1.origin.y*distance + 200*RECT2.origin.y - RECT2.origin.y*distance) / 200.0;
        rect2.size.width = RECT2.size.width + (RECT1.size.width-RECT2.size.width)*distance/200.0;
        rect2.size.height = RECT2.size.height + (RECT1.size.height-RECT2.size.height)*distance/200.0;
        secendView.frame = rect2;
        
        CGRect rect22;
        rect22.origin.x = 5;
        rect22.origin.y = 5;
        rect22.size.width = rect2.size.width-10;
        rect22.size.height = rect2.size.height-10;
        secImageView.frame = rect22;
        
        // 设置倒数第三个View
        CGRect rect3;
        rect3.origin.x = (RECT2.origin.x*distance + 200*RECT3.origin.x - RECT3.origin.x*distance) / 200.0;
        rect3.origin.y = (RECT2.origin.y*distance + 200*RECT3.origin.y - RECT3.origin.y*distance) / 200.0;
        rect3.size.width = RECT3.size.width + (RECT2.size.width-RECT3.size.width)*distance/200.0;
        rect3.size.height = RECT3.size.height + (RECT2.size.height-RECT3.size.height)*distance/200.0;
        thirdView.frame = rect3;

        CGRect rect33;
        rect33.origin.x = 5;
        rect33.origin.y = 5;
        rect33.size.width = rect3.size.width-10;
        rect33.size.height = rect3.size.height-10;
        thImageView.frame = rect33;
    }
}

// 【拖动完成】移出图片
- (void)gPhotoInsert:(UIView *)backView {
    if ([self.delegate respondsToSelector:@selector(photoStackView:didEndMovingPhotoAtIndex:directionLeft:)]) {
        [self.delegate photoStackView:self didEndMovingPhotoAtIndex:backView.tag directionLeft:isLeft];
    }
    if (aDD < numberOfPhotos-CREATCount) {
        UIImage *image = [self.dataSource photoStackView:self photoForIndex:CREATCount+aDD];
        UIImageView *imageView = (UIImageView *)backView.subviews.firstObject;
        imageView.image = image;
        backView.tag = CREATCount + aDD;

        backView.transform = CGAffineTransformIdentity;
        backView.transform = CGAffineTransformMakeRotation(0);
        backView.frame = RECT3;
        imageView.frame = CGRectMake(5, 5, RECT3.size.width-10, RECT3.size.height-10);
        [self insertSubview:backView atIndex:0];
        
        backView.alpha = 1;
        
        aDD++;
    } else {
        [backView removeFromSuperview];
    }
}

// 【拖动完成】第二、三张图片放大并改变位置
- (void)gPhotoEndWithAnimation {
    UIView *secendView = [self topPhoto:2];
    UIImageView *secendImageView = (UIImageView *)[secendView subviews].firstObject;
    
    UIView *thirdView = [self topPhoto:3];
    UIImageView *thirdImageView = (UIImageView *)[thirdView subviews].firstObject;
    
    [UIView animateWithDuration:0.5 animations:^{
        secendView.frame = RECT1;
        secendImageView.frame = CGRectMake(5, 5, RECT1.size.width-10, RECT1.size.height-10);
        
        thirdView.frame = RECT2;
        thirdImageView.frame = CGRectMake(5, 5, RECT2.size.width-10, RECT2.size.height-10);
    }];
}

// 【没有移出】恢复原位置
- (void)gPhotoReturn {
    UIView *firstView = [self topPhoto:1];
    UIImageView *firImageView = (UIImageView *)[firstView subviews].firstObject;
    
    UIView *secendView = [self topPhoto:2];
    UIImageView *secImageView = (UIImageView *)[secendView subviews].firstObject;
    
    UIView *thirdView = [self topPhoto:3];
    UIImageView *thImageView = (UIImageView *)[thirdView subviews].firstObject;

    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        firstView.transform = CGAffineTransformIdentity;
        firstView.transform = CGAffineTransformMakeRotation(0);
        
        firstView.frame = RECT1;
        firImageView.frame = CGRectMake(5, 5, RECT1.size.width-10, RECT1.size.height-10);
        secendView.frame = RECT2;
        secImageView.frame = CGRectMake(5, 5, RECT2.size.width-10, RECT2.size.height-10);
        thirdView.frame = RECT3;
        thImageView.frame = CGRectMake(5, 5, RECT3.size.width-10, RECT3.size.height-10);
    } completion:nil];
}


@end
