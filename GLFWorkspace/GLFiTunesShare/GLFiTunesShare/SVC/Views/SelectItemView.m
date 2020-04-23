//
//  SelectItemView.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/4/23.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "SelectItemView.h"

@interface SelectItemView ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *myTableView;
    NSIndexPath *currentIndexPath;
}
@end

@implementation SelectItemView


#pragma mark - Life Cycle
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;

    CGRect tableFrame = CGRectMake(0, 5, self.bounds.size.width, self.bounds.size.height - 10);
    myTableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self addSubview:myTableView];
    myTableView.tableFooterView = [[UIView alloc] init];
    
    CGRect viewFrame = CGRectMake(self.bounds.size.width - 90, self.bounds.size.height - 90, 80, 80);
    UIView *bgview = [[UIView alloc] initWithFrame:viewFrame];
    bgview.backgroundColor = KNavgationBarColor;
    bgview.alpha = 0.5;
    bgview.layer.cornerRadius = 40;
    bgview.layer.masksToBounds = YES;
    [self addSubview:bgview];
    CGRect buttonFrame = CGRectMake(self.bounds.size.width - 100, self.bounds.size.height - 100, 100, 100);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button setTitle:@"当前" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < self.dataArray.count; i++) {
            FileModel *model = self.dataArray[i];
            if ([model.name isEqualToString:self.currentModel.name]) {
                currentIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (currentIndexPath != nil) {
                [myTableView scrollToRowAtIndexPath:currentIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        });
    });
}

- (void)buttonAction {
    [myTableView scrollToRowAtIndexPath:currentIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = self.dataArray[indexPath.row];
    // 计算的不太准
    CGSize size = [GLFTools calculatingStringSizeWithString:model.name ByFont:KFontSize(16) andSize:CGSizeMake(self.bounds.size.width - 50, kScreenHeight)];
    return size.height + 35;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UITableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    FileModel *model = self.dataArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"【%ld】%@", indexPath.row + 1, model.name];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    if ([model.name isEqualToString:self.currentModel.name]) {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.pageType == 1) {
        DYViewController *vc = (DYViewController *)self.parentVC;
        [vc playRandom:indexPath.row];
    } else if (self.pageType == 2) {
        DYNextViewController *vc = (DYNextViewController *)self.parentVC;
        [vc playRandom:indexPath.row];
    }
    [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationSpring new]];
}


@end
