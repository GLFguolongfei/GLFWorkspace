//
//  EditTableViewCell.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/10/19.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoLeftConstraint;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
