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
    void(^_draggingEndedAction)();
    TNKRefreshControlState _state;
}

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) UIEdgeInsets addedContentInset;

@end

@implementation TNKRefreshControl

- (BOOL)isRefreshing
{
    return _state == TNKRefreshControlStateRefreshing;
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
        
        self.scrollView.contentInset = contentInset;
        self.scrollView.contentOffset = contentOffset;
    }
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    self.addedContentInset = UIEdgeInsetsZero;
    
    _scrollView = scrollView;
    [self _layoutScrollView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == TNKScrollViewContext) {
        [self _layoutScrollView];
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
    
    // our weak property is usually niled out by the time this is called, but odly self.superview is still correct
    UIScrollView *oldScrollView = [self _scrollViewForSuperview:self.superview];
    [oldScrollView removeObserver:self forKeyPath:@"contentOffset" context:TNKScrollViewContext];
    
    UIScrollView *scrollView = [self _scrollViewForSuperview:newSuperview];
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:TNKScrollViewContext];
    
    self.scrollView = scrollView;
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
    
    if (!self.scrollView.dragging && _draggingEndedAction != nil) {
        void(^draggingEndedAction)() = _draggingEndedAction;
        _draggingEndedAction = nil;// we don't want to fire this from within the block
        
        draggingEndedAction();
    }
    
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
            CGFloat distance = -self.frame.origin.y - 10.0;
            CGFloat percent = 0.0;
            if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
                percent = pow(distance / 50.0, 2); // http://cl.ly/image/0O280G3C3H3M
            } else {
                percent = pow(2.0, distance / 60.0) - 1.0; // http://cl.ly/image/2r3y0h0Z0B01
            }
            
            _activityIndicator.progress = percent;
            
            if (percent >= 1.0) {
                [self beginRefreshingVisibly:NO animated:NO];
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            
            break;
        } case TNKRefreshControlStateEnding: {
            if (self.scrollView.contentOffset.y >= -self.scrollView.contentInset.top) {
                _state = TNKRefreshControlStateWaiting;
            }
            
            break;
        } case TNKRefreshControlStateRefreshing: {
            
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
    
    if (self.scrollView.dragging) {
        __weak __typeof(self)self_weak = self;
        _draggingEndedAction = ^{
            self_weak.addedContentInset = UIEdgeInsetsMake(self_weak.frame.size.height, 0.0, 0.0, 0.0);
        };
    } else {
        self.addedContentInset = UIEdgeInsetsMake(self.frame.size.height, 0.0, 0.0, 0.0);
    }
}

- (void)endRefreshing
{
    if (_state != TNKRefreshControlStateRefreshing) {
        return;
    }
    
    [_activityIndicator stopAnimatingWithFadeAwayAnimation:YES completion:^{
        _state = TNKRefreshControlStateEnding;
        
        // if we are at the very tippy top of the scroll view, this wouldn't get called in a way that would change the state back automatically
        [self _layoutScrollView];
    }];
    
    if (self.scrollView.dragging) {
        __weak __typeof(self)self_weak = self;
        _draggingEndedAction = ^{
            [self_weak setAddedContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        };
    } else {
        _draggingEndedAction = nil;
        
        // using setContentOffset:animated: and reloadData don't play well with each other
        [UIView animateWithDuration:0.3 animations:^{
            [self setAddedContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            if (self.scrollView.contentOffset.y < -self.scrollView.contentInset.top && !self.scrollView.dragging) {
                CGPoint contentOffset = self.scrollView.contentOffset;
                contentOffset.y = -self.scrollView.contentInset.top;
                [self.scrollView setContentOffset:contentOffset animated:NO];
            }
        }];
    }
}

@end


@implementation UIScrollView (TNKRefreshControl)

- (void)setRefreshControl:(TNKRefreshControl *)refreshControl
{
    [self.refreshControl removeFromSuperview];
    
    objc_setAssociatedObject(self, @selector(refreshControl), refreshControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self insertSubview:refreshControl atIndex:0];
}

- (TNKRefreshControl *)refreshControl
{
    return objc_getAssociatedObject(self, @selector(refreshControl));
}

@end


@implementation UITableView (TNKRefreshControl)

- (void)setRefreshControl:(TNKRefreshControl *)refreshControl
{
    [super setRefreshControl:refreshControl];
    
    if (self.backgroundView != nil) {
        [self insertSubview:refreshControl aboveSubview:self.backgroundView];
    }
}

@end


@implementation UICollectionView (TNKRefreshControl)

- (void)setRefreshControl:(TNKRefreshControl *)refreshControl
{
    [super setRefreshControl:refreshControl];
    
    if (self.backgroundView != nil) {
        [self insertSubview:refreshControl aboveSubview:self.backgroundView];
    }
}

@end
