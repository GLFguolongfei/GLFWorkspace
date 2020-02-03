//
//  TwoViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/3.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "TwoViewController.h"

@interface TwoViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *myTableView;
    NSArray *myDataArray;
}
@end

@implementation TwoViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"iOS字体";
    
    myDataArray = [UIFont familyNames];
    myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
}

#pragma mark UITableViewDelegate(HeaderAndFooter)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%ld : %@", section, myDataArray[section]];
}

#pragma mark UITableViewDelegate(Cell)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return myDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *currentNames = [UIFont fontNamesForFamilyName:myDataArray[section]];
    return currentNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UITableViewCellIdentifierKey1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    NSArray *currentNames = [UIFont fontNamesForFamilyName:myDataArray[indexPath.section]];
    NSString *currentFontStr = currentNames[indexPath.row];
    
    cell.textLabel.text = currentFontStr;
    cell.textLabel.font = [UIFont fontWithName:currentFontStr size:18];
    cell.textLabel.textColor = [UIColor blackColor];
    
    if ([currentFontStr isEqualToString:@"Helvetica"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"默认字体: %@", currentFontStr];
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *currentNames = [UIFont fontNamesForFamilyName:myDataArray[indexPath.section]];
    NSString *currentFontStr = currentNames[indexPath.row];
    
    UIFont *font = [UIFont fontWithName:currentFontStr size:20];
    
    NSLog(@"字体的family名称: %@", font.familyName);
    NSLog(@"字体名称: %@", font.fontName);
    
    NSLog(@"字体大小: %f", font.pointSize);
    NSLog(@"ascender的值: %f", font.ascender);
    NSLog(@"descender的值: %f", font.descender);
    
    NSLog(@"大文字的高度: %f", font.capHeight);
    NSLog(@"小文字[x]的高度: %f", font.xHeight);
    NSLog(@"行的高度: %f", font.lineHeight);
    NSLog(@"font.leading: %f", font.leading);
}


@end
