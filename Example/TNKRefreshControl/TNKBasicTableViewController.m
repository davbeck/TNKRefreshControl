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
    TNKDateSource *_objectSource;
}

@end

@implementation TNKBasicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.refreshControl = [TNKRefreshControl new];
    [self.tableView.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    _objectSource = [TNKDateSource new];
    _objectSource.objects = @[[NSDate date]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView.refreshControl beginRefreshing];
    
    [self refresh:nil];
}


#pragma mark - Actions

- (IBAction)refresh:(id)sender {
    [self.tableView.refreshControl beginRefreshing];
    
    [_objectSource loadNewObjects:^(NSArray *newDates) {
        [self.tableView.refreshControl endRefreshing];
        
        [self.tableView reloadData];
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _objectSource.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DateCell" forIndexPath:indexPath];
    
    NSDate *date = _objectSource.objects[indexPath.row];
    cell.textLabel.text = date.description;
    
    return cell;
}

@end
