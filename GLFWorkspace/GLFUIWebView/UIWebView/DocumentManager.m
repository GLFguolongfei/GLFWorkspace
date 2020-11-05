//
//  DocumentManager.m
//  UIWebView
//
//  Created by guolongfei on 2020/3/10.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "DocumentManager.h"

@implementation DocumentManager

HMSingletonM(DocumentManager)

- (void)addURL:(NSDictionary *)urlDict {
    BOOL isHaveSave = NO;
    NSString *plistPath = [DocumentManager getPathWithActionType:1];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    if (array == nil) {
        array = [[NSMutableArray alloc] init];
    } else {
        for (NSInteger i = 0; i < array.count; i++) {
            NSMutableDictionary *dict = array[i];
            if ([dict[@"ipStr"] isEqualToString:urlDict[@"ipStr"]]) {
                isHaveSave = YES;
                dict[@"ipStr"] = urlDict[@"ipStr"];
                dict[@"isLastSelect"] = @"1";
            } else {
                dict[@"isLastSelect"] = @"0";
            }
            [array replaceObjectAtIndex:i withObject:dict];
        }
    }
    if (!isHaveSave) {
        [array addObject:urlDict];
    }
    [array writeToFile:plistPath atomically:YES];
}

- (void)deleteURL:(NSString *)urlStr {
    BOOL isHaveSave = NO;
    NSString *plistPath = [DocumentManager getPathWithActionType:2];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    if (array == nil) {
        return;
    } else {
        for (NSInteger i = 0; i < array.count; i++) {
            NSMutableDictionary *dict = array[i];
            if ([dict[@"ipStr"] isEqualToString:urlStr]) {
                isHaveSave = YES;
                [array removeObject:dict];
                break;
            }
        }
    }
    if (isHaveSave) {
        [array writeToFile:plistPath atomically:YES];
    }
}

- (void)clearURL {
    NSString *plistPath = [DocumentManager getPathWithActionType:2];
    NSMutableArray *array = array = [[NSMutableArray alloc] init];;
    [array writeToFile:plistPath atomically:YES];
}

- (void)renameURL:(NSDictionary *)urlDict {
    BOOL isHaveSave = NO;
    NSString *plistPath = [DocumentManager getPathWithActionType:2];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    if (array == nil) {
        array = [[NSMutableArray alloc] init];
    } else {
        for (NSInteger i = 0; i < array.count; i++) {
            NSMutableDictionary *dict = array[i];
            if ([dict[@"ipStr"] isEqualToString:urlDict[@"ipStr"]]) {
                isHaveSave = YES;
                [array replaceObjectAtIndex:i withObject:urlDict];
                break;
            }
        }
    }
    if (isHaveSave) {
        [array writeToFile:plistPath atomically:YES];
    }
}

#pragma mark Tools
// 1-记录 2-删除重命名
+ (NSString *)getPathWithActionType:(NSInteger)actionType {
    NSArray *sandboxpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [sandboxpath objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"IP.plist"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *isNORecord = [userDefaults objectForKey:kNORecord];
    if (isNORecord.integerValue == 1) {
        plistPath = [documentsDirectory stringByAppendingPathComponent:@"IPSecret.plist"];
    }
    return plistPath;
}


@end
