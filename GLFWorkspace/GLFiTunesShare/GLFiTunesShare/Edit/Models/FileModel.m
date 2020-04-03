//
//  FileModel.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/11/3.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "FileModel.h"

#define NAME @"name"
#define PATH @"path"
#define ATTRIBUTES @"attributes"
#define TYPE @"type"
#define SIZE @"size"
#define VIDEOSIZE @"videoSize" // 没有
#define COUNT @"count"

@implementation FileModel

#pragma mark - NSCoding(只有这两个)
// -----编码方法(哪些属性需要归档,不一定全部)------
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:NAME];
    [aCoder encodeObject:self.path forKey:PATH];
    [aCoder encodeObject:self.attributes forKey:ATTRIBUTES];
    
    NSString *type = [NSString stringWithFormat:@"%ld", self.type];
    NSString *size = [NSString stringWithFormat:@"%f", self.size];
    NSString *videoSize = NSStringFromCGSize(self.videoSize);
    NSString *count = [NSString stringWithFormat:@"%ld", self.count];

    [aCoder encodeObject:type forKey:TYPE];
    [aCoder encodeObject:size forKey:SIZE];
    [aCoder encodeObject:videoSize forKey:VIDEOSIZE];
    [aCoder encodeObject:count forKey:COUNT];
}

// -----解码方法(哪些属性需要解档,不一定全部)-------
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:NAME];
        self.path = [aDecoder decodeObjectForKey:PATH];
        self.attributes = [aDecoder decodeObjectForKey:ATTRIBUTES];
        
        NSString *type = [aDecoder decodeObjectForKey:TYPE];
        NSString *size = [aDecoder decodeObjectForKey:SIZE];
        NSString *videoSize = [aDecoder decodeObjectForKey:VIDEOSIZE];
        NSString *count = [aDecoder decodeObjectForKey:COUNT];
        
        self.type = [type integerValue];
        self.size = [size floatValue];
        self.videoSize = CGSizeFromString(videoSize);
        self.count = [count integerValue];
    }
    return self;
}

@end
