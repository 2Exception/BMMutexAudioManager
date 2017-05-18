//
//  BMMutexAudioManager.h
//  BMMutexAudioManager
//
//  Created by 李志强 on 2017/5/4.
//  Copyright © 2017年 Li Zhiqiang. All rights reserved.
//

//如果一直出现log，需要edit-scheme ，设置OS_ACTIVITY_MODE 为disable  http://www.cnblogs.com/jingxin1992/p/6290641.html

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BMMutexAudioStatusModel;

typedef NS_ENUM(NSUInteger, EBMPlayerStatus) {
    EBMPlayerStatusStop = 919,
    EBMPlayerStatusPlaying,
    EBMPlayerStatusPause,
    EBMPlayerStatusUnDownload,
    EBMPlayerStatusDownloading,
    EBMPlayerStatusRetryDownload
};

@protocol BMMutexAudioManagerDelegate <NSObject>
@optional

//发生变化的时候被调用，用于更新UI
- (void)mutexAudioManagerDidChanged:(NSIndexPath *)changedIndexPath statusModel:(BMMutexAudioStatusModel *)statusModel;

//用来更新正在播放的cell的进度条
- (void)mutexAudioManagerPlayingCell:(NSIndexPath *)playingCellIndexPath progress:(CGFloat)progress;

//一个cell播放完毕，进入停止状态
- (void)mutexAudioManagerDidFinishPlaying:(NSIndexPath *)finishedCellIndexPath;

@end

@interface BMMutexAudioManager : NSObject

@property (nonatomic, weak) id<BMMutexAudioManagerDelegate> delegate;

//Singleton
+ (instancetype)sharedInstance;

/**
 * @brief 点击播放按钮时调用（必须调用）
 * @param URL 音频文件的URL地址
 * @param indexPath 播放按钮所在的indexPath
 */
- (void)clickPlayButtonWithAudioURL:(NSString *)URL cellIndexPath:(NSIndexPath *)indexPath;

/**
 * @brief 点击停止按钮时调用（按需调用）
 * @param indexPath 播放按钮所在的indexPath
 */
- (void)clickStopButtonWithCellIndexPath:(NSIndexPath *)indexPath;

/**
 * @brief 根据滑块所处的进度（或model中储存的进度）设置播放器播放进度
 * @param progress 滑块拖动事件发生后变化的进度
 * @param indexPath 滑块所在的indexPath
 */
- (void)setPlayerProgressByProgress:(float)progress cellIndexPath:(NSIndexPath *)indexPath;

/**
 * @brief 根据indexPath查询对应cell的状态
 * @param indexPath cell的indexPath
 * @return BMMutexAudioStatusModel 状态model
 */
- (BMMutexAudioStatusModel *)queryStatusModelWithIndexPath:(NSIndexPath *)indexPath audioURL:(NSString *)audioURL;

/**
 * @brief 删除缓存的音频
 */
- (void)deleteAllDownloadedVoice;


@end

@interface BMMutexAudioStatusModel : NSObject

@property (nonatomic, assign) EBMPlayerStatus currentStatus;
@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, strong) NSURL *localPathURL;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat currentProgress; // 0 <= currentProgress <= 1, it's a percentage

@end
