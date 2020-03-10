//
//  DocumentManager.h
//  UIWebView
//
//  Created by guolongfei on 2020/3/10.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DocumentManager : NSObject

HMSingletonH(DocumentManager)

- (void)addURL:(NSDictionary *)urlDict;
- (void)deleteURL:(NSString *)urlStr;
- (void)clearURL;
- (void)renameURL:(NSDictionary *)urlDict;

@end

NS_ASSUME_NONNULL_END
