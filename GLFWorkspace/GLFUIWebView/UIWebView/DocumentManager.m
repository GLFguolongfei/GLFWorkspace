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

- (void)saveURLDict:(NSDictionary *)dict {
    BOOL isHaveSave = NO;
    NSArray *sandboxpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [sandboxpath objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"IP.plist"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    if (array == nil) {
        array = [[NSMutableArray alloc] init];
    } else {
        for (NSInteger i = 0; i < array.count; i++) {
            NSMutableDictionary *modelDict = array[i];
            if ([modelDict[@"ipStr"] isEqualToString:dict[@"ipStr"]]) {
                isHaveSave = YES;
                modelDict[@"isLastSelect"] = @"1";
            } else {
                modelDict[@"isLastSelect"] = @"0";
            }
            [array replaceObjectAtIndex:i withObject:dict];
        }
    }
    if (!isHaveSave) {
        [array addObject:dict];
    }
    [array writeToFile:plistPath atomically:YES];
}



@end
