//
//  TNKLoadMoreControl.m
//  Pods
//
//  Created by David Beck on 11/10/15.
//
//

#import "TNKLoadMoreControl.h"

#import <objc/runtime.h>

#import "TNKActivityIndicatorView.h"


static void *TNKScrollViewContext = &TNKScrollViewContext;


@interface TNKLoadMoreControl ()
{
	TNKActivityIndicatorView *_activityIndicatorView;
	BOOL _ignoreOffsetChanged;// sometimes we aren't done yet
}

@property (nonatomic) UIEdgeInsets addedContentInset;

@end

@implementation TNKLoadMoreControl

- (BOOL)visible {
	return CGRectIntersectsRect(self.scrollView.bounds, self.frame);
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

- (void)_init
{
	CGRect frame = self.frame;
	frame.size.height = self.intrinsicContentSize.height;
	self.frame = frame;
	
	_activityIndicatorView = [[TNKActivityIndicatorView alloc] init];
	_activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:_activityIndicatorView];
	
	[NSLayoutConstraint activateConstraints:@[
											  [_activityIndicatorView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
											  [_activityIndicatorView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
											  [_activityIndicatorView.topAnchor constraintGreaterThanOrEqualToAnchor:self.layoutMarginsGuide.topAnchor],
											  [_activityIndicatorView.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
											  [_activityIndicatorView.widthAnchor constraintLessThanOrEqualToAnchor:_activityIndicatorView.heightAnchor],
											  ]];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self _init];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self _init];
	}
	return self;
}


- (CGSize)intrinsicContentSize {
	return CGSizeMake(UIViewNoIntrinsicMetric, 44);
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.height = 44;
	return size;
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
	
	// we have an awkward situation here when the scrollView is deallocated before setting self.refreshControl to nil
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
	
	_scrollView = scrollView;
	
	[self _layoutScrollView];
}

- (void)_layoutScrollView
{
	//    NSLog(@"self.scrollView.contentOffset.y: %f", self.scrollView.contentOffset.y);
	
	self.frame = CGRectMake(0.0, self.scrollView.contentSize.height,
							self.scrollView.bounds.size.width, self.intrinsicContentSize.height);
	
	if (!self.scrollView.dragging) {
		if (self.enabled) {
			[self setAddedContentInset:UIEdgeInsetsMake(0, 0, self.bounds.size.height, 0)];
		} else {
			[self setAddedContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
		}
	}
	
	if (self.enabled) {
		if (self.visible) {
			[_activityIndicatorView startAnimatingWithFadeInAnimation:NO completion:nil];
			[self sendActionsForControlEvents:UIControlEventValueChanged];
		} else {
			[_activityIndicatorView stopAnimatingWithFadeAwayAnimation:NO completion:nil];
		}
	}
}

- (void)setEnabled:(BOOL)enabled {
	BOOL changed = self.enabled != enabled;
	
	[super setEnabled:enabled];
	
	if (changed) {
		if (enabled) {
			[self _layoutScrollView];
		} else {
			[_activityIndicatorView stopAnimatingWithFadeAwayAnimation:YES completion:nil];
			[self _layoutScrollView];
			[self _scrollToBottomIfNeeded];
		}
	}
}

- (void)_scrollToBottomIfNeeded
{
	if (!self.enabled) {
		[UIView animateWithDuration:0.3 animations:^{
			CGFloat zeroOffset = self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.scrollView.contentInset.bottom;
			zeroOffset = MAX(zeroOffset, 0);
			if (self.scrollView.contentOffset.y > zeroOffset) {
				CGPoint contentOffset = self.scrollView.contentOffset;
				contentOffset.y = zeroOffset;
				[self.scrollView setContentOffset:contentOffset animated:NO];
			}
		}];
	}
}


#pragma mark - Actions

- (IBAction)panScrollView:(UIPanGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed) { // dragging ended
		[self _layoutScrollView];
		
		// because this may be called after the rubber band effect has been decided, we may need to do it ourselves
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!self.enabled && !self.scrollView.decelerating) {
				[self _scrollToBottomIfNeeded];
			}
		});
	}
}

@end


@implementation UIScrollView (TNKRefreshControl)

- (void)setLoadMoreControl:(TNKLoadMoreControl *)loadMoreControl
{
	[self.loadMoreControl removeFromSuperview];
	
	objc_setAssociatedObject(self, @selector(loadMoreControl), loadMoreControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	[self insertSubview:loadMoreControl atIndex:0];
}

- (TNKLoadMoreControl *)loadMoreControl
{
	return objc_getAssociatedObject(self, @selector(loadMoreControl));
}

@end


@implementation UITableView (TNKRefreshControl)

- (void)setLoadMoreControl:(TNKLoadMoreControl *)loadMoreControl
{
	if (self.loadMoreControl != loadMoreControl) {
		[super setLoadMoreControl:loadMoreControl];
		
		if (self.backgroundView != nil) {
			[self insertSubview:loadMoreControl aboveSubview:self.backgroundView];
		}
	}
}

@end


@implementation UICollectionView (TNKRefreshControl)

- (void)setLoadMoreControl:(TNKLoadMoreControl *)loadMoreControl
{
	[super setLoadMoreControl:loadMoreControl];
	
	if (self.backgroundView != nil) {
		[self insertSubview:loadMoreControl aboveSubview:self.backgroundView];
	}
}

@end
