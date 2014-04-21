//
//  AccessoryView.h
//  KuaiKuai
//
//  Created by caohuan on 13-9-6.
//  Copyright (c) 2013年 MONTNETS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccessoryView;
@protocol AccessoryViewDelegate <NSObject>

@optional
//选择了某个附件
-(void)accessoryView:(AccessoryView *)accessoryView didSelectedItem:(UIButton *)itemBtn;

@end;

@interface AccessoryView : UIScrollView

@property(nonatomic,retain)NSMutableArray *accessoryArray; //附件信息字典集合

@property(nonatomic,assign) id<AccessoryViewDelegate> accessoryDelegate;

//根据信息集合初始化
- (id)initWithFrame:(CGRect)frame accessoryArray:(NSMutableArray *)accessoryArray;
//根据会话类型初始化
- (id)initWithFrame:(CGRect)frame sessionType:(NSInteger)sessionType;
@end
