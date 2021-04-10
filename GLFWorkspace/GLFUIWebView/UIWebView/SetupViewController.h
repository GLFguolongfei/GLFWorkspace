//
//  SetupViewController.h
//  UIWebView
//
//  Created by guolongfei on 2020/3/10.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SetupViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UISwitch *switch1;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UISwitch *switch2;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UISwitch *switch3;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UISwitch *switch4;
@property (weak, nonatomic) IBOutlet UILabel *label4;

@property (weak, nonatomic) IBOutlet UIButton *webviewButton;

@end

NS_ASSUME_NONNULL_END
