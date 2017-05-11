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

- (void)removeVoice;
- (void)asynchronousVoiceDownload:(NSDictionary *)voiceDict;
- (NSString *)voiceLocalSavePathAtVoiceName:(NSString *)voiceName;
- (NSString *)voiceFolder;

@end
