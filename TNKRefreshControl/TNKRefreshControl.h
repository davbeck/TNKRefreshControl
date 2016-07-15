//
//  TNKRefreshControl.h
//  Pods
//
//  Created by David Beck on 1/13/15.
//
//

#import <UIKit/UIKit.h>

//! Project version number for TNKRefreshControl.
FOUNDATION_EXPORT double TNKRefreshControlVersionNumber;

//! Project version string for TNKRefreshControl.
FOUNDATION_EXPORT const unsigned char TNKRefreshControlVersionString[];

#import <TNKRefreshControl/TNKActivityIndicatorView.h>
#import <TNKRefreshControl/TNKLoadMoreControl.h>


@interface TNKRefreshControl : UIControl

/** Tells the control that a refresh operation was started programmatically.
 
 Call this method when an external event source triggers a programmatic refresh of your table. For example, if you use an NSTimer object to refresh the contents of the table view periodically, you would call this method as part of your timer handler. This method updates the state of the refresh control to reflect the in-progress refresh operation. When the refresh operation ends, be sure to call the endRefreshing method to return the control to its default state.
 
 Internally, this method calls `beginRefreshingVisibly:animated:` with visibly set to YES when the scrollView is at the top and animated YES.
 
 It is safe to call this even when a refresh was triggered by the user.
 */
- (void)beginRefreshing;

/** Tells the control that a refresh operation was started programmatically.
 
 Similar to beginRefreshing, this method allows you to begin refreshing programatically. In addition, it automatically scrolls the control into view when visibly is YES.
 
 @param visibly Whether to scroll the control into view.
 @param animated If visibly is YES, controls scrolling animation.
 */
- (void)beginRefreshingVisibly:(BOOL)visibly animated:(BOOL)animated;

/** Tells the control that a refresh operation has ended.
 
 Call this method at the end of any refresh operation (whether it was initiated programmatically or by the user) to return the refresh control to its default state. If the refresh control is at least partially visible, calling this method also hides it.
 */
- (void)endRefreshing;

/** A Boolean value indicating whether a refresh operation has been triggered and is in progress. (read-only)
 */
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

/** The associated scroll view
 
 A weak reference to the scroll view that the control has been added to. This is computed dynamically
 based on the controls superview.
 */
@property (nonatomic, weak) UIScrollView *scrollView;

/** The amount of insets added to the scrollView.
 
 The control will do it's best to maintain a delta of what it has added to the scorllView's contentInsets. That way, as other code adds and removes insets, we keep track of only what we are responsible fore. Subclasses may override this property to customize how the inset is added.
 */
@property (nonatomic) UIEdgeInsets addedContentInset;

/** Restore the scrollView's content inset
 
 This method will remove any added content inset, reseting the value to what it was before we changed it. This method should be considered internal and only used by subclasses that change the inset behavior.
 
 @see addedInsets
 */
- (void)resetContentInset;

@end


@interface UIScrollView (TNKRefreshControl)

/** The refresh control used to trigger and display refresh status.
 
 The default value of this property is nil.
 
 Assigning a refresh control to this property adds the control to the scroll view. You do not need to set the frame of the refresh control before associating it with the view controller. The view controller updates the control’s height and width and sets its position appropriately.
 
 When the user initiates a refresh operation, the control generates a UIControlEventValueChanged event. You must associate a target and action method with this event and use them to refresh your table’s contents.
 */
@property (nonatomic, strong, setter=tnk_setRefreshControl:) TNKRefreshControl *tnk_refreshControl;

@end
