//
//  BMAduioDownloadManager.m
//  BMMutexAudioManager
//
//  Created by 李志强 on 2017/5/11.
//  Copyright © 2017年 Li Zhiqiang. All rights reserved.
//

#import "BMAduioDownloadManager.h"

#define kVoicePath @"Voice"

@interface BMAduioDownloadManager ()

@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation BMAduioDownloadManager

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static BMAduioDownloadManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (NSFileManager *)fileManager {
    return [NSFileManager defaultManager];
}

//获取文件路径
- (NSString *)voiceFolder {
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", kVoicePath]];
    return path;
}

- (void)createVoiceDir {
    NSString *storeDir = [self voiceFolder];
    if ([self.fileManager contentsOfDirectoryAtPath:storeDir error:nil]) {
        return;
    }
    BOOL isDir;
    BOOL doseExist = [self.fileManager fileExistsAtPath:storeDir isDirectory:&isDir];
    if (!doseExist) {
        if (![self.fileManager createDirectoryAtPath:storeDir withIntermediateDirectories:NO attributes:nil error:NULL]) {
            // DDLogError(@"create Voice folder fail");
        }
    } else if (doseExist && !isDir) {
        // 先删除后使用
        if ([self.fileManager removeItemAtPath:storeDir error:NULL]) {
            if (![self.fileManager createDirectoryAtPath:storeDir withIntermediateDirectories:NO attributes:nil error:NULL]) {
            }
        }
    }
}

- (void)asynchronousVoiceDownload:(NSDictionary *)voiceDict {
    if (!voiceDict) {
        return;
    }
    [self createVoiceDir];
    NSString *voiceUrl = [voiceDict valueForKey:@"voiceUrl"];
    NSString *voiceName = [voiceDict valueForKey:@"voiceName"];
    if (!voiceName.length || !voiceUrl.length) {
        return;
    }
    NSString *voicePath = [NSString stringWithFormat:@"%@/%@.voice", kVoicePath, voiceName];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths[0];
    NSString *voiceSavePath = [documentDirectory stringByAppendingPathComponent:voicePath];
    if ([self.fileManager fileExistsAtPath:voiceSavePath]) {
        if (self.voiceDownloadSuccessBlock) {
            self.voiceDownloadSuccessBlock(voiceName, EBMAudioDownloadStatusSuccess, voiceSavePath);
        }
    } else {
        [self asynchronousDownload:[NSURL URLWithString:voiceUrl] voiceSavePath:voiceSavePath voiceName:voiceName];
    }
}

- (NSString *)voiceLocalSavePathAtVoiceName:(NSString *)voiceName {
    if (!voiceName.length) {
        return nil;
    }
    NSString *voicePath = [NSString stringWithFormat:@"%@/%@.voice", kVoicePath, voiceName];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths[0];
    NSString *voiceSavePath = [documentDirectory stringByAppendingPathComponent:voicePath];
    if ([self.fileManager fileExistsAtPath:voiceSavePath]) {
        return voiceSavePath;
    } else {
        return nil;
    }
}

#pragma mark - Asynchronous Download
- (void)asynchronousDownload:(NSURL *)url voiceSavePath:(NSString *)voiceSavePath voiceName:(NSString *)voiceName {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSOperationQueue *queue = [NSOperationQueue new];
        [NSURLConnection
        sendAsynchronousRequest:request
                          queue:queue
              completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                  if ((([httpResponse statusCode] / 100) == 2)) {
                      if (connectionError == nil && data.length > 0) {                          // 包下载成功
                          [self saveData:data voiceSavePath:voiceSavePath voiceName:voiceName]; // 存储数据
                      } else {
                          if (connectionError) {
                              NSString *errorDescription =
                              [NSString stringWithFormat:@"网络请求错误:%@", [connectionError localizedDescription]];
                              if (weakSelf.voiceDownloadSuccessBlock) {
                                  weakSelf.voiceDownloadSuccessBlock(voiceName, EBMAudioDownloadStatusNetworkFail, nil);
                              }
                              // DDLogError(@"saveData Voice folder fail %@", errorDescription);
                          } else {
                              if (weakSelf.voiceDownloadSuccessBlock) {
                                  weakSelf.voiceDownloadSuccessBlock(voiceName, EBMAudioDownloadStatusNoData, nil);
                              }
                              // DDLogError(@"saveData Voice folder fail data is 0");
                          }
                      }
                  } else {
                      NSDictionary *userInfo = @{
                          NSLocalizedDescriptionKey:
                          NSLocalizedString(@"HTTP Error", @"Error message displayed when receving a connection error.")
                      };
                      NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
                      if ([error code] == 404) {
                          if (weakSelf.voiceDownloadSuccessBlock) {
                              weakSelf.voiceDownloadSuccessBlock(voiceName, EBMAudioDownloadStatusNetworkFail, nil);
                          }
                      }
                  }
              }];
    });
}

#pragma mark - 文件处理
- (BOOL)saveData:(NSData *)data voiceSavePath:(NSString *)voiceSavePath voiceName:(NSString *)voiceName {
    @synchronized(self) {
        if (data && data.length > 0) {
            if ([data writeToFile:voiceSavePath atomically:YES]) {
                if (self.voiceDownloadSuccessBlock) {
                    self.voiceDownloadSuccessBlock(voiceName, EBMAudioDownloadStatusSuccess, voiceSavePath);
                }
                return YES;
            }
        }
        if (self.voiceDownloadSuccessBlock) {
            self.voiceDownloadSuccessBlock(voiceName, EBMAudioDownloadStatusSaveFail, nil);
        }
        return NO;
    }
}

- (void)removeVoice {
    NSArray *filePathsArray = [self.fileManager contentsOfDirectoryAtPath:[self voiceFolder] error:nil]; //取得文件列表
    if (!filePathsArray) {
        return;
    }
    for (int i = 0; i < filePathsArray.count; i++) {
        NSString *voicePath = [[self voiceFolder] stringByAppendingPathComponent:filePathsArray[i]]; //获取前一个文件完整路径
        NSString *tempStr = [voicePath lastPathComponent];
        if ([tempStr rangeOfString:@"voice"].location != NSNotFound) {
            NSDictionary *firstFileInfo =
            [[NSFileManager defaultManager] attributesOfItemAtPath:voicePath error:nil]; //获取前一个文件信息
            NSDate *VoiceDate = firstFileInfo[NSFileModificationDate];
            NSTimeInterval voiceTime = [VoiceDate timeIntervalSince1970] * 1;
            NSTimeInterval dateTodayTime = [[NSDate date] timeIntervalSince1970] * 1;
            if (dateTodayTime - voiceTime > 60 * 60 * 24) {
                [self.fileManager removeItemAtPath:voicePath error:nil];
            }
        }
    }
}

@end
