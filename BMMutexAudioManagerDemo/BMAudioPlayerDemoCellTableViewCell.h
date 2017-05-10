//
//  BMAudioPlayerDemoCellTableViewCell.h
//  BMMutexAudioManager
//
//  Created by 李志强 on 2017/5/6.
//  Copyright © 2017年 Li Zhiqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMAudioPlayerDemoCellTableViewCell : UITableViewCell

typedef void (^ReturnSliderValueBlock)(float value);
typedef void (^ControlButtonClickBlock)(void);

@property (copy, nonatomic) ReturnSliderValueBlock returnSliderValueBlock;
@property (copy, nonatomic) ControlButtonClickBlock controlButtonClickBlock;

- (void)changeButtonImageWithPlayerStatus:(NSInteger)status;

- (void)changeSliderPositionWithProgress:(CGFloat)progress;
@end
