//
//  BMAduioDownloadManager.h
//  BMMutexAudioManager
//
//  Created by 李志强 on 2017/5/11.
//  Copyright © 2017年 Li Zhiqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMAduioDownloadManager : NSObject

typedef NS_ENUM(NSUInteger, EBMAudioDownloadStatus) {
    EBMAudioDownloadStatusUnloaded = 737,
    EBMAudioDownloadStatusDownloading,
    EBMAudioDownloadStatusSuccess,
    EBMAudioDownloadStatusNetworkFail,
    EBMAudioDownloadStatusNoData,
    EBMAudioDownloadStatusSaveFail
};

+ (instancetype)sharedInstance;

@property (copy, nonatomic) void (^voiceDownloadSuccessBlock)
(NSString *voiceName, EBMAudioDownloadStatus voiceDownloadStatus, NSString *voicePath);

/**
 * @brief 移除缓存的音频文件
 */
- (void)removeVoice;

/**
 * @brief 异步下载音频文件
 * @param voiceDict 字典文件，包含key：:@"voiceUrl"、@"voiceName"，分别对应音频的URL和想要保存的文件名
 */
- (void)asynchronousVoiceDownload:(NSDictionary *)voiceDict;

/**
 * @brief 获取音频文件的本地地址
 * @param voiceName 音频的文件名
 * @return 本地地址
 */
- (NSString *)voiceLocalSavePathAtVoiceName:(NSString *)voiceName;

/**
 * @brief 获取音频保存的文件夹地址
 * @return 文件夹地址
 */
- (NSString *)voiceFolder;

@end
