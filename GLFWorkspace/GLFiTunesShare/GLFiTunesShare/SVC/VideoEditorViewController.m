//
//  VideoEditorViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/8/28.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "VideoEditorViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoEditorViewController ()

@property (nonatomic, assign) NSArray *array;
@property (nonatomic, assign) NSString *outPath;
@property (nonatomic, assign) NSString *type;

@end

@implementation VideoEditorViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    // self.array 里面放的是两个视频的地址  ，类型为NSurl
    // path 是你合并后的存放的地址路径
    NSString *path = @"";
    [self mergeAndExportVideos:self.array withOutPath:path];
}

- (void)mergeAndExportVideos:(NSMutableArray*)videosPathArray withOutPath:(NSString*)outpath {
      AVMutableComposition *mixComposition  = [[AVMutableComposition alloc] init];
    // 音频轨道
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    // 视频轨道
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
preferredTrackID:kCMPersistentTrackID_Invalid];

    CMTime totalDuration = kCMTimeZero;
    for(int i =0; i < videosPathArray.count; i++) {
        //AVURLAsset：AVAsset的子类，此类主要用于获取多媒体的信息，包括视频、音频的类型、时长、每秒帧数，其实还可以用来获取视频的指定位置的缩略图。
        AVURLAsset *asset = [AVURLAsset assetWithURL:videosPathArray[i]];
        NSError *erroraudio =nil;
        //获取AVAsset中的音频
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio]firstObject];
        //向通道内加入音频
        BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
ofTrack:assetAudioTrack atTime:totalDuration error:&erroraudio];
        NSLog(@"erroraudio:%@%d",erroraudio,ba);
        NSError*errorVideo =nil;
        //获取AVAsset中的视频
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
        //向通道内加入视频
        BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
ofTrack:assetVideoTrack atTime:totalDuration error:&errorVideo];
        NSLog(@"errorVideo:%@%d",errorVideo,bl);
        totalDuration =CMTimeAdd(totalDuration, asset.duration);
    }
    //创建合成后写入的路劲
    NSURL *mergeFileURL = [NSURL fileURLWithPath:outpath];
    if([[NSFileManager defaultManager] fileExistsAtPath:outpath]) {
        NSLog(@"有文件");
        return;
    }
    //这里开始导出合成后的视频
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset640x480];
    exporter.outputURL= mergeFileURL;
    NSLog(@"%@",exporter.supportedFileTypes);
    if([self.type isEqualToString:@"mp4"]) {
        exporter.outputFileType=AVFileTypeMPEG4;
    }else{
        exporter.outputFileType=AVFileTypeQuickTimeMovie;
    }
    exporter.shouldOptimizeForNetworkUse=YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        //导出的状态
        switch(exporter.status) {
            caseAVAssetExportSessionStatusUnknown:
                NSLog(@"exporter Unknow");
                break;
            caseAVAssetExportSessionStatusCancelled:
                NSLog(@"exporter Canceled");
                break;
            caseAVAssetExportSessionStatusFailed:
                //导出失败
                NSLog(@"exporter Failed");
                break;
            caseAVAssetExportSessionStatusWaiting:
                NSLog(@"exporter Waiting");
                break;
            caseAVAssetExportSessionStatusExporting:
                NSLog(@"exporter Exporting");
                break;
            caseAVAssetExportSessionStatusCompleted:
                //导出成功
                NSLog(@"exporter Completed");
                dispatch_async(dispatch_get_main_queue(), ^{
                    //这里是回到你的主线程做一些事情
                });
                break;
        }
    }];
}

- (void)clearCache {
    if([[NSFileManager defaultManager] fileExistsAtPath:self.outPath]) {
        //这里是你可以删除你合成后的视频文件
        //self.outPath 是你保存视频的路劲，当然你也可以通过该路劲删除它
        NSLog(@"删除成功");
        [[NSFileManager defaultManager] removeItemAtPath:self.outPath error:nil];
    }
}


@end
