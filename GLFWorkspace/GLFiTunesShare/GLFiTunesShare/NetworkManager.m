//
//  NetworkManager.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/6/14.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

HMSingletonM(NetworkManager)


#pragma mark - 网络爬虫
+ (void)getNetworkData1 {
    __block NSInteger startIndex = 4000;
    NSInteger endIndex = startIndex + 200;

    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    for (NSInteger i = startIndex; i < endIndex; i++) {
        NSString *urlStr = [NSString stringWithFormat:@"http://www.38ppd.com/zpmp4.x?stype=zpmp4&zpmp4id=%ld", i];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            startIndex++;
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (str.length != 0) {
                NSRange range1 = [str rangeOfString:@"<source src="];
                NSRange range2 = [str rangeOfString:@"type=\"video/mp4\""];
                if (range1.length > 0 && range2.length > 0 && range2.location - range1.location > 0) {
                    NSRange range = NSMakeRange(range1.location, range2.location - range1.location + 10);
                    NSString *resultStr = [str substringWithRange:range];
                    [resultArray addObject:resultStr];
                    NSLog(@"endIndex: %ld, startIndex: %ld, resultArray.count: %ld", endIndex, startIndex, resultArray.count);
                    if (startIndex >= endIndex - 1 || (startIndex >= endIndex - 100 && startIndex % 50 == 0)) {
                        [self getNetworkDataSave:resultArray];
                    }
                }
            }
        }];
    }
}

+ (void)getNetworkData2 {
    __block NSInteger startIndex = 10000;
    NSInteger endIndex = startIndex + 200;

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
                NSRange range1 = [str rangeOfString:@"thunderHref="];
                NSRange range2 = [str rangeOfString:@"</A>"];
                if (range1.length > 0 && range2.length > 0 && range2.location - range1.location > 0) {
                    NSRange range = NSMakeRange(range1.location, range2.location - range1.location);
                    NSString *resultStr = [str substringWithRange:range];
                    [resultArray addObject:resultStr];
                    NSLog(@"endIndex: %ld, startIndex: %ld, resultArray.count: %ld", endIndex, startIndex, resultArray.count);
                    if (startIndex >= endIndex - 1 || (startIndex >= endIndex - 100 && startIndex % 50 == 0)) {
                        [self getNetworkDataSave:resultArray];
                    }
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
        }];
    }
}

+ (void)getNetworkDataTest {
    NSString *urlStr = @"https://www.7027d62825fed025.com/play.x?stype=mlvideo&movieid=15067";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", str);
        if (str != nil) {
            NSRange range1 = [str rangeOfString:@"<source src="];
            NSRange range2 = [str rangeOfString:@"type=\"video/mp4\""];
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
            NSRange range1 = [str rangeOfString:@"thunderHref="];
            NSRange range2 = [str rangeOfString:@"</A>"];
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

+ (void)getNetworkDataSave:(NSArray *)array {
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


@end
