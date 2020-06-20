//
//  ProjectManager.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/6/20.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "ProjectManager.h"

static NSString * const StartStr = @"thunderHref=";
static NSString * const EndStr = @"</A>";
static NSInteger const PageCount = 200;

@implementation ProjectManager

HMSingletonM(ProjectManager)

#pragma mark - 网络爬虫
+ (void)getNetworkDataTest {
    NSString *urlStr = @"https://www.7027d62825fed025.com/play.x?stype=mlvideo&movieid=15067";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", str);
        if (str != nil) {
            NSRange range1 = [str rangeOfString:StartStr];
            NSRange range2 = [str rangeOfString:EndStr];
            if (range1.length > 0 && range2.length > 0 && range2.location - range1.location > 0) {
                NSRange range = NSMakeRange(range1.location, range2.location - range1.location + 10);
                NSString *resultStr = [str substringWithRange:range];
                NSLog(@"%@", resultStr);
            }
        }
    }];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@", str);
        if (str != nil) {
            NSRange range1 = [str rangeOfString:StartStr];
            NSRange range2 = [str rangeOfString:EndStr];
            if (range1.length > 0 && range2.length > 0 && range2.location - range1.location > 0) {
                NSRange range = NSMakeRange(range1.location, range2.location - range1.location);
                NSString *resultStr = [str substringWithRange:range];
                NSLog(@"%@", resultStr);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

// NSURLConnection
+ (void)getNetworkData1 {
    NSInteger startIndex = 4000;
    NSInteger endIndex = startIndex + PageCount;
    __block NSInteger counter = 0;

    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    for (NSInteger i = startIndex; i < endIndex; i++) {
        NSString *urlStr = [NSString stringWithFormat:@"http://www.38ppd.com/zpmp4.x?stype=zpmp4&zpmp4id=%ld", i];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (str.length != 0) {
                NSRange range1 = [str rangeOfString:StartStr];
                NSRange range2 = [str rangeOfString:EndStr];
                if (range1.length > 0 && range2.length > 0 && range2.location - range1.location > 0) {
                    NSRange range = NSMakeRange(range1.location, range2.location - range1.location + 10);
                    NSString *resultStr = [str substringWithRange:range];
                    [resultArray addObject:resultStr];
                    NSLog(@"下载进度: %ld / %ld", resultArray.count, PageCount);
                }
            }
            counter++;
            if (counter >= PageCount) {
                [self saveData:resultArray];
            }
        }];
    }
}

// AFHTTPSessionManager
+ (void)getNetworkData2 {
    NSInteger startIndex = 4000;
    NSInteger endIndex = startIndex + PageCount;
    __block NSInteger counter = 0;

    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (NSInteger i = startIndex; i < endIndex; i++) {
        startIndex++;
        NSString *urlStr = [NSString stringWithFormat:@"https://www.7027d62825fed025.com/play.x?stype=mlvideo&movieid=%ld", i];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            if (str.length != 0) {
                NSRange range1 = [str rangeOfString:StartStr];
                NSRange range2 = [str rangeOfString:EndStr];
                if (range1.length > 0 && range2.length > 0 && range2.location - range1.location > 0) {
                    NSRange range = NSMakeRange(range1.location, range2.location - range1.location);
                    NSString *resultStr = [str substringWithRange:range];
                    [resultArray addObject:resultStr];
                    NSLog(@"下载进度: %ld / %ld", resultArray.count, PageCount);
                }
            }
            counter++;
            if (counter >= PageCount) {
                [self saveData:resultArray];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
            counter++;
            if (counter >= PageCount) {
                [self saveData:resultArray];
            }
        }];
    }
}

#pragma mark - 公司自动打卡
// 公司上班登陆
+ (void)iskytripLogin {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *bodyStr = @"username=0060&password=xKu18V7RRnntrPV8fvHlQA==&token_jpush=appstore 141fe1da9e3c87113aa&type=odoo";
    
    NSURL *url = [NSURL URLWithString:@"https://iskytrip.peoplus.cn/api/ERoadIDs/Session"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@ : %@", dict, [NSThread currentThread]);
        NSString *token = dict[@"token"];
        [self iskytripDaka:token];
    }];
    
    [task resume];
}

// 公司上班打卡
+ (void)iskytripDaka:(NSString *)token {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSDictionary *dict = @{
        @"cur_latitude": @(31.22428772837452),
        @"cur_longitude": @(121.3604059906495),
        @"wifi_array": @[@"20:28:3e:18:33:b0"],
        @"beaconArray": @[],
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:0];
    NSString *bodyStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *urlStr = [NSString stringWithFormat:@"https://iskytrip.peoplus.cn/api/Attendances/clock?access_token=%@&action=", token];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@ : %@", dict, [NSThread currentThread]);
    }];
    
    [task resume];
}

#pragma mark - 私有方法
+ (void)saveData:(NSArray *)array {
    NSLog(@"网络数据爬取成功,总数: %ld", array.count);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"data.txt"];
    BOOL isSuccess = [array writeToFile:filePath atomically:YES];
    if (isSuccess) {
        NSLog(@"网络数据保存成功");
    } else {
        NSLog(@"网络数据保存失败");
    }
}


@end
