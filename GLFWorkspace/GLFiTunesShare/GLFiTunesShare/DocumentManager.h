//
//  DocumentManager.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/15.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FileModel.h"

static NSString *DocumentPathArray = @"DocumentPathArray";
static NSString *DocumentPathArrayUpdate = @"DocumentPathArrayUpdate";

NS_ASSUME_NONNULL_BEGIN

@interface DocumentManager : NSObject

HMSingletonH(DocumentManager)

@property (nonatomic, strong) NSMutableArray *allArray;         // 文件和文件夹
@property (nonatomic, strong) NSMutableArray *allFoldersArray;  // 文件夹
@property (nonatomic, strong) NSMutableArray *allFilesArray;    // 文件
@property (nonatomic, strong) NSMutableArray *allImagesArray;   // 图片
@property (nonatomic, strong) NSMutableArray *allVideosArray;   // 视频
@property (nonatomic, strong) NSMutableArray *allDYVideosArray; // 抖音视频
@property (nonatomic, strong) NSMutableArray *allNoDYVideosArray; // 其它视频(非抖音视频)

#pragma mark 文件操作
- (void)eachAllFiles:(BOOL)isForce;
- (void)setModelVideosImage:(FileModel *)model;
- (void)setModelScaleImage:(FileModel *)model;
- (void)addFavoriteModel:(FileModel *)model;
- (void)removeFavoriteModel:(FileModel *)model;
- (void)addRemoveModel:(FileModel *)model;
- (void)removeRemoveModel:(FileModel *)model;
+ (void)updateDocumentPaths;

#pragma mark 历史记录
- (void)startRecording;
- (void)stopRecording;
- (void)switchCamera;
- (BOOL)isRecording;

#pragma mark 背景音乐
- (void)startPlay;
- (void)stopPlay;

@end

NS_ASSUME_NONNULL_END
