/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef enum : NSUInteger {
    eEMConnectionConnected,   //连接成功
    eEMConnectionDisconnected,//未连接
} EMConnectionState;

@class EMSearchBar;
@interface ConversationViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet EMSearchBar *searchBar;

- (void)refreshDataSource;

- (void)networkChanged:(EMConnectionState)connectionState;

@end
