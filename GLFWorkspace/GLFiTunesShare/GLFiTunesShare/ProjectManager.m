//
//  ProjectManager.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/6/20.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "ProjectManager.h"

@implementation ProjectManager

HMSingletonM(ProjectManager)

#pragma mark - 网络爬虫
+ (void)getNetworkDataTest {
    NSString *oldUrlStr = @"https://www.jrz2ch.de/play.x?stype=mlvideo&movieid=20458";
    NSString *urlStr = [oldUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; // 中文必须转换
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", str);
        NSString *resultStr1 = [self returnResultStr:str andType:1];
        NSString *resultStr2 = [self returnResultStr:str andType:2];
        NSLog(@"resultStr~~~1: %@", resultStr1);
        NSLog(@"resultStr~~~2: %@", resultStr2);
    }];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@", str);
        NSString *resultStr1 = [self returnResultStr:str andType:1];
        NSString *resultStr2 = [self returnResultStr:str andType:2];
        NSLog(@"resultStr~~~~~~1: %@", resultStr1);
        NSLog(@"resultStr~~~~~~2: %@", resultStr2);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

// AFHTTPSessionManager(视频)
+ (void)getNetworkData:(NSInteger)index andType:(NSInteger)type {
    NSInteger pageCount = 100;
    if (type == 1) {
        [self getNetworkData1:index andPageCount:pageCount andFinish:^{
            NSInteger nextIndex = index + pageCount;
            [self getNetworkData:nextIndex andType:type];
        }];
    } else {
        [self getNetworkData2:index andPageCount:pageCount andFinish:^{
            NSInteger nextIndex = index + pageCount;
            [self getNetworkData:nextIndex andType:type];
        }];
    }
}

// NSURLConnection(视频)
+ (void)getNetworkData1:(NSInteger)start andPageCount:(NSInteger)pageCount andFinish:(LoadFinishCallBack)callBack {
    __block NSInteger counter = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    for (NSInteger i = 0; i < pageCount; i++) {
        if (start + i > [ProjectManager sharedProjectManager].endIndex) {
            [[ProjectManager sharedProjectManager].resultArray addObjectsFromArray:array];
            [self saveData:[ProjectManager sharedProjectManager].resultArray andFileName:@"netData"];
            NSLog(@"~~~~~~~~~ ~~~~~~~~~ 爬取结束,共有数据 %ld 条", [ProjectManager sharedProjectManager].resultArray.count);
            return;
        }
        NSString *urlStr = [NSString stringWithFormat:@"https://www.bpw4.com/shipin/%ld.html", i];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *resultStr = [self returnResultStr:str andType:1];
            [array addObject:resultStr];
            
            if (resultStr.length > 0) {
                NSLog(@"爬取成功: %ld", start + counter);
            } else {
                NSLog(@"爬取失败: %ld", start + counter);
            }
            counter++;
            if (counter >= pageCount) {
                callBack();
            }
        }];
    }
}

// AFHTTPSessionManager(视频)
+ (void)getNetworkData2:(NSInteger)start andPageCount:(NSInteger)pageCount andFinish:(LoadFinishCallBack)callBack {
    __block NSInteger counter = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; i++) {
        if (start + i > [ProjectManager sharedProjectManager].endIndex) {
            [[ProjectManager sharedProjectManager].resultArray addObjectsFromArray:array];
            [self saveData:[ProjectManager sharedProjectManager].resultArray andFileName:@"netData"];
            NSLog(@"~~~~~~~~~ ~~~~~~~~~ 爬取结束,共有数据 %ld 条", [ProjectManager sharedProjectManager].resultArray.count);
            return;
        }
        NSString *urlStr = [NSString stringWithFormat:@"https://www.jrz2ch.de/play.x?stype=mlvideo&movieid=%ld", start + i];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSString *resultStr = [self returnResultStr:str andType:1];
            [array addObject:resultStr];
            
            if (resultStr.length > 0) {
                NSLog(@"爬取成功: %ld", start + counter);
            } else {
                NSLog(@"爬取失败: %ld", start + counter);
            }
            counter++;
            if (counter >= pageCount) {
                callBack();
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"爬取失败: %ld", start + counter);
            counter++;
            if (counter >= pageCount) {
                callBack();
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
    [self saveData:resultArray andFileName:@"data"];
}

#pragma mark - 私有方法
+ (void)saveData:(NSArray *)array andFileName:(NSString *)fileName {
    NSLog(@"网络数据爬取成功,总数: %ld", array.count);
    if (array.count == 0) {
        return;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *namePath = [NSString stringWithFormat:@"%@.txt", fileName];
    NSString *filePath = [path stringByAppendingPathComponent:namePath];
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
    return results;
}

+ (NSString *)returnResultStr:(NSString *)str andType:(NSInteger)type {
    if (str.length == 0) {
        return @"";
    }
    NSString *resultStr = @"";
    if (type == 1) {
        NSRange range1 = [str rangeOfString:@"http:"];
        NSRange range2 = [str rangeOfString:@".mp4"];
        if (range1.length > 0 && range2.length > 0 && range2.location - range1.location > 0) {
            NSRange range = NSMakeRange(range1.location, range2.location + range2.length - range1.location);
            resultStr = [str substringWithRange:range];
        }
    } else {
        NSString *patternStr = @"html_data.*?html"; // @"src=\"http.*?jpg"
        NSArray *results = [self pattern:patternStr andStr:str];
        if (results.count > 0) {
            // 只取第一个
            NSTextCheckingResult *result = results[0];
            resultStr = [str substringWithRange:result.range];
        }
    }
    return resultStr;
}


@end
