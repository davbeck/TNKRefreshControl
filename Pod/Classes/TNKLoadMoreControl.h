//
//  TNKLoadMoreControl.h
//  Pods
//
//  Created by David Beck on 11/10/15.
//
//

#import <UIKit/UIKit.h>

@class TNKActivityIndicatorView;


@interface TNKLoadMoreControl : UIControl

/** Check if the view is within it's scroll view's bounds
 
 Check this property after you finish loading content to see if you should continue loading more content.
 */
@property (nonatomic, readonly) BOOL visible;

/** The associated scroll view
 
 A weak reference to the scroll view that the control has been added to. This is computed dynamically
 based on the controls superview.
 */
@property (nonatomic, readonly, weak, nullable) UIScrollView *scrollView;

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


@interface UIScrollView (TNKLoadMoreControl)

/** The view used to indicate that more content still need to be loaded.
 
 The default value of this property is nil.
 
 Assigning a load more view to this property adds the control to the scroll view. You do not need to set the frame before associating it with the scroll view. The scroll view updates the control’s height and width and sets its position appropriately.
 
 When the user initiates a refresh operation, the control generates a UIControlEventValueChanged event. You must associate a target and action method with this event and use them to refresh your table’s contents.
 */
@property (nonatomic, strong, nullable) TNKLoadMoreControl *loadMoreControl;

@end
