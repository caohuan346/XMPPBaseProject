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


#import "ConversationCell.h"
#import "Conversation.h"
#import "NSDate+Category.h"
#import "XMPPHelper.h"
#import "AppDelegate.h"
#import "JSBadgeView.h"

@interface ConversationCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation ConversationCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        /*
        // Initialization code
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 7, 80, 16)];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_timeLabel];
        
        _unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 20, 20)];
        _unreadLabel.backgroundColor = [UIColor redColor];
        _unreadLabel.textColor = [UIColor whiteColor];
        
        _unreadLabel.textAlignment = NSTextAlignmentCenter;
        _unreadLabel.font = [UIFont systemFontOfSize:11];
        _unreadLabel.layer.cornerRadius = 10;
        _unreadLabel.clipsToBounds = YES;
        [self.contentView addSubview:_unreadLabel];
        
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 30, 175, 20)];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = [UIFont systemFontOfSize:15];
        _detailLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_detailLabel];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 1)];
        
        //_lineView.backgroundColor = RGBACOLOR(207, 210, 213, 0.7);
        
        [self.contentView addSubview:_lineView];
         
         */
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
    /*
    if (![_unreadLabel isHidden]) {
        _unreadLabel.backgroundColor = [UIColor redColor];
    }
     */
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    /*
    if (![_unreadLabel isHidden]) {
        _unreadLabel.backgroundColor = [UIColor redColor];
    }
     */
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.nameLabel.text = self.conversation.senderId;
    self.timeLabel.text = [self.conversation.time minuteDescription];
    self.contentLabel.text = self.conversation.msgContent;
    
    JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:self.iconImageView alignment:JSBadgeViewAlignmentTopRight];
    badgeView.badgeText = [NSString stringWithFormat:@"%d", self.conversation.unreadCount];
    
    self.iconImageView.alpha = 1.0f;
    ConversationType conversationType = self.conversation.type;
    
    UIImage *iconImage;
    //个人
    if (conversationType == ConversationTypePersonalChat) {
        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",self.conversation.senderId,SharedAppDelegate.globals.xmppServerDomain]];
        
        self.nameLabel.text = jid.user;
        
        iconImage = [XMPPHelper xmppUserPhotoForJID:jid];
        
        NSMutableDictionary *onlineUsersDic = SharedAppDelegate.xmppServer.onlineDict;
        if (![onlineUsersDic objectForKey:jid.user]) {
            self.iconImageView.alpha = 0.5f;
        }
        self.iconImageView.image = iconImage;
    }
    //群组
    else if (conversationType == ConversationTypeGroupChat){
        
    }
    //添加好友等等处理信息
    else if (conversationType == ConversationTypeSubscription){
        self.nameLabel.text = @"系统消息";
    }
    
    //系统消息
    else if (conversationType == ConversationTypeSystem){
        
    }

}

-(void)setName:(NSString *)name{
    _name = name;
    self.textLabel.text = name;
}

@end
