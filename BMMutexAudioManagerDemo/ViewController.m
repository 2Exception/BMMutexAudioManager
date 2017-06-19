//
//  ViewController.m
//  BMMutexAudioManager
//
//  Created by 李志强 on 2017/5/4.
//  Copyright © 2017年 Li Zhiqiang. All rights reserved.
//

#import "ViewController.h"
#import "BMAudioPlayerDemoCellTableViewCell.h"
#import "BMMutexAudioManager.h"

#define WEAKSELF() __weak __typeof(&*self) weakSelf = self

#define SCREEN_WIDTH CGRectGetWidth([[UIScreen mainScreen] bounds])
#define SCREEN_HEIGHT CGRectGetHeight([[UIScreen mainScreen] bounds])

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, BMMutexAudioManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [BMMutexAudioManager sharedInstance].delegate = self;
}

- (void)dealloc {
    [BMMutexAudioManager sharedInstance].delegate = nil;
}

#pragma mark - Init Method

- (void)configUI {
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[BMAudioPlayerDemoCellTableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - Private Method

- (NSString *)generateAudioURLWithIndexPath:(NSIndexPath *)indexPath {
    return [NSString stringWithFormat:@"https://s3-us-west-2.amazonaws.com/qqxybucket/%ld.mp3", indexPath.row];
}

#pragma mark - Delegate And DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BMAudioPlayerDemoCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    BMMutexAudioStatusModel *statusModel =
    [[BMMutexAudioManager sharedInstance] queryStatusModelWithIndexPath:indexPath
                                                               audioURL:[self generateAudioURLWithIndexPath:indexPath]];
    if (statusModel) {
        [cell changeButtonImageWithPlayerStatus:statusModel.currentStatus];
        [cell changeProgressLabelWithCurrentSecond:statusModel.currentProgress * statusModel.duration duration:statusModel.duration];
    } else {
        [cell changeButtonImageWithPlayerStatus:EBMPlayerStatusStop];
    }
    [cell changeSliderPositionWithProgress:statusModel.currentProgress];

    cell.controlButtonClickBlock = ^() {
        [[BMMutexAudioManager sharedInstance] clickPlayButtonWithAudioURL:[self generateAudioURLWithIndexPath:indexPath]
                                                            cellIndexPath:indexPath];
    };

    cell.returnSliderValueBlock = ^(float value) {
        NSLog(@"拖动值：%lf", value);
        [[BMMutexAudioManager sharedInstance] setPlayerProgressByProgress:value cellIndexPath:indexPath];
    };
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 245;
}

#pragma mark - BMMutexAudioManager delegate

- (void)mutexAudioManagerPlayingCell:(NSIndexPath *)playingCellIndexPath
                            progress:(CGFloat)progress
                            duration:(NSInteger)duration {
    NSLog(@"第%ld块，第%ld行，当前进度：%lf", playingCellIndexPath.section, playingCellIndexPath.row, progress);
    BMAudioPlayerDemoCellTableViewCell *cell = [self.tableView cellForRowAtIndexPath:playingCellIndexPath];
    [cell changeSliderPositionWithProgress:progress];
    [cell changeProgressLabelWithCurrentSecond:progress * duration duration:duration];
}

- (void)mutexAudioManagerDidChanged:(NSIndexPath *)changedIndexPath statusModel:(BMMutexAudioStatusModel *)statusModel {
    BMAudioPlayerDemoCellTableViewCell *cell = [self.tableView cellForRowAtIndexPath:changedIndexPath];
    if ([NSThread isMainThread]) {
        [cell changeButtonImageWithPlayerStatus:statusModel.currentStatus];
        [cell changeSliderPositionWithProgress:statusModel.currentProgress];
        if (statusModel.duration > 0 && statusModel.currentStatus == EBMPlayerStatusStop) {
            [cell changeProgressLabelWithCurrentSecond:0 duration:statusModel.duration];
        }
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [cell changeButtonImageWithPlayerStatus:statusModel.currentStatus];
            [cell changeSliderPositionWithProgress:statusModel.currentProgress];
            if (statusModel.duration > 0 && statusModel.currentStatus == EBMPlayerStatusStop) {
                [cell changeProgressLabelWithCurrentSecond:0 duration:statusModel.duration];
            }
        });
    }
}

#pragma mark - Lazy Load

- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView =
        [[UITableView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    }
    return _tableView;
}
@end
