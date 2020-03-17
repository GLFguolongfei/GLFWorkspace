//
//  FiveViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/22.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "FiveViewController.h"
#import "QQL_CompassViewController.h"
#import "QQL_RuleViewController.h"
#import "QQL_LevelViewController.h"
#import "QQL_NoiseViewController.h"
#import "QQL_MirrorViewController.h"
#import "QQL_CorrectViewController.h"
#import "QQL_ProtractorViewController.h"
#import "QQL_NetworkSpeedViewController.h"
#import "MMScanViewController.h"

@interface FiveViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *myTableView;
    NSArray *myDataArray;
}
@end

@implementation FiveViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日常小工具";

    myDataArray = @[@"指南针",@"量角器",@"测噪音",@"测网速",@"水平仪",@"挂物矫正",@"尺子",@"镜子",@"扫描二维码条形码"];
   
    CGRect react = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    myTableView = [[UITableView alloc] initWithFrame:react style:UITableViewStylePlain];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    myTableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return myDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UITableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
//    cell.imageView.image = [UIImage imageNamed:@"icon_评价"];
    cell.textLabel.text = [NSString stringWithFormat:@"  %@", myDataArray[indexPath.row]];
    cell.textLabel.font = [UIFont fontWithName:myDataArray[indexPath.row] size:18];
//    cell.detailTextLabel.text = myDataArray[indexPath.row];
//    cell.detailTextLabel.textColor = [UIColor redColor];
    
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) { // 指南针
        QQL_CompassViewController *VC = [[QQL_CompassViewController alloc] init];
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:VC animated:YES];
    } else if (indexPath.row == 1) { // 量角器
        QQL_ProtractorViewController *VC = [[QQL_ProtractorViewController alloc] init];
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:VC animated:YES];
    } else if (indexPath.row == 2) { // 测噪音
        QQL_NoiseViewController *VC = [[QQL_NoiseViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
    } else if (indexPath.row == 3) { // 测网速
        QQL_NetworkSpeedViewController *VC = [[QQL_NetworkSpeedViewController alloc] init];
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:VC animated:YES];
    } else if (indexPath.row == 4) { // 水平仪
        QQL_LevelViewController *VC = [[QQL_LevelViewController alloc] init];
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:VC animated:YES];
    } else if (indexPath.row == 5) { // 挂物矫正
        QQL_CorrectViewController *VC = [[QQL_CorrectViewController alloc] init];
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:VC animated:YES];
    } else if (indexPath.row == 6) { // 尺子
        QQL_RuleViewController *VC = [[QQL_RuleViewController alloc] init];
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:VC animated:YES];
    } else if (indexPath.row == 7) { // 镜子
        QQL_MirrorViewController *VC = [[QQL_MirrorViewController alloc] init];
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:VC animated:YES];
    } else if (indexPath.row == 8) {
        MMScanViewController *scanVc = [[MMScanViewController alloc] initWithQrType:MMScanTypeAll onFinish:^(NSString *result, NSError *error) {
            if (error) {
                NSLog(@"error: %@", error);
                [self showStringHUD:error.localizedDescription second:1.5];
            } else {
                NSLog(@"扫描结果：%@", result);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:result delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }];
        [scanVc setHistoryCallBack:^(NSArray *result) {
            NSLog(@"%@", result);
        }];
        [self.navigationController pushViewController:scanVc animated:YES];
    }
}


@end
