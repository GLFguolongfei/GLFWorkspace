//
//  SelectIPView.m
//  UIWebView
//
//  Created by guolongfei on 2017/12/8.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "SelectIPView.h"
#import "IpModel.h"
#import "LewPopupViewController.h"
#import "GLFTools.h"

@interface SelectIPView ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *myTableView;
    NSMutableArray *myDataArray;
}
@end

@implementation SelectIPView


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
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"IP.plist"];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
    for (NSInteger i = 0; i < array.count; i++) {
        NSDictionary *dict = array[i];
        IpModel *model = [[IpModel alloc] init];
        model.ipStr = dict[@"ipStr"];
        model.ipDescribe = dict[@"ipDescribe"];
        model.isLastSelect = [dict[@"isLastSelect"] boolValue];
        [myDataArray addObject:model];
    }
    [myTableView reloadData];
}

- (void)setupUI {
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    myTableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self addSubview:myTableView];
    myTableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    IpModel *model = myDataArray[indexPath.row];
    // 计算的不太准
    CGSize size = [GLFTools calculatingStringSizeWithString:model.ipStr ByFont:KFontSize(16) andSize:CGSizeMake(kScreenWidth/4*3-50, kScreenHeight)];
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
    
    IpModel *model = myDataArray[indexPath.row];
    cell.textLabel.text = model.ipStr;
    cell.detailTextLabel.text = model.ipDescribe;
    if (model.isLastSelect) {
        cell.textLabel.textColor = [UIColor redColor];
        cell.detailTextLabel.textColor = [UIColor redColor];
    } else {
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IpModel *model = myDataArray[indexPath.row];
    _parentVC.ipTextView.text = model.ipStr;
    [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationSpring new]];
    
    // 保存
    NSArray *sandboxpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [sandboxpath objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"IP.plist"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    if (array == nil) {
        array = [[NSMutableArray alloc] init];
    } else {
        for (NSInteger i = 0; i < array.count; i++) {
            NSMutableDictionary *dict = array[i];
            if ([dict[@"ipStr"] isEqualToString:model.ipStr]) {
                dict[@"isLastSelect"] = @"1";
            } else {
                dict[@"isLastSelect"] = @"0";
            }
            [array replaceObjectAtIndex:i withObject:dict];
        }
    }
    [array writeToFile:plistPath atomically:YES];
}

#pragma mark 编辑
- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self deleteAction:indexPath];
    }];
    UITableViewRowAction *more = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"更改备注" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"更多 %@ %@", action, indexPath);
        [self renameAction:indexPath];
    }];
    NSArray *array = @[delete, more];
    return array;
}

- (void)deleteAction:(NSIndexPath *)indexPath {
    IpModel *model = myDataArray[indexPath.row];
    NSString *str = [NSString stringWithFormat:@"是否确定删除URL [%@]", model.ipStr];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:model.ipDescribe message:str preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [alertVC addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 保存
        NSArray *sandboxpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [sandboxpath objectAtIndex:0];
        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"IP.plist"];
        NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
        if (array == nil) {
            array = [[NSMutableArray alloc] init];
        } else {
            for (NSInteger i = 0; i < array.count; i++) {
                NSMutableDictionary *dict = array[i];
                if ([dict[@"ipStr"] isEqualToString:model.ipStr]) {
                    [array removeObject:dict];
                    break;
                }
            }
        }
        [array writeToFile:plistPath atomically:YES];
        [self setupData];
    }];
    [alertVC addAction:okAction];
    [self.parentVC presentViewController:alertVC animated:YES completion:nil];
}

- (void)renameAction:(NSIndexPath *)indexPath {
    IpModel *model = myDataArray[indexPath.row];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"给URL修改备注" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    [alertVC addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (alertVC.textFields.count > 0) {
            UITextField *textField = alertVC.textFields.firstObject;
            NSLog(@"重命名名称: %@", textField.text);
            
            // 保存
            NSArray *sandboxpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [sandboxpath objectAtIndex:0];
            NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"IP.plist"];
            NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
            if (array == nil) {
                array = [[NSMutableArray alloc] init];
            } else {
                for (NSInteger i = 0; i < array.count; i++) {
                    NSMutableDictionary *dict = array[i];
                    if ([dict[@"ipStr"] isEqualToString:model.ipStr]) {
                        dict[@"ipDescribe"] = textField.text;
                    }
                    [array replaceObjectAtIndex:i withObject:dict];
                }
            }
            [array writeToFile:plistPath atomically:YES];
            [self setupData];
        }
    }];
    [alertVC addAction:okAction];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入新名称";
        textField.text = model.ipDescribe;
    }];
    [self.parentVC presentViewController:alertVC animated:YES completion:nil];
}


@end
