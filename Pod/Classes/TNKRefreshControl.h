//
//  TNKRefreshControl.h
//  Pods
//
//  Created by David Beck on 1/13/15.
//
//

#import <UIKit/UIKit.h>

@interface TNKRefreshControl : UIControl

/** Tells the control that a refresh operation was started programmatically.
 
 Call this method when an external event source triggers a programmatic refresh of your table. For example, if you use an NSTimer object to refresh the contents of the table view periodically, you would call this method as part of your timer handler. This method updates the state of the refresh control to reflect the in-progress refresh operation. When the refresh operation ends, be sure to call the endRefreshing method to return the control to its default state.
 
 It is safe to call this even when a refresh was triggered by the user.
 */
- (void)beginRefreshing;

/** Tells the control that a refresh operation has ended.
 
 Call this method at the end of any refresh operation (whether it was initiated programmatically or by the user) to return the refresh control to its default state. If the refresh control is at least partially visible, calling this method also hides it.
 */
- (void)endRefreshing;

/** A Boolean value indicating whether a refresh operation has been triggered and is in progress. (read-only)
 */
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

@end


@interface UIScrollView (TNKRefreshControl)

/** The refresh control used to trigger and display refresh status.
 
 The default value of this property is nil.
 
 Assigning a refresh control to this property adds the control to the scroll view. You do not need to set the frame of the refresh control before associating it with the view controller. The view controller updates the control’s height and width and sets its position appropriately.
 
 When the user initiates a refresh operation, the control generates a UIControlEventValueChanged event. You must associate a target and action method with this event and use them to refresh your table’s contents.
 */
@property (nonatomic, strong) TNKRefreshControl *refreshControl;

@end
