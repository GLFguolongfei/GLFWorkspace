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

static NSString * _Nullable DocumentPathArray = @"DocumentPathArray";
static NSString * _Nullable DocumentPathArrayUpdate = @"DocumentPathArrayUpdate";

typedef void (^FinishBlock) (NSArray *_Nullable);

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
// type 0-全部 1-文件夹 2-文件 3-图片 4-视频 5-抖音视频 6-其它视频
+ (void)eachAllFilesWithType:(NSInteger)eachType andFinish:(FinishBlock)callBlock;
- (void)eachAllFiles:(BOOL)isForce;
- (void)setVideosImage:(NSInteger)maxCount;
- (void)setScaleImage:(NSInteger)maxCount;
- (void)setModelVideosImage:(FileModel *)model;
- (void)setModelScaleImage:(FileModel *)model;
- (void)addFavoriteModel:(FileModel *)model;
- (void)removeFavoriteModel:(FileModel *)model;
- (void)addRemoveModel:(FileModel *)model;
- (void)removeRemoveModel:(FileModel *)model;
+ (void)updateDocumentPaths;

#pragma mark 历史记录
@property (nonatomic, assign) BOOL isUseBackFacingCamera; // 是否使用后置摄像头

- (void)startRecording;
- (void)stopRecording;
- (void)switchCamera;
- (BOOL)isRecording;

#pragma mark 背景音乐
- (void)startPlay;
- (void)stopPlay;

@end

NS_ASSUME_NONNULL_END
