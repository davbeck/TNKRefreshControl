//
//  TNKRefreshControl.h
//  Pods
//
//  Created by David Beck on 1/13/15.
//
//

#import <UIKit/UIKit.h>

@interface TNKRefreshControl : UIControl

- (void)beginRefreshing;
- (void)endRefreshing;

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

@end


@interface UIScrollView (TNKRefreshControl)

@property (nonatomic, strong) TNKRefreshControl *refreshControl;

@end
