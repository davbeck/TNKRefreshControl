# TNKRefreshControl

[![Carthage compatible](https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/TNKRefreshControl.svg?style=flat)](http://cocoadocs.org/docsets/TNKRefreshControl)
[![License](https://img.shields.io/cocoapods/l/TNKRefreshControl.svg?style=flat)](http://cocoadocs.org/docsets/TNKRefreshControl)
[![Platform](https://img.shields.io/cocoapods/p/TNKRefreshControl.svg?style=flat)](http://cocoadocs.org/docsets/TNKRefreshControl)

TNKRefreshControl is a replacement for UIRefreshControl that can be used with any UIScrollView
and uses a more modern look.

[![Screenshot](http://zippy.gfycat.com/BlackandwhiteUnevenIndianspinyloach.gif)](http://cl.ly/0R1n0f2D3S3Z)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

See the [documentation](http://cocoadocs.org/docsets/TNKRefreshControl/) for more details.

Instead of setting refreshControl on a UITableViewController, you create and set a TNKRefreshControl on any UIScrollView or UIScrollView subclass like UITableView.

```objc
self.tableView.refreshControl = [TNKRefreshControl new];
[self.tableView.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
```

From there, you can programatically activate the refresh control programatically with `beginRefreshing`. When you have finished loading content, make sure to call `endRefreshing`.

```objc
- (IBAction)refresh:(id)sender {
    [self.tableView.refreshControl beginRefreshing];
    
    [_objectSource loadNewObjects:^(NSArray *newDates) {
        [self.tableView.refreshControl endRefreshing];
        
        [self.tableView reloadData];
    }];
}
```

## Installation

### Cocoapods

TNKRefreshControl is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TNKRefreshControl", "~> 0.3"

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate TNKRefreshControl into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "davbeck/TNKRefreshControl" ~> 0.3
```

Run `carthage` to build the framework and drag the built `TNKRefreshControl.framework` into your Xcode project.

## UITableView Floating Headers and updating from 0.6.0

`UITableView` has a nasty habit of placing it's section headers below `contentInset`. This causes floating section headers to appear lower than they should when the refresh control is active. Previously, TNKRefreshControl would use method swizzling to adjust the headers. However, for many user's of the framework, they are not using the refresh control with floating headers, but `layoutSubviews` gets swizzled on `UITableView` for everyone that includes the framework in their project.

If you still need the fix for floating headers, you can include this code in your project, along with [JRSwizzle](https://github.com/rentzsch/jrswizzle). Further, you must use `-[UITableView dequeueReusableHeaderFooterViewWithIdentifier:]` (or the default header views) for this to work. See [rdar://19489536](http://openradar.appspot.com/radar?id=6142546598166528) for more info.

```objc
@implementation UITableView (TNKRefreshControl)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error;
        BOOL result = [[self class] jr_swizzleMethod:@selector(layoutSubviews) withMethod:@selector(TNK_layoutSubviews) error:&error];
        if (!result || error) {
            NSLog(@"Can't swizzle methods - %@", [error description]);
        }
    });
}

- (void)TNK_layoutSubviews
{
    [self TNK_layoutSubviews]; // this will call layoutSubviews implementation, because we have exchanged them.
    
    
    // UITableView has a nasty habbit of placing it's section headers below contentInset
    // We aren't changing that behavior, just adjusting for the inset that we added
    
    if (self.refreshControl.addedContentInset.top != 0.0) {
        //http://b2cloud.com.au/tutorial/uitableview-section-header-positions/
        const NSUInteger numberOfSections = self.numberOfSections;
        const UIEdgeInsets contentInset = self.contentInset;
        const CGPoint contentOffset = self.contentOffset;
        
        const CGFloat sectionViewMinimumOriginY = contentOffset.y + contentInset.top - self.refreshControl.addedContentInset.top;
        
        //	Layout each header view
        for(NSUInteger section = 0; section < numberOfSections; section++)
        {
            UIView* sectionView = [self headerViewForSection:section];
            
            if(sectionView == nil)
                continue;
            
            const CGRect sectionFrame = [self rectForSection:section];
            
            CGRect sectionViewFrame = sectionView.frame;
            
            sectionViewFrame.origin.y = ((sectionFrame.origin.y < sectionViewMinimumOriginY) ? sectionViewMinimumOriginY : sectionFrame.origin.y);
            
            //	If it's not last section, manually 'stick' it to the below section if needed
            if(section < numberOfSections - 1)
            {
                const CGRect nextSectionFrame = [self rectForSection:section + 1];
                
                if(CGRectGetMaxY(sectionViewFrame) > CGRectGetMinY(nextSectionFrame))
                    sectionViewFrame.origin.y = nextSectionFrame.origin.y - sectionViewFrame.size.height;
            }
            
            [sectionView setFrame:sectionViewFrame];
        }
    }
}

@end
```

## Author

David Beck, code@thinkultimate.com

## License

TNKRefreshControl is available under the MIT license. See the LICENSE file for more info.

