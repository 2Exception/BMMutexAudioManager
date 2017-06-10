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
@property (nonatomic, strong) UILabel *progressLabel;

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

- (void)changeProgressLabelWithCurrentSecond:(NSInteger)currentSecond duration:(NSInteger)duration {
    if (currentSecond <= 0 && duration <= 0) {
        self.progressLabel.text = @"";
    } else {
        self.progressLabel.text = [NSString stringWithFormat:@"%@/%@", [self getMMSSFromSS:currentSecond], [self getMMSSFromSS:duration]];
    }
}

#pragma mark - Init Method

- (void)configUI {
    [self addSubview:self.controlButton];
    [self addSubview:self.voiceSlider];
    [self.controlButton addTarget:self action:@selector(controlButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.voiceSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.progressLabel];
}

#pragma mark - Private Method

- (void)startAnimation:(UIView *)view {

    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotationAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    //围绕Z轴旋转，垂直与屏幕
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI / 2.0, 0.0, 0.0, 1.0)];
    rotationAnimation.duration = 0.25;
    //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    [view.layer addAnimation:rotationAnimation forKey:kRotationAnimationKey];
}

- (void)endAnimation:(UIView *)view {
    [view.layer removeAnimationForKey:kRotationAnimationKey];
}

- (NSString *)getMMSSFromSS:(NSInteger)seconds {
    if (seconds >= 0) {
        NSInteger hour = seconds / 3600;
        NSInteger minute = (seconds % 3600) / 60;
        NSInteger second = seconds - hour * 3600 - minute * 60;

        NSMutableString *charTime;
        if (second) {
            if (second < 10) {
                charTime = [NSMutableString stringWithFormat:@"0%ld", second];
            } else {
                charTime = [NSMutableString stringWithFormat:@"%ld", second];
            }
        } else {
            charTime = [NSMutableString stringWithString:@"00"];
        }
        if (minute) {
            [charTime insertString:[NSString stringWithFormat:@"%ld:", minute] atIndex:0];
        } else {
            [charTime insertString:@"00:" atIndex:0];
        }
        if (hour) {
            [charTime insertString:[NSString stringWithFormat:@"%ld:", hour] atIndex:0];
        }
        return charTime;
    }
    return nil;
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
        _controlButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 30, 50, 50)];
    }
    return _controlButton;
}

- (UISlider *)voiceSlider {
    if (nil == _voiceSlider) {
        _voiceSlider = [[UISlider alloc] initWithFrame:CGRectMake(80, 42.5, 160, 25)];
    }
    return _voiceSlider;
}

- (UILabel *)progressLabel {
    if (nil == _progressLabel) {
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(255, 47, 100, 15)];
    }
    return _progressLabel;
}

@end
