//
//  MyView.m
//  太极图
//
//  Created by huangdl on 14-9-3.
//  Copyright (c) 2014年 1000phone. All rights reserved.
//

#import "MyView.h"

#define degreeToRadians(x) (M_PI*(x)/180.0) // 宏定义圆弧角度

@interface MyView ()
{
    CGFloat _angle;   // 角度
    CGFloat _biggerR; // 大圆半径
    CGFloat _smallR;  // 小圆半径
    
    NSTimer *myTimer;
}
@end

@implementation MyView


#pragma mark - init
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _angle = 30;
        _biggerR = frame.size.height/2;
        _smallR = _biggerR/6;
        
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)removeFromSuperview {
    [myTimer invalidate];
}

- (void)timerAction {
    if (self.addAngle < 1) {
        _angle += 1;
    } else {
        _angle += self.addAngle;
    }
    [self setNeedsDisplay]; // 注意: 该方法会自动调用下面的方法
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctf = UIGraphicsGetCurrentContext();
    
    // 1-画最外层的大圆
    CGContextAddEllipseInRect(ctf, CGRectMake(1, 1, _biggerR*2-2, _biggerR*2-2));
    CGContextStrokePath(ctf); // 只画圆的轮廓
    
    // 2-画圆弧 注意: 之所以再画一段重复的弧段是因为要围成一个区域 以便填充颜色
    CGContextAddArc(ctf, _biggerR, _biggerR, _biggerR-1, degreeToRadians(-_angle), degreeToRadians(-_angle + 180), 1);
    
    CGContextAddArc(ctf, _biggerR+(_biggerR-1)*cos(degreeToRadians(_angle+180))/2, _biggerR - (_biggerR-1)*sin(degreeToRadians(_angle+180))/2, (_biggerR-1)/2, degreeToRadians(-_angle + 180), degreeToRadians(-_angle), 1);

    CGContextAddArc(ctf, _biggerR+(_biggerR-1)*cos(degreeToRadians(_angle))/2, _biggerR - (_biggerR-1)*sin(degreeToRadians(_angle))/2, (_biggerR-1)/2, degreeToRadians(-_angle + 180), degreeToRadians(-_angle), 0);

    // 3-画两个小圆
    CGContextAddEllipseInRect(ctf, CGRectMake(_biggerR+(_biggerR-1)*cos(degreeToRadians(_angle+180))/2 - _smallR, _biggerR - (_biggerR-1)*sin(degreeToRadians(_angle+180))/2 - _smallR, _smallR * 2, _smallR *2));

    CGContextAddEllipseInRect(ctf, CGRectMake(_biggerR+(_biggerR-1)*cos(degreeToRadians(_angle))/2 - _smallR, _biggerR - (_biggerR-1)*sin(degreeToRadians(_angle))/2 - _smallR, _smallR * 2, _smallR * 2));
  
    
//    CGContextStrokePath(ctf); // 只画轮廓
    CGContextFillPath(ctf);     // 只填充颜色(只填充从上一个画图方法CGContextStrokePath之后的闭合线段代码)
}


@end
