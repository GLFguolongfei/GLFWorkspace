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
    [self setVCTitle:self.model.name];

    CGSize size = [GLFTools calculatingStringSizeWithString:self.model.path ByFont:KFontBold(18) andSize:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX)];
    self.pathHeightConstraint.constant = size.height + 30;
    self.pathLabel.text = self.model.path;
    
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
    
    for (NSString *key in self.model.attributes) {
        NSLog(@"%@ : %@", key, [self.model.attributes objectForKey:key]);
    }
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"详情1" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"详情1" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }];
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"详情2" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"详情2" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }];
    NSArray *actions = @[action1, action2];
    return actions;
}


@end
