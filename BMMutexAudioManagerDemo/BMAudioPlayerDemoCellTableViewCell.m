//
//  BMAudioPlayerDemoCellTableViewCell.m
//  BMMutexAudioManager
//
//  Created by 李志强 on 2017/5/6.
//  Copyright © 2017年 Li Zhiqiang. All rights reserved.
//

#import "BMAudioPlayerDemoCellTableViewCell.h"
#import "BMMutexAudioManager.h"

static NSString *kRotationAnimationKey = @"rotationAnimation";

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
    [self endAnimation:self.controlButton];
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
        case EBMPlayerStatusUnDownload: {
            imageName = @"icon_download";
        } break;
        case EBMPlayerStatusDownloading: {
            imageName = @"icon_loading";
            [self startAnimation:self.controlButton];
        } break;
        case EBMPlayerStatusRetryDownload: {
            imageName = @"icon_download";
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

#pragma mark - Private Method

- (void)startAnimation:(UIView *)view {

    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath: @"transform" ];
    rotationAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    //围绕Z轴旋转，垂直与屏幕
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI/2.0, 0.0, 0.0, 1.0) ];
    rotationAnimation.duration = 0.25;
    //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    [view.layer addAnimation:rotationAnimation forKey:kRotationAnimationKey];
}

- (void)endAnimation:(UIView *)view {
    [view.layer removeAnimationForKey:kRotationAnimationKey];
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
    }
    return _voiceSlider;
}

@end
