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

@property (nonatomic, strong) NSDictionary *statusDic;

@end

@implementation BMMutexAudioManager

/*manager的单例*/
+ (instancetype)sharedInstance {
    static BMMutexAudioManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (float)durationWithResourceName:(NSString *)resourceName extension:(NSString *)extension {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSURL *voiceURL = [[NSBundle bundleWithPath:bundlePath] URLForResource:resourceName withExtension:extension];
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:voiceURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}

@end
