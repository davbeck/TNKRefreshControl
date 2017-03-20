//
//  TNKActivityIndicatorView.m
//  Pods
//
//  Created by David Beck on 1/13/15.
//
//

#import "TNKActivityIndicatorView.h"


#define TNKActivityIndicatorViewLineWidth (2.0)


@interface TNKActivityIndicatorView ()
{
	CAShapeLayer *_spinnerView;
	
	BOOL _animating;
}

@end

@implementation TNKActivityIndicatorView

#pragma mark - Properties

- (void)setProgress:(CGFloat)progress
{
	[self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
	_progress = MAX(MIN(progress, 1.0), 0.0);
	
	[self _updateProgressAnimated:animated];
}

- (void)_updateProgressAnimated:(BOOL)animated
{
	CGFloat progress = 0.0;
	if (!_animating) {
		progress = 0.9 * _progress + _spinnerView.strokeStart;
	} else {
		progress = 0.95;
	}
	
	
	if (animated) {
		CABasicAnimation *strokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
		strokeEnd.fromValue = [_spinnerView.presentationLayer valueForKey:@"strokeEnd"];
		strokeEnd.toValue = @(progress);
		strokeEnd.duration = 0.2;
		strokeEnd.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		
		[_spinnerView addAnimation:strokeEnd forKey:@"update progress"];
		_spinnerView.strokeEnd = progress;
	} else {
		[CATransaction setDisableActions:YES];
		_spinnerView.strokeEnd = progress;
		[CATransaction setDisableActions:NO];
	}
}

- (BOOL)isAnimating
{
	return _animating;
}

- (void)tintColorDidChange
{
	[super tintColorDidChange];
	
	_spinnerView.strokeColor = self.tintColor.CGColor;
}


#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		_spinnerView = [CAShapeLayer new];
		_spinnerView.fillColor = [UIColor clearColor].CGColor;
		_spinnerView.strokeColor = self.tintColor.CGColor;
		_spinnerView.strokeStart = 0.05;
		_spinnerView.strokeEnd = 0.95;
		_spinnerView.transform = CATransform3DMakeRotation(-M_PI_2, 0.0, 0.0, 1.0);
		[self.layer addSublayer:_spinnerView];
		
		[self _updateProgressAnimated:NO];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		_spinnerView = [CAShapeLayer new];
		_spinnerView.fillColor = [UIColor clearColor].CGColor;
		_spinnerView.strokeColor = self.tintColor.CGColor;
		_spinnerView.strokeStart = 0.05;
		_spinnerView.strokeEnd = 0.95;
		_spinnerView.transform = CATransform3DMakeRotation(-M_PI_2, 0.0, 0.0, 1.0);
		[self.layer addSublayer:_spinnerView];
		
		[self _updateProgressAnimated:NO];
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
	
	// because we are transforming this view all over the place, we can't set the frame
	_spinnerView.bounds = self.layer.bounds;
	_spinnerView.position = CGPointMake(self.layer.bounds.size.width / 2.0, self.layer.bounds.size.height / 2.0);
	
	CGRect pathRect = CGRectInset(_spinnerView.bounds, TNKActivityIndicatorViewLineWidth / 2.0, TNKActivityIndicatorViewLineWidth / 2.0);
	UIBezierPath *path = path = [UIBezierPath bezierPathWithOvalInRect:pathRect];
	path.lineWidth = TNKActivityIndicatorViewLineWidth;
	_spinnerView.path = path.CGPath;
}


#pragma mark - Animation

- (void)startAnimating
{
	[self startAnimatingWithFadeInAnimation:self.progress <= 0.0 completion:nil];
}

- (void)startAnimatingWithFadeInAnimation:(BOOL)animated completion:(void (^)())completion
{
	if (!_animating) {
		_animating = YES;
		
		[self _updateProgressAnimated:YES];
		
		CABasicAnimation *refreshingAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
		refreshingAnimation.duration = 1.0;
		refreshingAnimation.repeatCount = CGFLOAT_MAX;
		refreshingAnimation.fromValue = @(-M_PI_2);
		refreshingAnimation.byValue = @(M_PI * 2.0);
		[_spinnerView addAnimation:refreshingAnimation forKey:@"refreshing"];
		
		if (animated) {
			[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseInOut animations:^{
				self.alpha = 1;
			} completion:nil];
		} else {
			self.alpha = 1;
		}
	}
}

- (void)stopAnimating
{
	[self stopAnimatingWithFadeAwayAnimation:YES completion:nil];
}

- (void)stopAnimatingWithFadeAwayAnimation:(BOOL)animated completion:(void (^)())completion
{
	if (_animating) {
		_animating = NO;
		
		if (animated) {
			[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseInOut animations:^{
				self.alpha = 0;
			} completion:^(BOOL finished) {
				if (finished && !_animating) {
					self.alpha = 1;
					[_spinnerView removeAnimationForKey:@"refreshing"];
				}
				
				[self _updateProgressAnimated:NO];
				
				if (completion != nil) {
					completion();
				}
			}];
		} else {
			[_spinnerView removeAnimationForKey:@"refreshing"];
			
			self.alpha = 1;
			[self _updateProgressAnimated:NO];
			
			if (completion != nil) {
				completion();
			}
		}
	}
}

@end
