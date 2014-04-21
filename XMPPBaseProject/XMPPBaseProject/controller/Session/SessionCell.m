//
//  SessionCell.m
//  BaseProject
//
//  Created by caohuan on 13-12-20.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "SessionCell.h"

@implementation SessionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {

}
@end
