//
//  ContactsViewController.h
//  XMPPBaseProject
//
//  Created by hc on 14-6-27.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "BaseViewController.h"

@class EMSearchBar;
@interface ContactsViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet EMSearchBar *searchBar;

//好友请求变化时，更新好友请求未处理的个数
- (void)reloadApplyView;

//群组变化时，更新群组页面
- (void)reloadGroupView;

//好友个数变化时，重新获取数据
- (void)reloadDataSource;

//添加好友的操作被触发
- (void)addFriendAction;

@end
