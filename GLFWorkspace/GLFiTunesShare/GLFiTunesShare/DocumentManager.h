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

#pragma mark 文件操作
+ (void)eachAllFiles;
+ (void)updateDocumentPaths;
- (void)addFavoriteModel:(FileModel *)model;
- (void)removeFavoriteModel:(FileModel *)model;
- (void)addRemoveModel:(FileModel *)model;
- (void)removeRemoveModel:(FileModel *)model;

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
