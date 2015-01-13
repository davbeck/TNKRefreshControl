//
//  TCActivityIndicatorView.m
//  Pods
//
//  Created by David Beck on 1/13/15.
//
//

#import "TCActivityIndicatorView.h"


@interface TCActivityIndicatorView ()
{
    UIView *_spinnerView;
    CAShapeLayer *_spinnerLayer;
    CATransform3D _defaultTransform;
    
    BOOL _animating;
}

@end

@implementation TCActivityIndicatorView

#pragma mark - Properties

- (void)setProgress:(CGFloat)progress
{
    _progress = MAX(MIN(progress, 1.0), 0.0);
    
    [self _updateProgress];
}

- (void)_updateProgress
{
    [CATransaction setDisableActions:YES];
    if (!_animating) {
        _spinnerLayer.strokeEnd = 0.9 * _progress + _spinnerLayer.strokeStart;
    } else {
        _spinnerLayer.strokeEnd = 0.95;
    }
    [CATransaction setDisableActions:NO];
}

- (BOOL)isAnimating
{
    return _animating;
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    _spinnerLayer.strokeColor = self.tintColor.CGColor;
}


#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _defaultTransform = CATransform3DMakeRotation(-M_PI_2, 0.0, 0.0, 1.0);
        
        _spinnerView = [UIView new];
        [self addSubview:_spinnerView];
        
        _spinnerLayer = [[CAShapeLayer alloc] init];
        [_spinnerView.layer addSublayer:_spinnerLayer];
        _spinnerLayer.fillColor = [UIColor clearColor].CGColor;
        _spinnerLayer.lineWidth = 2.0;
        _spinnerLayer.strokeColor = self.tintColor.CGColor;
        _spinnerLayer.strokeStart = 0.05;
        _spinnerLayer.strokeEnd = 0.95;
        _spinnerLayer.transform = _defaultTransform;
    }
    return self;
}


#pragma mark - Layout

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(34.0, 34.0);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return self.intrinsicContentSize;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _spinnerView.frame = self.bounds;
    _spinnerLayer.frame = _spinnerView.bounds;
    CGRect pathRect = CGRectInset(_spinnerLayer.bounds, _spinnerLayer.lineWidth / 2.0, _spinnerLayer.lineWidth / 2.0);
    _spinnerLayer.path = [UIBezierPath bezierPathWithOvalInRect:pathRect].CGPath;
}


#pragma mark - Animation

- (void)startAnimating
{
    _animating = YES;
    
    [self _updateProgress];
    
    CABasicAnimation *refreshingAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    refreshingAnimation.duration = 1.0;
    refreshingAnimation.repeatCount = CGFLOAT_MAX;
    refreshingAnimation.fromValue = @(-M_PI_2);
    refreshingAnimation.toValue = @(M_PI * 2.0 - M_PI_2);
    [_spinnerLayer addAnimation:refreshingAnimation forKey:@"refreshing"];
}

- (void)stopAnimating
{
    _animating = NO;
    
    [self _updateProgress];
    
    [_spinnerLayer removeAnimationForKey:@"refreshing"];
}

@end
