//
//  CustomView.h
//
//  Code generated using QuartzCode 1.56.0 on 2017/5/12.
//  www.quartzcodeapp.com
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface CustomView : UIView

- (void)addUntitled1Animation;
- (void)addUntitled1AnimationCompletionBlock:(void (^)(BOOL finished))completionBlock;
- (void)addUntitled1AnimationReverse:(BOOL)reverseAnimation completionBlock:(void (^)(BOOL finished))completionBlock;
- (void)removeAnimationsForAnimationId:(NSString *)identifier;
- (void)removeAllAnimations;

@end
