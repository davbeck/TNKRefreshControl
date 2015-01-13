//
//  TNKBasicTableViewController.m
//  TNKRefreshControl
//
//  Created by David Beck on 1/13/15.
//  Copyright (c) 2015 David Beck. All rights reserved.
//

#import "TNKBasicTableViewController.h"

#import <TNKRefreshControl/TNKRefreshControl.h>

#import "TNKRefreshControl-Swift.h"


@interface TNKBasicTableViewController ()
{
    TNKDateSource *_dateSource;
}

@end

@implementation TNKBasicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.refreshControl = [TNKRefreshControl new];
    [self.tableView.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    _dateSource = [TNKDateSource new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refresh:nil];
}


#pragma mark - Actions

- (IBAction)refresh:(id)sender {
    [self.tableView.refreshControl beginRefreshing];
    
    [_dateSource refresh:^(NSArray *dates) {
        [self.tableView.refreshControl endRefreshing];
        
        [self.tableView reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self.tableView reloadData];
        });
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dateSource.dates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DateCell" forIndexPath:indexPath];
    
    NSDate *date = _dateSource.dates[indexPath.row];
    cell.textLabel.text = date.description;
    
    return cell;
}

@end
