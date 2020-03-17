//
//  SixViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/22.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "SixViewController.h"
#import "MathViewController.h"

@interface SixViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *myTableView;
    NSArray *myDataArray;
}
@end

@implementation SixViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日常小玩意";

    myDataArray = @[@"数学绘图"];
   
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
    if (indexPath.row == 0) { // 数学图形
        MathViewController *VC = [[MathViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
    }
}


@end
