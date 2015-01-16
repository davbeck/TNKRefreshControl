# TNKRefreshControl

[![Version](https://img.shields.io/cocoapods/v/TNKRefreshControl.svg?style=flat)](http://cocoadocs.org/docsets/TNKRefreshControl)
[![License](https://img.shields.io/cocoapods/l/TNKRefreshControl.svg?style=flat)](http://cocoadocs.org/docsets/TNKRefreshControl)
[![Platform](https://img.shields.io/cocoapods/p/TNKRefreshControl.svg?style=flat)](http://cocoadocs.org/docsets/TNKRefreshControl)

TNKRefreshControl is a replacement for UIRefreshControl that can be used with any UIScrollView
and uses a more modern look.

[![Screenshot](http://zippy.gfycat.com/BlackandwhiteUnevenIndianspinyloach.gif)](http://cl.ly/0R1n0f2D3S3Z)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

See the [documentation](http://cocoadocs.org/docsets/TNKRefreshController/) for more details.

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

> **Note:** There is an issue with UITableView, section headers and indexes where they will be
> placed below any contentInset. TNKRefreshControl swizzle's `-[UITableView layoutSubviews]` to
> correct the behavior for section headers but not section indexes. Further, you must use 
> `-[UITableView dequeueReusableHeaderFooterViewWithIdentifier:]` (or the default header views)
> for this to work.
> See [rdar://19489536](http://openradar.appspot.com/radar?id=6142546598166528) for more info.

## Installation

TNKRefreshControl is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TNKRefreshControl", "~> 0.1"

## Author

David Beck, code@thinkultimate.com

## License

TNKRefreshControl is available under the MIT license. See the LICENSE file for more info.

