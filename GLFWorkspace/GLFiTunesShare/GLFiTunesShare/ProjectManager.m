//
//  ProjectManager.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/6/20.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "ProjectManager.h"

static NSString * const UrlStr = @"https://www.bpr8.com/shipin/397.html";
static NSString * const PatternStr = @"^http[a-zA-Z0-9]jpg$";
static NSString * const StartStr = @"http://";
static NSString * const EndStr = @".mp4";
static NSInteger const PageCount = 500;

@implementation ProjectManager

HMSingletonM(ProjectManager)

#pragma mark - 网络爬虫
+ (void)getNetworkDataTest {
    NSString *urlStr = [UrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; // 中文必须转换
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", str);
        
        [self pattern:PatternStr andStr:str];
        
        if (str != nil) {
            NSRange range1 = [str rangeOfString:StartStr];
            NSRange range2 = [str rangeOfString:EndStr];
            if (range1.length > 0 && range2.length > 0 && range2.location - range1.location > 0) {
                NSRange range = NSMakeRange(range1.location, range2.location + range2.length - range1.location);
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
                NSRange range = NSMakeRange(range1.location, range2.location + range2.length - range1.location);
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
                    NSRange range = NSMakeRange(range1.location, range2.location + range2.length - range1.location);
                    NSString *resultStr = [str substringWithRange:range];
                    [resultArray addObject:resultStr];
                }
            }
            counter++;
            NSLog(@"爬取进度: %ld / %ld", counter, PageCount);
            if (counter >= PageCount) {
                [self saveData:resultArray];
            }
        }];
    }
}

// AFHTTPSessionManager
+ (void)getNetworkData2 {
    NSInteger startIndex = 13000;
    NSInteger endIndex = startIndex + PageCount;
    __block NSInteger counter = 0;

    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (NSInteger i = startIndex; i < endIndex; i++) {
        startIndex++;
        NSString *urlStr = [NSString stringWithFormat:@"https://www.p4s3.com/play.x?stype=mlvideo&movieid=%ld", i];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            if (str.length != 0) {
                NSRange range1 = [str rangeOfString:StartStr];
                NSRange range2 = [str rangeOfString:EndStr];
                if (range1.length > 0 && range2.length > 0 && range2.location - range1.location > 0) {
                    NSRange range = NSMakeRange(range1.location, range2.location + range2.length - range1.location);
                    NSString *resultStr = [str substringWithRange:range];
                    [resultArray addObject:resultStr];
                }
            }
            counter++;
            NSLog(@"爬取进度(成功): %ld / %ld", counter, PageCount);
            if (counter >= PageCount) {
                [self saveData:resultArray];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            counter++;
            NSLog(@"爬取进度(失败): %ld / %ld", counter, PageCount);
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

#pragma mark 其它
+ (void)calcData {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:@"data.txt"];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    for (NSInteger i = 0; i < array.count; i++) {
        NSString *str = array[i];
        NSRange range1 = [str rangeOfString:@"http://"];
        NSRange range2 = [str rangeOfString:@".mp4"];
        if (range1.length > 0 && range2.length > 0 && range2.location - range1.location > 0) {
            NSRange range = NSMakeRange(range1.location, range2.location + range2.length - range1.location);
            NSString *resultStr = [str substringWithRange:range];
//            NSLog(@"%@", resultStr);
            [resultArray addObject:resultStr];
        }
    }
    [self saveData:resultArray];
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

+ (NSArray *)pattern:(NSString *)patternStr andStr:(NSString *)str {
    // 使用正则表达式的步骤
    // 1-创建一个正则表达式对象
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:patternStr options:0 error:nil];
    // 2-利用正则表达式对象来测试相应的字符串
    NSArray *results = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    for (int i = 0; i < results.count; i++) {
        NSTextCheckingResult *result = results[i];
        NSLog(@"正则表达式查询结果: %@ %@", NSStringFromRange(result.range), [str substringWithRange:result.range]);
    }
    return results;
}


@end
