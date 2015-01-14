//
//  TCActivityIndicatorView.m
//  Pods
//
//  Created by David Beck on 1/13/15.
//
//

#import "TCActivityIndicatorView.h"

#import <CKShapeView/CKShapeView.h>


#define TNKActivityIndicatorViewLineWidth (2.0)


@interface TCActivityIndicatorView ()
{
    CKShapeView *_spinnerView;
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
        _spinnerView.strokeEnd = 0.9 * _progress + _spinnerView.strokeStart;
    } else {
        _spinnerView.strokeEnd = 0.95;
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
    
    _spinnerView.strokeColor = self.tintColor;
}


#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _defaultTransform = CATransform3DMakeRotation(-M_PI_2, 0.0, 0.0, 1.0);
        
        _spinnerView = [CKShapeView new];
        _spinnerView.fillColor = [UIColor clearColor];
        _spinnerView.strokeColor = self.tintColor;
        _spinnerView.strokeStart = 0.05;
        _spinnerView.strokeEnd = 0.95;
        _spinnerView.layer.transform = _defaultTransform;
        [self addSubview:_spinnerView];
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
    CGRect pathRect = CGRectInset(_spinnerView.bounds, TNKActivityIndicatorViewLineWidth / 2.0, TNKActivityIndicatorViewLineWidth / 2.0);
    UIBezierPath *path = path = [UIBezierPath bezierPathWithOvalInRect:pathRect];
    path.lineWidth = TNKActivityIndicatorViewLineWidth;
    _spinnerView.path = path;
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
    [_spinnerView.layer addAnimation:refreshingAnimation forKey:@"refreshing"];
}

- (void)stopAnimating
{
    _animating = NO;
    
    [self _updateProgress];
    
    [_spinnerView.layer removeAnimationForKey:@"refreshing"];
}

@end
