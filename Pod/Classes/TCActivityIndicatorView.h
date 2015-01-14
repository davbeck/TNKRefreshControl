//
//  TCActivityIndicatorView.h
//  Pods
//
//  Created by David Beck on 1/13/15.
//
//

#import <UIKit/UIKit.h>

@interface TCActivityIndicatorView : UIView

@property (nonatomic) CGFloat progress;

- (void)startAnimating;
- (void)stopAnimating;
@property (nonatomic, readonly, getter=isAnimating) BOOL animating;

@end
