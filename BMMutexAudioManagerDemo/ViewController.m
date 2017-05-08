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

#define SCREEN_WIDTH CGRectGetWidth([[UIScreen mainScreen] bounds])
#define SCREEN_HEIGHT CGRectGetHeight([[UIScreen mainScreen] bounds])

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSURL *voiceURL = [[NSBundle bundleWithPath:bundlePath] URLForResource:@"blankSpace" withExtension:@"mp3"];
    [[BMMutexAudioManager sharedInstance] clickPlayButtonWithAudioURL:[voiceURL absoluteString] cellIndexPath:[NSIndexPath indexPathForRow:4 inSection:2]];
}

#pragma mark - Init Method

- (void)configUI {
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[BMAudioPlayerDemoCellTableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - Delegate And DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BMAudioPlayerDemoCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
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
