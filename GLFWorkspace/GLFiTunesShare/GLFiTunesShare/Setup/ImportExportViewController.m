//
//  ImportExportViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2021/3/13.
//  Copyright © 2021 GuoLongfei. All rights reserved.
//

#import "ImportExportViewController.h"

@interface ImportExportViewController ()<UIDocumentPickerDelegate>

@end

@implementation ImportExportViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setVCTitle:@"导入数据"];

    for (int i = 0; i < 4; i++) {
        CGFloat width = (kScreenWidth - 60) / 2;
        CGRect frame = CGRectMake(20 * (i % 2 + 1) + width * (i % 2), 100 + 80 * ceil(i / 2), width, 60);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        button.backgroundColor = [UIColor lightGrayColor];
        if (i == 0) {
            [button setTitle:@"从iCloud导入" forState:UIControlStateNormal];
        } else if (i == 1) {
            [button setTitle:@"导出至iCloud" forState:UIControlStateNormal];
        } else if (i == 2) {
            [button setTitle:@"从Photos导入" forState:UIControlStateNormal];
        } else if (i == 3) {
            [button setTitle:@"导出至Photos" forState:UIControlStateNormal];
        }
        [self.view addSubview:button];
        button.tag = 100 + i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
    }
}

- (void)buttonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == 100) {
        NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code ", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
        UIDocumentPickerViewController *controller = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeImport];
        controller.delegate = self;
        controller.allowsMultipleSelection = YES; // 只支持iOS11.0以上
        [self presentViewController:controller animated:YES completion:nil];
    } else if (button.tag == 101) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
        UIDocumentPickerViewController *controller = [[UIDocumentPickerViewController alloc] initWithURL:url inMode:UIDocumentPickerModeExportToService];
        controller.delegate = self;
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:controller animated:YES completion:nil];
    } else if (button.tag == 102) {
        [self showStringHUD:@"暂未实现！！！" second:1.5];
        // UIImagePickerController
    } else if (button.tag == 103) {
        [self showStringHUD:@"暂未实现！！！" second:1.5];
        // UIImageWriteToSavedPhotosAlbum
        // UIVideoAtPathIsCompatibleWithSavedPhotosAlbum
        // UISaveVideoAtPathToSavedPhotosAlbum
    }
}

#pragma mark UIDocumentPickerDelegate
// iOS11.0以上
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls {
    NSLog(@"111: %@", urls);
}

// iOS11.0以下
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    NSLog(@"333: %@", url);
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *sourcePath = url.path;
        NSArray *array = [sourcePath componentsSeparatedByString:@"/"];
        if (array.count > 0) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsPath, array.lastObject];
            BOOL isSuccess = [GLFFileManager fileCopy:sourcePath toPath:filePath];
            if (isSuccess) {
                [self showStringHUD:@"导入成功！！！" second:1.5];
            } else {
                [self showStringHUD:@"导入失败！！！" second:1.5];
            }
        }
    } else if (controller.documentPickerMode == UIDocumentPickerModeExportToService) {
        [self showStringHUD:@"导出成功！！！" second:1.5];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"222: %@", controller);
}


@end
