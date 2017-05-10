//
//  BMAudioPlayerDemoCellTableViewCell.m
//  BMMutexAudioManager
//
//  Created by 李志强 on 2017/5/6.
//  Copyright © 2017年 Li Zhiqiang. All rights reserved.
//

#import "BMAudioPlayerDemoCellTableViewCell.h"
#import "BMMutexAudioManager.h"

@interface BMAudioPlayerDemoCellTableViewCell ()

@property (nonatomic, strong) UIButton *controlButton;
@property (nonatomic, strong) UISlider *voiceSlider;

@end

@implementation BMAudioPlayerDemoCellTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configUI];
    }
    return self;
}

#pragma mark - Public Method

- (void)changeButtonImageWithPlayerStatus:(NSInteger)status {
    NSString *imageName;
    switch (status) {
        case EBMPlayerStatusStop: {
            imageName = @"icon_play";
        } break;
        case EBMPlayerStatusPause: {
            imageName = @"icon_play";
        } break;
        case EBMPlayerStatusPlaying: {
            imageName = @"icon_pause";
        } break;
        default: { imageName = @"icon_download"; } break;
    }
    [self.controlButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)changeSliderPositionWithProgress:(CGFloat)progress {
    self.voiceSlider.value = progress;
}

#pragma mark - Init Method

- (void)configUI {
    [self addSubview:self.controlButton];
    [self addSubview:self.voiceSlider];
    [self.controlButton addTarget:self action:@selector(controlButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.voiceSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Event Response

- (void)controlButtonClick {
    if (self.controlButtonClickBlock) {
        self.controlButtonClickBlock();
    }
}

- (void)sliderValueChanged:(id)sender {
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider *slider = (UISlider *)sender;
        if (self.returnSliderValueBlock) {
            self.returnSliderValueBlock(slider.value);
        }
    }
}

#pragma mark - Lazy Load

- (UIButton *)controlButton {
    if (nil == _controlButton) {
        _controlButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 30, 50, 50)];
    }
    return _controlButton;
}

- (UISlider *)voiceSlider {
    if (nil == _voiceSlider) {
        _voiceSlider = [[UISlider alloc] initWithFrame:CGRectMake(100, 42.5, 200, 25)];
        _voiceSlider.continuous = NO;//重点
    }
    return _voiceSlider;
}

@end
