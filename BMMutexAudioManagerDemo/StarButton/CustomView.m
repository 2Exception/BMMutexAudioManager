//
//  CustomView.m
//
//  Code generated using QuartzCode 1.56.0 on 2017/5/12.
//  www.quartzcodeapp.com
//

#import "CustomView.h"
#import "QCMethod.h"

@interface CustomView ()

@property (nonatomic, strong) NSMutableDictionary *layers;
@property (nonatomic, strong) NSMapTable *completionBlocks;
@property (nonatomic, assign) BOOL updateLayerValueForCompletedAnimation;

@end

@implementation CustomView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupProperties];
        [self setupLayers];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupProperties];
        [self setupLayers];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setupLayerFrames];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self setupLayerFrames];
}

- (void)setupProperties {
    self.completionBlocks =
    [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsOpaqueMemory valueOptions:NSPointerFunctionsStrongMemory];
    ;
    self.layers = [NSMutableDictionary dictionary];
    self.updateLayerValueForCompletedAnimation = YES;
}

- (void)setupLayers {
    CAShapeLayer *star = [CAShapeLayer layer];
    [self.layer addSublayer:star];
    self.layers[@"star"] = star;

    [self resetLayerPropertiesForLayerIdentifiers:nil];
    [self setupLayerFrames];
}

- (void)resetLayerPropertiesForLayerIdentifiers:(NSArray *)layerIds {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    if (!layerIds || [layerIds containsObject:@"star"]) {
        CAShapeLayer *star = self.layers[@"star"];
        star.fillColor = [UIColor colorWithRed:0.99 green:1 blue:1 alpha:1].CGColor;
        star.strokeColor = [UIColor colorWithRed:0.329 green:0.329 blue:0.329 alpha:1].CGColor;
    }

    [CATransaction commit];
}

- (void)setupLayerFrames {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    CAShapeLayer *star = self.layers[@"star"];
    star.frame = CGRectMake(0 * CGRectGetWidth(star.superlayer.bounds), 0 * CGRectGetHeight(star.superlayer.bounds),
                            1 * CGRectGetWidth(star.superlayer.bounds), 1 * CGRectGetHeight(star.superlayer.bounds));
    star.path = [self starPathWithBounds:[self.layers[@"star"] bounds]].CGPath;

    [CATransaction commit];
}

#pragma mark - Animation Setup

- (void)addUntitled1Animation {
    [self addUntitled1AnimationCompletionBlock:nil];
}

- (void)addUntitled1AnimationCompletionBlock:(void (^)(BOOL finished))completionBlock {
    [self addUntitled1AnimationReverse:NO completionBlock:completionBlock];
}

- (void)addUntitled1AnimationReverse:(BOOL)reverseAnimation completionBlock:(void (^)(BOOL finished))completionBlock {
    if (completionBlock) {
        CABasicAnimation *completionAnim = [CABasicAnimation animationWithKeyPath:@"completionAnim"];
        ;
        completionAnim.duration = 0.459;
        completionAnim.delegate = self;
        [completionAnim setValue:@"Untitled1" forKey:@"animId"];
        [completionAnim setValue:@(NO) forKey:@"needEndAnim"];
        [self.layer addAnimation:completionAnim forKey:@"Untitled1"];
        [self.completionBlocks setObject:completionBlock forKey:[self.layer animationForKey:@"Untitled1"]];
    }

    NSString *fillMode = reverseAnimation ? kCAFillModeBoth : kCAFillModeForwards;

    CFTimeInterval totalDuration = 0.459;

    ////Star animation
    CAKeyframeAnimation *starFillColorAnim = [CAKeyframeAnimation animationWithKeyPath:@"fillColor"];
    starFillColorAnim.values = @[
        (id)[UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1].CGColor,
        (id)[UIColor colorWithRed:1 green:0.961 blue:0.376 alpha:1].CGColor
    ];
    starFillColorAnim.keyTimes = @[@0, @1];
    starFillColorAnim.duration = 0.459;

    CAShapeLayer *star = self.layers[@"star"];

    CAKeyframeAnimation *starTransformAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    starTransformAnim.values = @[
        [NSValue valueWithCATransform3D:CATransform3DIdentity],
        [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.2)], [NSValue valueWithCATransform3D:CATransform3DIdentity]
    ];
    starTransformAnim.keyTimes = @[@0, @0.301, @1];
    starTransformAnim.duration = 0.459;

    CAAnimationGroup *starUntitled1Anim = [QCMethod groupAnimations:@[starFillColorAnim, starTransformAnim] fillMode:fillMode];
    if (reverseAnimation)
        starUntitled1Anim = (CAAnimationGroup *)[QCMethod reverseAnimation:starUntitled1Anim totalDuration:totalDuration];
    [star addAnimation:starUntitled1Anim forKey:@"starUntitled1Anim"];
}

#pragma mark - Animation Cleanup

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    void (^completionBlock)(BOOL) = [self.completionBlocks objectForKey:anim];
    ;
    if (completionBlock) {
        [self.completionBlocks removeObjectForKey:anim];
        if ((flag && self.updateLayerValueForCompletedAnimation) || [[anim valueForKey:@"needEndAnim"] boolValue]) {
            [self updateLayerValuesForAnimationId:[anim valueForKey:@"animId"]];
            [self removeAnimationsForAnimationId:[anim valueForKey:@"animId"]];
        }
        completionBlock(flag);
    }
}

- (void)updateLayerValuesForAnimationId:(NSString *)identifier {
    if ([identifier isEqualToString:@"Untitled1"]) {
        [QCMethod updateValueFromPresentationLayerForAnimation:[self.layers[@"star"] animationForKey:@"starUntitled1Anim"]
                                                      theLayer:self.layers[@"star"]];
    }
}

- (void)removeAnimationsForAnimationId:(NSString *)identifier {
    if ([identifier isEqualToString:@"Untitled1"]) {
        [self.layers[@"star"] removeAnimationForKey:@"starUntitled1Anim"];
    }
}

- (void)removeAllAnimations {
    [self.layers enumerateKeysAndObjectsUsingBlock:^(id key, CALayer *layer, BOOL *stop) {
        [layer removeAllAnimations];
    }];
}

#pragma mark - Bezier Path

- (UIBezierPath *)starPathWithBounds:(CGRect)bounds {
    UIBezierPath *starPath = [UIBezierPath bezierPath];
    CGFloat minX = CGRectGetMinX(bounds), minY = CGRectGetMinY(bounds), w = CGRectGetWidth(bounds), h = CGRectGetHeight(bounds);

    [starPath moveToPoint:CGPointMake(minX + 0.29282 * w, minY + 0.24853 * h)];
    [starPath addCurveToPoint:CGPointMake(minX + 0.16621 * w, minY + 0.65263 * h)
                controlPoint1:CGPointMake(minX + 0.06378 * w, minY + 0.28304 * h)
                controlPoint2:CGPointMake(minX + -0.16526 * w, minY + 0.31756 * h)];
    [starPath addCurveToPoint:CGPointMake(minX + 0.49768 * w, minY + 0.90238 * h)
                controlPoint1:CGPointMake(minX + 0.12709 * w, minY + 0.8892 * h)
                controlPoint2:CGPointMake(minX + 0.08796 * w, minY + 1.12576 * h)];
    [starPath addCurveToPoint:CGPointMake(minX + 0.82915 * w, minY + 0.65263 * h)
                controlPoint1:CGPointMake(minX + 0.70254 * w, minY + 1.01407 * h)
                controlPoint2:CGPointMake(minX + 0.9074 * w, minY + 1.12576 * h)];
    [starPath addCurveToPoint:CGPointMake(minX + 0.70254 * w, minY + 0.24853 * h)
                controlPoint1:CGPointMake(minX + 0.99488 * w, minY + 0.48509 * h)
                controlPoint2:CGPointMake(minX + 1.16062 * w, minY + 0.31756 * h)];
    [starPath addCurveToPoint:CGPointMake(minX + 0.29282 * w, minY + 0.24853 * h)
                controlPoint1:CGPointMake(minX + 0.60011 * w, minY + 0.0333 * h)
                controlPoint2:CGPointMake(minX + 0.49768 * w, minY + -0.18194 * h)];
    [starPath closePath];
    [starPath moveToPoint:CGPointMake(minX + 0.29282 * w, minY + 0.24853 * h)];

    return starPath;
}

@end
