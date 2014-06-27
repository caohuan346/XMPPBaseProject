//
//  BaseTableViewCell.h
//  XMPPBaseProject
//
//  Created by hc on 14-6-27.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewCell : UITableViewCell

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) UIView *bottomLineView;

@end
