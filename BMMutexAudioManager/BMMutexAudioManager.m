//
//  BMMutexAudioManager.m
//  BMMutexAudioManager
//
//  Created by 李志强 on 2017/5/4.
//  Copyright © 2017年 Li Zhiqiang. All rights reserved.
//

#import "BMMutexAudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface BMMutexAudioManager ()

@property (nonatomic, strong) NSMutableDictionary *cellStatusDictionary; //需要考虑到indexPath变了以后,直接重置dictionary！
@property (nonatomic, strong) NSIndexPath *currentPlayingIndexPath;
@property (nonatomic, strong) NSIndexPath *lastPlayingIndexPath;

@end

@implementation BMMutexAudioManager

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static BMMutexAudioManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - Public Method

- (BOOL)clickPlayButtonWithAudioURL:(NSString *)URLString cellIndexPath:(NSIndexPath *)indexPath {
    NSURL *fileURL = [NSURL URLWithString:URLString];
    BOOL isVaild = [fileURL checkResourceIsReachableAndReturnError:nil];
    if (isVaild && indexPath) {
        if (self.cellStatusDictionary[[self generateCellKeyStringWithIndexPath:indexPath]]) {
            //判断这个cell当前的状态，按情况改写，cell播放结束以后应该相应的更新键值对
        } else {//这个cell以前没播放过
            BMMutexAudioStatusModel *statusModel = [[BMMutexAudioStatusModel alloc] init];
            statusModel.audioURL = fileURL;
            statusModel.currentStatus = EBMPlayerStatusStop;
            statusModel.duration = [self durationWithVaildURL:fileURL];
            statusModel.currentProgress = 0;
            [self.cellStatusDictionary setObject:statusModel forKey:[self generateCellKeyStringWithIndexPath:indexPath]];
            self.currentPlayingIndexPath = indexPath;
            //暂停之前播放的，开始播放这个
            [self pauseOtherAudio];
            [self playAudioWithStatusModel:statusModel];
        }
    }
    return YES;
}

- (float)durationWithResourceName:(NSString *)resourceName extension:(NSString *)extension {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSURL *voiceURL = [[NSBundle bundleWithPath:bundlePath] URLForResource:resourceName withExtension:extension];
    return [self durationWithVaildURL:voiceURL];
}

- (BMMutexAudioStatusModel *)queryStatusModelWithIndexPath:(NSIndexPath *)indexPath {
    BMMutexAudioStatusModel *statusModel;
    return statusModel;
}

#pragma mark - Private Method

- (NSString *)generateCellKeyStringWithIndexPath:(NSIndexPath *)indexPath {
    NSString *keyString = @"keyString";
    if (indexPath) {
        keyString = [NSString stringWithFormat:@"%ld-%ld", indexPath.section, indexPath.row];
    }
    return keyString;
}

- (float)durationWithVaildURL:(NSURL *)vaildURL {
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:vaildURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}

- (void)playAudioWithStatusModel:(BMMutexAudioStatusModel *)statusModel {
    
}

- (void)pauseOtherAudio {
    
}

#pragma mark - Lazy Load

- (NSMutableDictionary *)cellStatusDictionary {
    if (nil == _cellStatusDictionary) {
        _cellStatusDictionary = [NSMutableDictionary dictionary];
    }
    return _cellStatusDictionary;
}
@end
