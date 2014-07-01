//
//  ChatBaseCell.m
//  XMPPBaseProject
//
//  Created by hc on 14-7-1.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "ChatBaseCell.h"

@implementation ChatBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
