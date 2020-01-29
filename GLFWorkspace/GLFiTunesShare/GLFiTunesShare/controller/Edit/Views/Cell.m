
/*
     File: Cell.m
 Abstract: 
  Version: 1.0
 */

#import "Cell.h"
#import <QuartzCore/CALayer.h>

@implementation Cell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 1-Imageview
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
        // 2-Label
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width/2, 25)];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:17];
        self.label.textColor = [UIColor colorWithHexString:@"2C84E8"];
        [self.contentView addSubview:self.label];

//        self.contentView.layer.borderWidth = 1;
//        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end
