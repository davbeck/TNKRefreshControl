# TNKRefreshControl

[![CI Status](http://img.shields.io/travis/David Beck/TNKRefreshControl.svg?style=flat)](https://travis-ci.org/David Beck/TNKRefreshControl)
[![Version](https://img.shields.io/cocoapods/v/TNKRefreshControl.svg?style=flat)](http://cocoadocs.org/docsets/TNKRefreshControl)
[![License](https://img.shields.io/cocoapods/l/TNKRefreshControl.svg?style=flat)](http://cocoadocs.org/docsets/TNKRefreshControl)
[![Platform](https://img.shields.io/cocoapods/p/TNKRefreshControl.svg?style=flat)](http://cocoadocs.org/docsets/TNKRefreshControl)

TNKRefreshControl is a replacement for UIRefreshControl that can be used with any UIScrollView
and uses a more modern look.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

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

TNKRefreshControl is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TNKRefreshControl", "~> 0.1"

## Author

David Beck, code@thinkultimate.com

## License

TNKRefreshControl is available under the MIT license. See the LICENSE file for more info.

