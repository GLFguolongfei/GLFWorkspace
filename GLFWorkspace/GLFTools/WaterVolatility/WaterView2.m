//
//  WaterView2.m
//  WaterVolatility
//
//  Created by guolongfei on 2017/8/4.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "WaterView2.h"

#pragma mark 适配
#define kScreen [[UIScreen mainScreen] bounds]
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface WaterView2 ()
{
    UIColor *upWaterColor; // 上面水的颜色
    UIColor *downWaterColor; // 下面水的颜色
    
    float _currentLinePointY;  // 水波的平均水平线
    
    float a;
    float b;
    
    BOOL jia;
    
    float upLeftX;      // 开始为上的波浪 最左边的点 的x坐标
    float upLeftY;      // 开始为上的波浪 最左边的点 的y坐标
    float upRightX;     // 开始为上的波浪 最右边的点 的x坐标
    float upRightY;     // 开始为上的波浪 最右边的点 的y坐标
    
    float downLeftX;    // 开始为下的波浪 最左边的点 的x坐标
    float downLeftY;    // 开始为下的波浪 最左边的点 的y坐标
    float downRightX;   // 开始为下的波浪 最左边的点 的x坐标
    float downRightY;   // 开始为下的波浪 最左边的点 的y坐标
    
    NSTimer *myTimer;
}
@end

@implementation WaterView2


#pragma mark init
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        a = 1.5;
        b = 0;
        
        jia = NO;
        
        // ------- 水的颜色可以设置
        upWaterColor = [UIColor colorWithRed:24/255.0f green:138/255.0f blue:225/255.0f alpha:0.3];
        downWaterColor = [UIColor colorWithRed:43/255.0f green:111/255.0f blue:219/255.0f alpha:0.5];
        // 水的高度可以设置
        _currentLinePointY = kScreenHeight-150;
        
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(animateWave) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)removeFromSuperview {
    [myTimer invalidate];
}

- (void)animateWave {
    if (jia) {
        a += 0.005;
    } else {
        a -= 0.005;
    }
    if (a<=1) {
        jia = YES;
    }
    if (a>=1.5) {
        jia = NO;
    }
    if (self.addPointX < 0.05) {
        b += 0.05;
    } else {
        b += self.addPointX;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self testOne:context andRect:rect];
    [self testTwo:context andRect:rect];
}

- (void)testOne:(CGContextRef)context andRect:(CGRect)rect {
    // 1-获取上下文路径等
    CGMutablePathRef path = CGPathCreateMutable();
    // 2-设置线的宽度和填充颜色
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, [downWaterColor CGColor]);
    // 3-设置当前path点的位置
    float y = _currentLinePointY;
    CGPathMoveToPoint(path, NULL, 0, y);
    // 4-开始为上的波浪
    for(float x = 0; x <= kScreenWidth; x++){
        y = a * sin(x/180*M_PI + 4*b/M_PI) * (-15) + _currentLinePointY;
        if (x == 0) {
            upLeftX = 0;
            upLeftY = y;
        }
        if (x == kScreenWidth) {
            upRightX = kScreenWidth;
            upRightY = y;
        }
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    // 连成一个闭合的区域
    CGPathAddLineToPoint(path, nil, kScreenWidth, rect.size.height);
    CGPathAddLineToPoint(path, nil, 0, rect.size.height);
    CGPathAddLineToPoint(path, nil, upLeftX, upLeftY);
    
    // 填充颜色
    CGContextAddPath(context, path);
    CGContextFillPath(context); // 只填充颜色(注意、想要填充 必须是闭合的曲线)
    CGContextDrawPath(context, kCGPathStroke); // 画轮廓
    
    CGPathAddLineToPoint(path, nil, 0, upLeftY);
    // 5-开始为下得波浪
    for(float x = 0; x <= kScreenWidth; x++){
        y = a * sin(x/180*M_PI + 4*b/M_PI) * 15 + _currentLinePointY;
        if (x == 0) {
            downLeftX = 0;
            downLeftY = y;
        }
        if (x == kScreenWidth) {
            downRightX = kScreenWidth;
            downRightY = y;
        }
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    // 连成一个闭合的区域
    CGPathAddLineToPoint(path, nil, kScreenWidth, rect.size.height);
    CGPathAddLineToPoint(path, nil, 0, rect.size.height);
    CGPathAddLineToPoint(path, nil, downLeftX, downLeftY);
    
    // 填充颜色
    CGContextAddPath(context, path);
    CGContextFillPath(context); // 只填充颜色(注意、想要填充 必须是闭合的曲线)
    CGContextDrawPath(context, kCGPathStroke); // 画轮廓
    
    CGPathRelease(path);
}

- (void)testTwo:(CGContextRef)context andRect:(CGRect)rect {
    // 1-获取上下文路径等
    CGMutablePathRef path = CGPathCreateMutable();
    // 2-设置线的宽度和填充颜色
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, [upWaterColor CGColor]);
    // 3-设置当前path点的位置
    float y = _currentLinePointY;
    CGPathMoveToPoint(path, NULL, 0, y);
    // 4-开始为上的波浪
    for(float x = 0; x <= kScreenWidth; x++){
        y = a * sin(x/180*M_PI + 4*b/M_PI) * (-15) + _currentLinePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    // 5-将上波浪的终点与下波浪的始点连接
    CGPathAddLineToPoint(path, nil, kScreenWidth, downRightY);
    // 6-开始为下得波浪
    for(float x=kScreenWidth; x>=0; x--){
        y = a * sin(x/180*M_PI + 4*b/M_PI) * 15 + _currentLinePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    // 7-连成一个闭合的曲线
    CGPathAddLineToPoint(path, nil, 0, upLeftX);
    
    // 8-填充颜色
    CGContextAddPath(context, path);
    CGContextFillPath(context); // 只填充颜色(注意、想要填充 必须是闭合的曲线)
    CGContextDrawPath(context, kCGPathStroke); // 画轮廓
    
    CGPathRelease(path);
}


@end
