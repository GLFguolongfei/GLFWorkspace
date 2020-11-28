//
//  BlackIPView.m
//  UIWebView
//
//  Created by guolongfei on 2020/11/29.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "BlackIPView.h"
#import "LewPopupViewController.h"
#import "GLFTools.h"

@interface BlackIPView ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *myTableView;
    NSMutableArray *myDataArray;
}
@end

@implementation BlackIPView


#pragma mark - Life Cycle
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    [self setupData];
    [self setupUI];
}

- (void)setupData {
    myDataArray = [[NSMutableArray alloc] init];
    NSArray *sandboxpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [sandboxpath objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"IPBlack.plist"];
    myDataArray = (NSMutableArray *)[[NSArray alloc] initWithContentsOfFile:plistPath];
    [myTableView reloadData];
}

- (void)setupUI {
    CGRect rect = CGRectMake(0, 5, self.bounds.size.width, self.bounds.size.height - 10);
    myTableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self addSubview:myTableView];
    myTableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = myDataArray[indexPath.row];
    // 计算的不太准
    CGSize size = [GLFTools calculatingStringSizeWithString:str ByFont:KFontSize(16) andSize:CGSizeMake(self.bounds.size.width - 50, kScreenHeight)];
    return size.height + 35;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return myDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UITableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSString *str = myDataArray[indexPath.row];
    cell.textLabel.text = str;
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark 编辑
- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self deleteAction:indexPath];
    }];
    NSArray *array = @[delete];
    return array;
}

- (void)deleteAction:(NSIndexPath *)indexPath {
    NSString *ipStr = myDataArray[indexPath.row];
    NSString *str = [NSString stringWithFormat:@"是否确定从黑名单移除URL [%@]", ipStr];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:str preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertVC addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSArray *sandboxpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [sandboxpath objectAtIndex:0];
        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"IPBlack.plist"];
        [myDataArray removeObjectAtIndex:indexPath.row];
        [myDataArray writeToFile:plistPath atomically:YES];
        [myTableView reloadData];
    }];
    [alertVC addAction:okAction];
    [self.parentVC presentViewController:alertVC animated:YES completion:nil];
}


@end
