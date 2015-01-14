//
//  TNKUIRefreshControlTableViewController.m
//  TNKRefreshControl
//
//  Created by David Beck on 1/13/15.
//  Copyright (c) 2015 David Beck. All rights reserved.
//

#import "TNKUIRefreshControlTableViewController.h"

#import "TNKRefreshControl-Swift.h"


@interface TNKUIRefreshControlTableViewController ()
{
    TNKDateSource *_dateSource;
}

@end

@implementation TNKUIRefreshControlTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing"];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    _dateSource = [TNKDateSource new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refresh:nil];
}


#pragma mark - Actions

- (IBAction)refresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    
    [_dateSource refresh:^(NSArray *dates) {
        [self.tableView reloadData];
        
        [self.refreshControl endRefreshing];
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
