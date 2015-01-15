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
    TNKDateSource *_objectSource;
}

@end

@implementation TNKUIRefreshControlTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing"];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    _objectSource = [TNKDateSource new];
    _objectSource.objects = @[[NSDate date]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refresh:nil];
}


#pragma mark - Actions

- (IBAction)refresh:(id)sender {
    [self.refreshControl beginRefreshing];
    
    [_objectSource loadNewObjects:^(NSArray *newDates) {
        [self.refreshControl endRefreshing];
        
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
