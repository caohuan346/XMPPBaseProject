//
//  ChatMsgCell.h
//  XMPPBaseProject
//
//  Created by hc on 14-6-1.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMsgCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImgV;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

@end
