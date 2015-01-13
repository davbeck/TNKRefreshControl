# TNKRefreshControl

[![CI Status](http://img.shields.io/travis/David Beck/TNKRefreshControl.svg?style=flat)](https://travis-ci.org/David Beck/TNKRefreshControl)
[![Version](https://img.shields.io/cocoapods/v/TNKRefreshControl.svg?style=flat)](http://cocoadocs.org/docsets/TNKRefreshControl)
[![License](https://img.shields.io/cocoapods/l/TNKRefreshControl.svg?style=flat)](http://cocoadocs.org/docsets/TNKRefreshControl)
[![Platform](https://img.shields.io/cocoapods/p/TNKRefreshControl.svg?style=flat)](http://cocoadocs.org/docsets/TNKRefreshControl)

## Limitations of UIRefreshControl

### `attributedTitle` Offset

![attributedTitle offset](http://f.cl.ly/items/1t460h0Y322v3q3c093G/iOS%20Simulator%20Screen%20Shot%20Jan%2013,%202015,%2011.35.55%20AM.png)

When `attributedTitle` is set, the offset for the table view is too large. This is fixed if you call `beginRefreshing` from `viewWillAppear:`.


## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

TNKRefreshControl is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TNKRefreshControl"

## Author

David Beck, code@thinkultimate.com

## License

TNKRefreshControl is available under the MIT license. See the LICENSE file for more info.

