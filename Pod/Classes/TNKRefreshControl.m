//
//  TNKRefreshControl.m
//  Pods
//
//  Created by David Beck on 1/13/15.
//
//

#import "TNKRefreshControl.h"

#import <objc/runtime.h>

#import "TCActivityIndicatorView.h"


#define TNKRefreshControlHeight 44.0

static void *TNKScrollViewContext = &TNKScrollViewContext;


typedef NS_ENUM(NSUInteger, TNKRefreshControlState) {
    TNKRefreshControlStateWaiting,
    TNKRefreshControlStateRefreshing,
    TNKRefreshControlStateEnding,
};


@interface TNKRefreshControl ()
{
    TCActivityIndicatorView *_activityIndicator;
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

- (void)setAddedContentInset:(UIEdgeInsets)addedContentInset
{
    [self setAddedContentInset:addedContentInset animated:NO];
}

- (void)setAddedContentInset:(UIEdgeInsets)addedInsets animated:(BOOL)animated
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
        
        if (animated) {
            [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:0 animations:^{
                self.scrollView.contentInset = contentInset;
                self.scrollView.contentOffset = contentOffset;
            } completion:nil];
        } else {
            self.scrollView.contentInset = contentInset;
            self.scrollView.contentOffset = contentOffset;
        }
    }
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset" context:TNKScrollViewContext];
    
    _scrollView = scrollView;
    [self _layoutScrollView];
    
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:TNKScrollViewContext];
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
        
        _activityIndicator = [TCActivityIndicatorView new];
        [self addSubview:_activityIndicator];
//        _activityIndicator.backgroundColor = [UIColor greenColor];
    }
    
    return self;
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
    
    self.frame = CGRectMake(0.0, self.scrollView.contentOffset.y + self.scrollView.contentInset.top - self.addedContentInset.top,
                            self.scrollView.bounds.size.width, TNKRefreshControlHeight);
    
    switch (_state) {
        case TNKRefreshControlStateWaiting: {
            CGFloat percent = MAX(MIN(-self.frame.origin.y - 10.0, 75.0), 0.0) / 75.0;
            
            _activityIndicator.progress = percent;
            
            if (-self.frame.origin.y > 100.0) {
                [self beginRefreshing];
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
    _state = TNKRefreshControlStateRefreshing;
    
    _activityIndicator.progress = 0.0;
    [_activityIndicator startAnimating];
    
    if (self.scrollView.dragging) {
        __weak __typeof(self)self_weak = self;
        _draggingEndedAction = ^{
            self_weak.addedContentInset = UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0);
        };
    } else {
        self.addedContentInset = UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0);
    }
}

- (void)endRefreshing
{
    [_activityIndicator stopAnimatingWithFadeAwayAnimation:YES completion:^{
        _state = TNKRefreshControlStateEnding;
    }];
    
    _draggingEndedAction = nil;
    [self setAddedContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) animated:YES];
    if (self.scrollView.contentOffset.y < -self.scrollView.contentInset.top && !self.scrollView.dragging) {
        CGPoint contentOffset = self.scrollView.contentOffset;
        contentOffset.y = -self.scrollView.contentInset.top;
        [self.scrollView setContentOffset:contentOffset animated:YES];
    }
}

@end


@implementation UIScrollView (TNKRefreshControl)

- (void)setRefreshControl:(TNKRefreshControl *)refreshControl
{
    refreshControl.scrollView = self;
    
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
