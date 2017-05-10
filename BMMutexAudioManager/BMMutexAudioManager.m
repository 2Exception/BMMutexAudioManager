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

@interface BMMutexAudioManager () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *privatePlayer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableDictionary *cellStatusDictionary; //需要考虑到indexPath变了以后,直接重置dictionary！
@property (nonatomic, strong) NSIndexPath *currentPlayingIndexPath;
@property (nonatomic, strong) BMMutexAudioStatusModel *currentPlayingModel;
@property (nonatomic, strong) NSIndexPath *previousPlayingIndexPath;

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
            BMMutexAudioStatusModel *statusModel = self.cellStatusDictionary[[self generateCellKeyStringWithIndexPath:indexPath]];
            [self playAudioWithStatusModel:statusModel indexPath:indexPath];
        } else { //这个cell以前没播放过
            BMMutexAudioStatusModel *statusModel = [[BMMutexAudioStatusModel alloc] init];
            statusModel.audioURL = fileURL;
            statusModel.currentStatus = EBMPlayerStatusStop;
            statusModel.duration = [self durationWithVaildURL:fileURL];
            statusModel.currentProgress = 0;
            [self.cellStatusDictionary setObject:statusModel forKey:[self generateCellKeyStringWithIndexPath:indexPath]];
            //暂停之前播放的，开始播放这个
            [self playAudioWithStatusModel:statusModel indexPath:indexPath];
        }
    }
    return YES;
}

- (void)clickStopButtonWithCellIndexPath:(NSIndexPath *)indexPath {
    [self pauseOrStopAudioInIndexPath:indexPath status:EBMPlayerStatusStop];
}

- (float)durationWithResourceName:(NSString *)resourceName extension:(NSString *)extension {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSURL *voiceURL = [[NSBundle bundleWithPath:bundlePath] URLForResource:resourceName withExtension:extension];
    return [self durationWithVaildURL:voiceURL];
}

- (BMMutexAudioStatusModel *)queryStatusModelWithIndexPath:(NSIndexPath *)indexPath {
    BMMutexAudioStatusModel *statusModel = [self.cellStatusDictionary objectForKey:[self generateCellKeyStringWithIndexPath:indexPath]];
    return statusModel;
}

- (void)setPlayerProgressByProgress:(float)progress cellIndexPath:(NSIndexPath *)indexPath {
    BMMutexAudioStatusModel *statusModel = [self.cellStatusDictionary objectForKey:[self generateCellKeyStringWithIndexPath:indexPath]];
    statusModel.currentProgress = progress;
    if ([self isTwoIndexPathEqual:self.currentPlayingIndexPath otherIndexPath:indexPath] && [self.privatePlayer isPlaying]) {
        [self.privatePlayer pause];
        self.privatePlayer.currentTime = self.privatePlayer.duration * progress;
        [self.privatePlayer play];
    }
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

- (void)playAudioWithStatusModel:(BMMutexAudioStatusModel *)statusModel indexPath:(NSIndexPath *)indexPath {
    if ([self.privatePlayer isPlaying]) {
        [self pauseCurrentAudio];
    }
    if (![self isTwoIndexPathEqual:self.previousPlayingIndexPath otherIndexPath:indexPath] || statusModel.currentStatus == EBMPlayerStatusStop) {
        self.currentPlayingIndexPath = indexPath;
        self.currentPlayingModel = statusModel;
        self.privatePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:statusModel.audioURL error:nil];
        self.privatePlayer.delegate = self;
        statusModel.currentStatus = EBMPlayerStatusPlaying;

        if (_timer == nil) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                      target:self
                                                    selector:@selector(updateProgress)
                                                    userInfo:nil
                                                     repeats:YES];
        }
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(routeChange:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:nil];*/
        self.privatePlayer.currentTime = self.privatePlayer.duration * statusModel.currentProgress;
        [self.privatePlayer play];
        [self cellStatusDidChanged:self.currentPlayingIndexPath statusModel:statusModel];
        //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
}

- (void)pauseCurrentAudio {
    [self pauseOrStopAudioInIndexPath:self.currentPlayingIndexPath status:EBMPlayerStatusPause];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)pauseOrStopAudioInIndexPath:(NSIndexPath *)indexPath status:(EBMPlayerStatus)status {
    if ([self isTwoIndexPathEqual:indexPath otherIndexPath:self.currentPlayingIndexPath] &&
        (status == EBMPlayerStatusStop || status == EBMPlayerStatusPause)) {
        self.previousPlayingIndexPath = self.currentPlayingIndexPath;
        self.currentPlayingIndexPath = nil;
        self.currentPlayingModel = nil;
        [_timer invalidate];
        _timer = nil;
        [self.privatePlayer stop];
        self.privatePlayer = nil;
        BMMutexAudioStatusModel *statusModel =
        [self.cellStatusDictionary objectForKey:[self generateCellKeyStringWithIndexPath:self.previousPlayingIndexPath]];
        statusModel.currentStatus = status;
        if (status == EBMPlayerStatusStop) {
            statusModel.currentProgress = 0;
        }
        [self cellStatusDidChanged:self.previousPlayingIndexPath statusModel:statusModel];
    }
}

/**
 * @brief 获取当前播放器的播放进度
 * @return progress播放进度
 */
- (float)getCurrentProgress {
    if (self.privatePlayer) {
        return self.privatePlayer.currentTime / self.privatePlayer.duration;
    } else {
        return 0;
    }
}

- (BOOL)isTwoIndexPathEqual:(NSIndexPath *)indexPathA otherIndexPath:(NSIndexPath *)indexPathB {
    if (indexPathA && indexPathB && indexPathA.section == indexPathB.section && indexPathA.row == indexPathB.row) {
        return YES;
    }
    return NO;
}

#pragma mark - Delegate And DataSource

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if ([self.delegate respondsToSelector:@selector(mutexAudioManagerDidChanged:statusModel:)]) {
        [self.delegate mutexAudioManagerDidChanged:self.currentPlayingIndexPath statusModel:self.currentPlayingModel];
    }
    [self pauseOrStopAudioInIndexPath:self.currentPlayingIndexPath status:EBMPlayerStatusStop];
}

#pragma mark - Event Response

/**
 * @brief 播放器在播放时实时更新播放进度（用于更新slider）
 */
- (void)updateProgress {
    if (_timer == nil) {
        return;
    }
    //进度条显示播放进度
    float progress = [self getCurrentProgress];
    self.currentPlayingModel.currentProgress = progress;
    if ([self.delegate respondsToSelector:@selector(mutexAudioManagerPlayingCell:progress:)]) {
        [self.delegate mutexAudioManagerPlayingCell:self.currentPlayingIndexPath progress:progress];
    }
}

- (void)cellStatusDidChanged:(NSIndexPath *)changedCellIndexPath statusModel:(BMMutexAudioStatusModel *)statusModel {
    if ([self.delegate respondsToSelector:@selector(mutexAudioManagerDidChanged:statusModel:)]) {
        [self.delegate mutexAudioManagerDidChanged:changedCellIndexPath statusModel:statusModel];
    }
}

#pragma mark - Lazy Load

- (NSMutableDictionary *)cellStatusDictionary {
    if (nil == _cellStatusDictionary) {
        _cellStatusDictionary = [NSMutableDictionary dictionary];
    }
    return _cellStatusDictionary;
}
@end

@implementation BMMutexAudioStatusModel

@end
