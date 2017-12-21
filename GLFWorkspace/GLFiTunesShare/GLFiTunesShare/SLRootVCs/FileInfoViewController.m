//
//  FileInfoViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/10/24.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "FileInfoViewController.h"

@interface FileInfoViewController ()

@end

@implementation FileInfoViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景图片
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *isUseBackImagePath = [userDefaults objectForKey:IsUseBackImagePath];
    NSString *backName = [userDefaults objectForKey:BackImageName];
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    NSString *filePath = [cachePath stringByAppendingString:@"/image.png"];
    UIImage *backImage;
    if (isUseBackImagePath.integerValue) {
        backImage = [UIImage imageWithContentsOfFile:filePath];
    } else {
        backImage = [UIImage imageNamed:backName];
    }
    if (backImage == nil) {
        backImage = [UIImage imageNamed:@"bgView2"];
        [userDefaults setObject:@"bgView2" forKey:BackImageName];
        [userDefaults synchronize];
    }
    self.backImageView.image = backImage;

    NSRange range = [self.model.path rangeOfString:@"Documents"];
    NSString *str1 = [self.model.path substringWithRange:NSMakeRange(0, range.location+range.length)];
    NSString *str2 = [self.model.path substringWithRange:NSMakeRange(str1.length, self.model.path.length-str1.length)];
    NSString *name = [NSString stringWithFormat:@"%@\n%@", str1, str2];
    CGSize size = [GLFTools calculatingStringSizeWithString:name ByFont:KFontBold(18) andSize:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX)];
    self.nameLabelConstraint.constant = size.height + 30;
    self.nameLabel.text = name;
    
    self.label1.text = self.model.attributes[@"NSFileType"];
    self.label2.text = [GLFFileManager returenSizeStr:self.model.size];
    NSString *create = self.model.attributes[@"NSFileCreationDate"];
    NSString *update = self.model.attributes[@"NSFileModificationDate"];
    if ([[create class] isSubclassOfClass:[NSDate class]]) {
        NSDate *date = (NSDate *)create;
        self.label3.text = [date dateStringWithFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    }
    if ([[update class] isSubclassOfClass:[NSDate class]]) {
        NSDate *date = (NSDate *)update;
        self.label4.text = [date dateStringWithFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    }
}


@end
