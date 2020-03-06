//
//  DocumentManager.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/15.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DocumentManager : NSObject

HMSingletonH(DocumentManager)

@property (nonatomic, strong) NSMutableArray *allArray;         // 文件和文件夹
@property (nonatomic, strong) NSMutableArray *allFoldersArray;  // 文件夹
@property (nonatomic, strong) NSMutableArray *allFilesArray;    // 文件
@property (nonatomic, strong) NSMutableArray *allImagesArray;   // 图片
@property (nonatomic, strong) NSMutableArray *allVideosArray;   // 视频
@property (nonatomic, strong) NSMutableArray *allDYVideosArray; // 抖音视频

- (void)eachAllFiles:(BOOL)isForce;
- (void)setVideosImage:(NSInteger)maxCount;
- (void)addFavoriteModel:(FileModel *)model;
- (void)removeFavoriteModel:(FileModel *)model;
+ (void)updateDocumentPaths;

- (void)startPlay;
- (void)stopPlay;

@end

NS_ASSUME_NONNULL_END
