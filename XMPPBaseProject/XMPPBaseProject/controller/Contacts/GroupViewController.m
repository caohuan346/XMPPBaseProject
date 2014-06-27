//
//  GroupViewController.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "GroupViewController.h"
#import "ChatViewController.h"
#import "MultiUserChatViewCtl.h"


@interface GroupViewController (){
    NSMutableArray *groups;
}

@end

@implementation GroupViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    groups = [NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated{
//    [self initRoom];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
//    return groups.count;
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = @"room1@conference.chtekimacbook-pro.local";
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MultiUserChatViewCtl *multiChatCtl = [[MultiUserChatViewCtl alloc] init];
    multiChatCtl.roomName = @"room1@conference.chtekimacbook-pro.local";
    [self.navigationController pushViewController:multiChatCtl animated:YES];
}
@end
