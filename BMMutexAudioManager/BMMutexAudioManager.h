//
//  BMMutexAudioManager.h
//  BMMutexAudioManager
//
//  Created by 李志强 on 2017/5/4.
//  Copyright © 2017年 Li Zhiqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BMMutexAudioStatusModel;

typedef NS_ENUM(NSUInteger, EBMPlayerStatus) {
    EBMPlayerStatusStop = 0,
    EBMPlayerStatusPlaying,
    EBMPlayerStatusPause,
    EBMPlayerStatusUnDownload,
    EBMPlayerStatusDownloading,
    EBMPlayerStatusDownloaded
};

@protocol BMMutexAudioManagerDelegate <NSObject>
@optional
//音频改变的时候用来更新
- (void)mutexAudioManagerDidChangeToCurrentPlayingCell:(NSIndexPath *)currentIndexPath
                         currentPlayingCellStatusModel:(BMMutexAudioStatusModel *)currentStatusModel
                                   previousPlayingCell:(NSIndexPath *)previousIndexPath
                        previousPlayingCellStatusModel:(BMMutexAudioStatusModel *)previousStatusModel;

//用来更新正在播放的cell的进度条
- (void)mutexAudioManagerPlayingCell:(NSIndexPath *)playingCellIndexPath progress:(CGFloat)progress;

//一个cell播放完毕，没有启动另一个播放
- (void)mutexAudioManagerDidFinishPlaying:(NSIndexPath *)finishedCellIndexPath;

@end

@interface BMMutexAudioManager : NSObject

@property (nonatomic, weak) id<BMMutexAudioManagerDelegate> delegate;

+ (instancetype)sharedInstance;

//可能需要一个block去返回cell的index和状态，用于更新按钮
- (BOOL)clickPlayButtonWithAudioURL:(NSString *)URL cellIndexPath:(NSIndexPath *)indexPath;

- (void)clickStopButtonWithCellIndexPath:(NSIndexPath *)indexPath;

/**
 * @brief 根据滑块所处的进度（或model中储存的进度）设置播放器播放进度
 * @param progress 滑块拖动事件发生后变化的进度
 */
- (void)setPlayerProgressByProgress:(float)progress cellIndexPath:(NSIndexPath *)indexPath;

/**
 * @brief 根据indexPath查询对应cell的状态
 * @param indexPath cell的indexPath
 * @return BMMutexAudioStatusModel 状态model
 */
- (BMMutexAudioStatusModel *)queryStatusModelWithIndexPath:(NSIndexPath *)indexPath;

//在需要的时候设计这个方法
- (float)durationWithResourceName:(NSString *)resourceName extension:(NSString *)extension;

@end

@interface BMMutexAudioStatusModel : NSObject

@property (nonatomic, assign) EBMPlayerStatus currentStatus;
@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat currentProgress; // 0 <= currentProgress <= 1, it's a percentage

@end
