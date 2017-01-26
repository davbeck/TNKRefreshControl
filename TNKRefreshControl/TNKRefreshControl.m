//
//  TNKRefreshControl.m
//  Pods
//
//  Created by David Beck on 1/13/15.
//
//

#import "TNKRefreshControl.h"

#import <objc/runtime.h>

#import "TNKActivityIndicatorView.h"


#define TNKRefreshControlHeight 44.0

static void *TNKScrollViewContext = &TNKScrollViewContext;


typedef NS_ENUM(NSUInteger, TNKRefreshControlState) {
	TNKRefreshControlStateWaiting,
	TNKRefreshControlStateRefreshing,
	TNKRefreshControlStateEnding,
};


@interface TNKRefreshControl ()
{
	TNKActivityIndicatorView *_activityIndicator;
	TNKRefreshControlState _state;
	BOOL _ignoreOffsetChanged;// sometimes we aren't done yet
}

@end

@implementation TNKRefreshControl

- (BOOL)isRefreshing
{
	return _state == TNKRefreshControlStateRefreshing;
}

- (void)resetContentInset
{
	UIEdgeInsets contentInset = self.scrollView.contentInset;
	contentInset.top -= _addedContentInset.top;
	contentInset.left -= _addedContentInset.left;
	contentInset.right -= _addedContentInset.right;
	contentInset.bottom -= _addedContentInset.bottom;
	self.scrollView.contentInset = contentInset;
	
	_addedContentInset = UIEdgeInsetsZero;
}

- (void)setAddedContentInset:(UIEdgeInsets)addedInsets
{
	if (!UIEdgeInsetsEqualToEdgeInsets(_addedContentInset, addedInsets)) {
		UIEdgeInsets contentInset = self.scrollView.contentInset;
		CGPoint contentOffset = self.scrollView.contentOffset;
		
		contentInset.top -= _addedContentInset.top;
		contentInset.left -= _addedContentInset.left;
		contentInset.right -= _addedContentInset.right;
		contentInset.bottom -= _addedContentInset.bottom;
		
		contentInset.top += addedInsets.top;
		contentInset.left += addedInsets.left;
		contentInset.right += addedInsets.right;
		contentInset.bottom += addedInsets.bottom;
		
		
		_addedContentInset = addedInsets;
		
		_ignoreOffsetChanged = YES;
		self.scrollView.contentInset = contentInset;
		_ignoreOffsetChanged = NO;
		self.scrollView.contentOffset = contentOffset;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == TNKScrollViewContext) {
		if (!_ignoreOffsetChanged) {
			[self _layoutScrollView];
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (instancetype)initWithFrame:(CGRect)frame
{
	frame.size.height = TNKRefreshControlHeight;
	
	self = [super initWithFrame:frame];
	if (self != nil) {
		//        self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1];
		
		_activityIndicator = [TNKActivityIndicatorView new];
		[self addSubview:_activityIndicator];
		//        _activityIndicator.backgroundColor = [UIColor greenColor];
	}
	
	return self;
}

- (UIScrollView *)_scrollViewForSuperview:(UIView *)superview
{
	UIScrollView *scrollView = (UIScrollView *)superview;
	while (scrollView != nil && ![scrollView isKindOfClass:[UIScrollView class]]) {
		scrollView = (UIScrollView *)scrollView.superview;
	}
	
	return scrollView;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	
	// we have an awkward situation here when the scrollView is deallocated before setting self.tnkRefreshControl to nil
	// our weak property is usually niled out by the time this is called, but odly self.superview is still correct
	// if we let the scrollView be autoreleased, it will be gone and deallocated by the time the autorelease pool is drained
	@autoreleasepool {
		UIScrollView *oldScrollView = [self _scrollViewForSuperview:self.superview];
		[oldScrollView removeObserver:self forKeyPath:@"contentOffset" context:TNKScrollViewContext];
		[self resetContentInset];
		[oldScrollView.panGestureRecognizer removeTarget:self action:@selector(panScrollView:)];
	}
	
	UIScrollView *scrollView = [self _scrollViewForSuperview:newSuperview];
	[scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:TNKScrollViewContext];
	[scrollView.panGestureRecognizer addTarget:self action:@selector(panScrollView:)];
	
	self.scrollView = scrollView;
	
	[self _layoutScrollView];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect indicatorFrame;
	indicatorFrame.size = _activityIndicator.intrinsicContentSize;
	indicatorFrame.origin = CGPointMake((self.bounds.size.width - indicatorFrame.size.width) / 2.0, (self.bounds.size.height - indicatorFrame.size.height) / 2.0);
	_activityIndicator.frame = indicatorFrame;
}

- (void)_layoutScrollView
{
	//    NSLog(@"self.scrollView.contentOffset.y: %f", self.scrollView.contentOffset.y);
	
	CGFloat frameY = 0.0;
	CGFloat lockedY = self.scrollView.contentOffset.y + self.scrollView.contentInset.top - self.addedContentInset.top;
	if (_state == TNKRefreshControlStateWaiting) {
		frameY = lockedY;
	} else {
		frameY = -TNKRefreshControlHeight;
		if (lockedY < -TNKRefreshControlHeight) {
			frameY = self.scrollView.contentOffset.y + self.scrollView.contentInset.top - self.addedContentInset.top;
		}
	}
	self.frame = CGRectMake(0.0, frameY,
							self.scrollView.bounds.size.width, TNKRefreshControlHeight);
	
	switch (_state) {
			case TNKRefreshControlStateWaiting: {
				if (!self.scrollView.dragging) {
					[self setAddedContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
				}
				
				CGFloat distance = -self.frame.origin.y - 10.0;
				CGFloat percent = 0.0;
				if (distance > 0.0) {
					if (NSClassFromString(@"UITraitCollection") && self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
						percent = pow(distance / 50.0, 2); // http://cl.ly/image/0O280G3C3H3M
					} else {
						percent = pow(2.0, distance / 60.0) - 1.0; // http://cl.ly/image/2r3y0h0Z0B01
					}
				}
				
				_activityIndicator.progress = percent;
				
				if (percent >= 1.0) {
					[self beginRefreshingVisibly:NO animated:NO];
					[self sendActionsForControlEvents:UIControlEventValueChanged];
				}
				
				break;
			} case TNKRefreshControlStateEnding: {
				if (self.scrollView.contentOffset.y >= -(self.scrollView.contentInset.top - self.addedContentInset.top)) {
					_state = TNKRefreshControlStateWaiting;
				}
				
				if (!self.scrollView.dragging) {
					[self setAddedContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
				}
				
				break;
			} case TNKRefreshControlStateRefreshing: {
				if (!self.scrollView.dragging) {
					[self setAddedContentInset:UIEdgeInsetsMake(self.bounds.size.height, 0.0, 0.0, 0.0)];
				}
				
				break;
			}
	}
}

- (void)beginRefreshing
{
	BOOL show = self.scrollView.contentOffset.y <= -self.scrollView.contentInset.top && !self.scrollView.dragging;
	
	[self beginRefreshingVisibly:show animated:show];
}

- (void)beginRefreshingVisibly:(BOOL)visibly animated:(BOOL)animated
{
	if (_state == TNKRefreshControlStateRefreshing) {
		return;
	}
	
	_state = TNKRefreshControlStateRefreshing;
	
	_activityIndicator.progress = 0.0;
	[_activityIndicator startAnimatingWithFadeInAnimation:animated completion:nil];
	if (visibly) {
		CGPoint contentOffset = self.scrollView.contentOffset;
		contentOffset.y = -self.scrollView.contentInset.top - self.frame.size.height;
		[self.scrollView setContentOffset:contentOffset animated:animated];
	}
}

- (void)endRefreshing
{
	if (_state != TNKRefreshControlStateRefreshing) {
		return;
	}
	_state = TNKRefreshControlStateEnding;
	
	BOOL animate = self.scrollView.contentOffset.y < -self.scrollView.contentInset.top;
	[_activityIndicator stopAnimatingWithFadeAwayAnimation:animate completion:^{
		// if we are at the very tippy top of the scroll view, this wouldn't get called in a way that would change the state back automatically
		[self _layoutScrollView];
	}];
	
	
	// using setContentOffset:animated: and reloadData don't play well with each other
	if (!self.scrollView.dragging) {
		[self _scrollToTopIfNeeded];
	}
}

- (void)_scrollToTopIfNeeded
{
	[UIView animateWithDuration:0.3 animations:^{
		CGFloat zeroOffset = -(self.scrollView.contentInset.top - self.addedContentInset.top);
		if (self.scrollView.contentOffset.y < zeroOffset) {
			CGPoint contentOffset = self.scrollView.contentOffset;
			contentOffset.y = zeroOffset;
			[self.scrollView setContentOffset:contentOffset animated:NO];
		}
	}];
}


#pragma mark - Actions

- (IBAction)panScrollView:(UIPanGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed) { // dragging ended
		[self _layoutScrollView];
		
		// because this may be called after the rubber band effect has been decided, we may need to do it ourselves
		dispatch_async(dispatch_get_main_queue(), ^{
			if (_state != TNKRefreshControlStateRefreshing && !self.scrollView.decelerating) {
				[self _scrollToTopIfNeeded];
			}
		});
	}
}

@end


@implementation UIScrollView (TNKRefreshControl)

- (void)tnk_setRefreshControl:(TNKRefreshControl *)refreshControl
{
	[self.tnk_refreshControl removeFromSuperview];
	
	objc_setAssociatedObject(self, @selector(tnk_refreshControl), refreshControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	[self insertSubview:refreshControl atIndex:0];
}

- (TNKRefreshControl *)tnk_refreshControl
{
	return objc_getAssociatedObject(self, @selector(tnk_refreshControl));
}

@end


@implementation UITableView (TNKRefreshControl)

- (void)tnk_setRefreshControl:(TNKRefreshControl *)refreshControl
{
	if (self.tnk_refreshControl != refreshControl) {
		[super tnk_setRefreshControl:refreshControl];
		
		if (self.backgroundView != nil) {
			[self insertSubview:refreshControl aboveSubview:self.backgroundView];
		}
	}
}

@end


@implementation UICollectionView (TNKRefreshControl)

- (void)tnk_setRefreshControl:(TNKRefreshControl *)refreshControl
{
	[super tnk_setRefreshControl:refreshControl];
	
	if (self.backgroundView != nil) {
		[self insertSubview:refreshControl aboveSubview:self.backgroundView];
	}
}

@end
