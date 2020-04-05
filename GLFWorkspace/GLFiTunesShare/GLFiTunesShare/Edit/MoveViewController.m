//
//  MoveViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2018/5/30.
//  Copyright © 2018年 GuoLongfei. All rights reserved.
//

#import "MoveViewController.h"
#import "EditTableViewCell.h"

static NSString *cellID = @"GLFTableViewCellID";

@interface MoveViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UIScrollView *scrollView;
    UITableView *myTableView;
    NSMutableArray *myDataArray;
    NSString *documentPath;
    UIView *sliderView;
    UIActivityIndicatorView *actView;
}
@end

@implementation MoveViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];

    [self prepareInterface];
    [self prepareData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareData) name:DocumentPathArrayUpdate object:nil];
}

// 更改状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)prepareData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentPath = [paths objectAtIndex:0];
    myDataArray = [[NSMutableArray alloc] init];
    
    [actView startAnimating];
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:DocumentPathArray];
    if (array.count != 0) {
        [myDataArray addObjectsFromArray:array];
        [myTableView reloadData];
        [actView stopAnimating];
        if (myDataArray.count > 300) {
            sliderView.hidden = NO;
        } else {
            sliderView.hidden = YES;
        }
    } else {
        [DocumentManager updateDocumentPaths];
    }
}

- (void)prepareInterface {
    UIImageView *bImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bImageView.image = [UIImage imageNamed:@"bgview2"];
    bImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:bImageView];
    
    CGRect scrollViewRect = CGRectMake(0, 100, kScreenWidth, kScreenHeight-100);
    scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    scrollView.showsHorizontalScrollIndicator = YES; // 隐藏滚动条(横向的)
    scrollView.showsVerticalScrollIndicator = YES;   // 隐藏滚动条(纵向的)
    scrollView.contentSize = scrollViewRect.size;    // 内容(如果在某一个方向上,小于控件本身的大小,那个方向不可以滑动)
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    
    CGRect tableViewRect = CGRectMake(0, 0, kScreenWidth, kScreenHeight-100);
    myTableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStylePlain];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.separatorInset = UIEdgeInsetsMake(0, -20, 0, 0);
    myTableView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:myTableView];
    myTableView.tableFooterView = [[UIView alloc] init];
    [myTableView registerNib:[UINib nibWithNibName:@"EditTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    
    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
    back.backgroundColor = KNavgationBarColor;
    [self.view addSubview:back];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, kScreenWidth, 20)];
    label1.text = @"选取添加这些项目的位置";
    label1.textAlignment = NSTextAlignmentCenter;
    label1.font = [UIFont systemFontOfSize:14];
    label1.textColor = [UIColor whiteColor];
    [back addSubview:label1];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 40, 60, 60)];
    imageView.image = [UIImage imageNamed:@"wenjianjia"];
    [back addSubview:imageView];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(85, 40, 300, 60)];
    label3.text = @"NSDocumentDirectory";
    label3.textAlignment = NSTextAlignmentLeft;
    label3.font = [UIFont systemFontOfSize:18];
    label3.textColor = [UIColor whiteColor];
    [back addSubview:label3];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-85, 25, 85, 70)];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [back addSubview:button];
    
    // 点按手势
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(tapAction:)];
    [imageView addGestureRecognizer:tapGesture];

    // slider
    sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 80, kScreenHeight-100)];
    sliderView.backgroundColor = [UIColor clearColor];
    if (myDataArray.count > 300) {
        sliderView.hidden = NO;
    } else {
        sliderView.hidden = YES;
    }
    [self.view addSubview:sliderView];
    CGRect rect = CGRectMake(-kScreenWidth/2-40, kScreenHeight/2-85, kScreenHeight-140, 80);
    UISlider *slider = [[UISlider alloc] initWithFrame:rect];
    slider.value = 0;
    slider.backgroundColor = [UIColor clearColor];
    slider.minimumValue = 0;
    slider.maximumValue = 100;
    slider.minimumTrackTintColor = KNavgationBarColor;
    slider.maximumTrackTintColor = [UIColor lightGrayColor];
    slider.thumbTintColor = KNavgationBarColor;
    [sliderView addSubview:slider];
    // 设置旋转90度
    slider.transform = CGAffineTransformMakeRotation(1.57079633);
    // 连续滑动是否触发方法,默认值为YES
    slider.continuous = YES;
    [slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    
    actView =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    actView.frame = scrollViewRect;     // 大小是固定的,之所以设置这么大,好处是可以隔绝响应事件
    actView.hidesWhenStopped = YES;     // 设置指示器是否停止动画时隐藏
    actView.color = [UIColor redColor]; // 设置指示器颜色
    [self.view addSubview:actView];
}

#pragma mark Events
- (void)buttonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tapAction:(UITapGestureRecognizer *)gesture {
    [self moveTo:@""];
}

- (void)sliderChange:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSInteger index = (NSInteger)(slider.value/100.0 * (myDataArray.count-1));
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)moveTo:(NSString *)path {
    [self showHUD:@"移动中, 不要着急!"];
    for (int i = 0; i < self.modelArray.count; i++) {
        FileModel *model = self.modelArray[i];
        NSString *toPath = [NSString stringWithFormat:@"%@/%@/%@", documentPath, path, model.name];
        if ([toPath isEqualToString:model.path]) {
            [self showStringHUD:@"目标路径不能与源路径相同" second:1.5];
            return;
        }
        if ([toPath containsString:model.path]) {
            [self showStringHUD:@"目标路径不能是源路径的子路径" second:1.5];
            return;
        }
        BOOL success = [GLFFileManager fileMove:model.path toPath:toPath];
        if (!success) {
            NSLog(@"%@ 移动失败", model.path);
        }
    }
    [self hideAllHUD];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return myDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    NSArray *array = [myDataArray[indexPath.row] componentsSeparatedByString:@"/"];
    CGFloat space = 15;
    if (array.count > 1) {
        for (int i = 0; i < array.count-1; i++) {
            space += 20;
        }
    }
    if (array.count > 6) {
        myTableView.frame = CGRectMake(0, 0, kScreenWidth*1.5, kScreenHeight-100);
        scrollView.contentSize = CGSizeMake(kScreenWidth*1.5, kScreenHeight-100);
    } else if (array.count > 10) {
        myTableView.frame = CGRectMake(0, 0, kScreenWidth*2, kScreenHeight-100);
        scrollView.contentSize = CGSizeMake(kScreenWidth*2, kScreenHeight-100);
    }
    cell.photoLeftConstraint.constant = space;
    cell.contentLabel.text = array.lastObject;
    // 背景色
    UIView *view = [[UIView alloc] initWithFrame:cell.frame];
    view.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = view;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self moveTo:myDataArray[indexPath.row]];
    [DocumentManager updateDocumentPaths];
}


@end
