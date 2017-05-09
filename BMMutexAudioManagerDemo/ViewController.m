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
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSURL *voiceURL = [[NSBundle bundleWithPath:bundlePath] URLForResource:[NSString stringWithFormat:@"%ld.mp3", indexPath.row % 7]
                                                             withExtension:nil];
    return [voiceURL absoluteString];
}

#pragma mark - Delegate And DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BMAudioPlayerDemoCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    BMMutexAudioStatusModel *statusModel = [[BMMutexAudioManager sharedInstance] queryStatusModelWithIndexPath:indexPath];
    if (statusModel) {
        [cell changeButtonImageWithPlayerStatus:statusModel.currentStatus];
    } else {
        [cell changeButtonImageWithPlayerStatus:EBMPlayerStatusStop];
    }

    WEAKSELF();
    cell.controlButtonClickBlock = ^() {
        [[BMMutexAudioManager sharedInstance] clickPlayButtonWithAudioURL:[weakSelf generateAudioURLWithIndexPath:indexPath]
                                                            cellIndexPath:indexPath];
    };
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

#pragma mark - Delegate And DataSource

- (void)mutexAudioManagerPlayingCell:(NSIndexPath *)playingCellIndexPath progress:(CGFloat)progress {
    NSLog(@"第%ld块，第%ld行，当前进度：%lf", playingCellIndexPath.section, playingCellIndexPath.row, progress);
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
