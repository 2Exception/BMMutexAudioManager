//
//  BMMutexAudioManager.h
//  BMMutexAudioManager
//
//  Created by 李志强 on 2017/5/4.
//  Copyright © 2017年 Li Zhiqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef  NS_ENUM(NSUInteger, EBMPlayerStatus) {
    EBMPlayerStatusStop = 0,
    EBMPlayerStatusPlay,
    EBMPlayerStatusPause,
    EBMPlayerStatusUnDownload,
    EBMPlayerStatusDownloading,
    EBMPlayerStatusDownloaded
};

@interface BMMutexAudioManager : NSObject

//可能需要一个block去返回cell的index和状态，用于更新按钮
- (BOOL)playAudioWithURL:(NSString *)URL cellIndexPath:(NSIndexPath *)indexPath;

//应该不需要这个，按钮的点击希望只调一个方法
//- (void)pauseAudioWithCellIndexPath:(NSIndexPath *)indexPath;

- (void)stopAudioWithCellIndexPath:(NSIndexPath *)indexPath;

/**
 * @brief 根据滑块所处的进度（或model中储存的进度）设置播放器播放进度
 * @param progress 滑块拖动事件发生后变化的进度
 */
- (void)setPlayerProgressByProgress:(float)progress cellIndexPath:(NSIndexPath *)indexPath;

//在需要的时候设计这个方法
- (float)duration;

@end
