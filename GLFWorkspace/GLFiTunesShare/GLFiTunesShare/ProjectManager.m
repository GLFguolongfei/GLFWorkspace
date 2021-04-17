//
//  ProjectManager.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/6/20.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "ProjectManager.h"

@interface ProjectManager()
{
    NSMutableArray *resultArray;        // 爬取结果
    NSMutableArray *errorUrlArray;      // 爬取失败-URL数组
    NSInteger startIndex;
    NSInteger endIndex;
    BOOL isReSend;
}
@end

@implementation ProjectManager

HMSingletonM(ProjectManager)

#pragma mark - 网络爬虫
- (void)getNetworkDataTest:(NSString *)urlString {
    if (urlString.length == 0) {
        NSLog(@"||| 请输入URL |||");
        return;
    }
    NSLog(@"||| getNetworkDataTest |||");
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; // 中文必须转换
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *resultStr1 = [self returnResultStr:str andType:1];
        NSString *resultStr2 = [self returnResultStr:str andType:2];
        if (isReSend) {
            if (resultStr1.length > 0) {
                [resultArray addObject:resultStr1];
                [errorUrlArray removeObject:urlString];
                NSLog(@"~~~~~~ 补救成功,还余留: %ld", errorUrlArray.count);
            } else if (resultStr2.length > 0) {
                [resultArray addObject:resultStr2];
                [errorUrlArray removeObject:urlString];
                NSLog(@"~~~~~~ 补救成功,还余留: %ld", errorUrlArray.count);
            }
        } else {
            NSLog(@"resultStr~~~10: %@", str);
            NSLog(@"resultStr~~~11: %@", resultStr1);
            NSLog(@"resultStr~~~12: %@", resultStr2);
        }
    }];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *resultStr1 = [self returnResultStr:str andType:1];
        NSString *resultStr2 = [self returnResultStr:str andType:2];
        if (isReSend) {
            if (resultStr1.length > 0) {
                [resultArray addObject:resultStr1];
                [errorUrlArray removeObject:urlString];
                NSLog(@"~~~~~~ 补救成功,还余留: %ld", errorUrlArray.count);
            } else if (resultStr2.length > 0) {
                [resultArray addObject:resultStr2];
                [errorUrlArray removeObject:urlString];
                NSLog(@"~~~~~~ 补救成功,还余留: %ld", errorUrlArray.count);
            }
        } else {
            NSLog(@"resultStr~~~20: %@", str);
            NSLog(@"resultStr~~~21: %@", resultStr1);
            NSLog(@"resultStr~~~22: %@", resultStr2);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)getNetworkData:(NSInteger)type {
    if (!resultArray) {
        resultArray = [[NSMutableArray alloc] init];
        errorUrlArray = [[NSMutableArray alloc] init];
        startIndex = 1;
        endIndex = 206;
        isReSend = NO;
    }
    if (type == 1) {
        [self getNetworkData1:^{
            [self getNetworkData:type];
        }];
    } else {
        [self getNetworkData2:^{
            [self getNetworkData:type];
        }];
    }
}

- (void)getNetworkDataRepeat {
    NSLog(@"需要补救的URL数目: %ld", errorUrlArray.count);
    isReSend = YES;
    NSInteger counter = 0;
    for (NSString *urlString in errorUrlArray) {
        [self getNetworkDataTest:urlString];
        counter++;
        if (counter > 5) {
            sleep(2);
        }
    }
}

// NSURLConnection(视频)
- (void)getNetworkData1:(LoadFinishCallBack)callBack {
    __block NSInteger counter = 0;
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    for (NSInteger i = startIndex; i < startIndex + 5; i++) {
        if (i >= endIndex) {
            [self saveData:resultArray andFileName:@"netData"];
            return;
        }
        NSString *urlStr = [NSString stringWithFormat:@"https://www.bpw4.com/shipin/%ld.html", i];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            counter++;
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *resultStr = [self returnResultStr:str andType:1];
            if (resultStr.length > 0) {
                [resultArray addObject:resultStr];
                NSLog(@"爬取成功: %ld / %ld / %ld", resultArray.count, startIndex, endIndex);
            } else {
                [errorUrlArray addObject:urlStr];
                NSLog(@"~~~~~~ 爬取失败: %ld / %ld / %ld", resultArray.count, startIndex, endIndex);
            }
            if (counter >= 4) {
                callBack();
            }
        }];
    }
}

// AFHTTPSessionManager(视频)
- (void)getNetworkData2:(LoadFinishCallBack)callBack {
    __block NSInteger counter = 0;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    for (NSInteger i = startIndex; i < startIndex + 5; i++) {
        if (i >= endIndex) {
            [self saveData:resultArray andFileName:@"netData"];
            return;
        }
        NSString *urlStr = [NSString stringWithFormat:@"https://www.jrz2ch.de/play.x?stype=mlvideo&movieid=%ld", i];
        [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            counter++;
            NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSString *resultStr = [self returnResultStr:str andType:1];
            if (resultStr.length > 0) {
                [resultArray addObject:resultStr];
                NSLog(@"爬取成功: %ld / %ld / %ld", resultArray.count, startIndex, endIndex);
            } else {
                [errorUrlArray addObject:urlStr];
                NSLog(@"~~~~~~ 爬取失败:  %ld / %ld / %ld", resultArray.count, startIndex, endIndex);
            }
            if (counter >= 4) {
                callBack();
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            counter++;
            NSLog(@"~~~~~~ 爬取失败:  %ld / %ld / %ld", resultArray.count, startIndex, endIndex);
            if (counter >= 4) {
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

#pragma mark - 私有方法
- (void)saveData:(NSArray *)array andFileName:(NSString *)fileName {
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

- (NSArray *)pattern:(NSString *)patternStr andStr:(NSString *)str {
    // 使用正则表达式的步骤
    // 1-创建一个正则表达式对象
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:patternStr options:0 error:nil];
    // 2-利用正则表达式对象来测试相应的字符串
    NSArray *results = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    return results;
}

- (NSString *)returnResultStr:(NSString *)str andType:(NSInteger)type {
    if (str.length == 0) {
        return @"";
    }
    NSString *resultStr = @"";
    if (type == 1) {
        NSRange range1 = [str rangeOfString:@"http:"];
        if (range1.length == 0) {
            range1 = [str rangeOfString:@"https:"];
        }
        if (range1.length > 0) {
            NSString *subStr = [str substringFromIndex:range1.location];
            NSRange range2 = [subStr rangeOfString:@".mp4"];
            if (range2.length > 0) {
                NSInteger endIndex = range2.location + range2.length;
                resultStr = [subStr substringToIndex:endIndex];
            }
        } else {
            NSLog(@"%ld", range1.length);
        }
    } else {
        NSString *patternStr = @"^http.*.mp4$";
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
