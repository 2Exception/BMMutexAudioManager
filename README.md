# BMMutexAudioManager

## Feature
![image](https://github.com/BlueMercury/BMMutexAudioManager/blob/master/demo.gif)

## Installation

Simply copy "BMMutexAudioManager" floder to your project.

## Getting Started
Use by including the following import:

```
#import "BMMutexAudioManager.h"
```
In ViewController, you need to adopt these protocols:

```
@interface ViewController () <UITableViewDelegate, UITableViewDataSource, BMMutexAudioManagerDelegate>
```

And then implement the methods in the protocol:

```
- (void)mutexAudioManagerPlayingCell:(NSIndexPath *)playingCellIndexPath
                            progress:(CGFloat)progress
                            duration:(NSInteger)duration {
    //update current playing cell's UI in this method.
}

- (void)mutexAudioManagerDidChanged:(NSIndexPath *)changedIndexPath statusModel:(BMMutexAudioStatusModel *)statusModel {
    //update last playing cell and current playing cell in this method.
}
```

In UITableViewDataSource,method  "tableView:cellForRowAtIndexPath:", you need to get the StatusModel and update cell to its initial state. And give the slider's value to manager. For example:

```
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
```


## Communication

- If you need help, or if you'd like to ask a general question, please contact me. Email:  lizhiqiangcs@outlook.com
- If you found a bug, and can provide steps to reliably reproduce it, please open an issue.
- If you have a feature request, please open an issue.
- If you want to contribute, please submit a pull request.