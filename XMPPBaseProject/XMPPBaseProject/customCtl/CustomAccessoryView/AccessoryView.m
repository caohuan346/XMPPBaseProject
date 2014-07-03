//
//  AccessoryView.m
//  KuaiKuai
//
//  Created by caohuan on 13-9-6.
//  Copyright (c) 2013年 MONTNETS. All rights reserved.
//

#import "AccessoryView.h"

#define kMargin 12
#define kItemWidth 65  //(320 - 12*5)/4
#define kItemHeight 75

@implementation AccessoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame accessoryArray:(NSMutableArray *)accessoryArray{
    self = [super initWithFrame:frame];
    if (self) {
        self.accessoryArray = accessoryArray;
        [self setBackgroundColor:UIColorFromRGB(0Xf1efeb)];
        [self initItemViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame conversationType:(NSInteger)conversationType{
    self = [super initWithFrame:frame];
    if (self) {
        //[self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"facesBack"]]];
        [self setBackgroundColor:UIColorFromRGB(0Xf1efeb)];
        self.accessoryArray = [NSMutableArray array];
    
        [self initDataWithConversationType:conversationType];
        
        [self initItemViews];
    }
    return self;
}

//根据会话类型初始化附件view需要的数据
-(void)initDataWithConversationType:(NSInteger)conversationType{
    NSDictionary *accessoryDict=[NSDictionary dictionaryWithContentsOfFile:
                                [[NSBundle mainBundle] pathForResource:@"accessoryInfo"
                                                                ofType:@"plist"]];
    
    self.accessoryArray = [accessoryDict objectForKey:@"items"];
}

/*
 SEL tt;
 tt = @selector(sayHi);
 
 // 打包成一个NSValue对象,就可以传来传去了.
 NSValue *selectorValue = [NSValue valueWithBytes:&tt objCType:@encode(SEL)];
 NSArray *arr = @[selectorValue];
 
 SEL mm;
 // 取值
 [arr[0] getValue:&mm];
 */
-(void)initItemViews{
    
    CGFloat displayWidth = 320;//self.frame.size.width;
    CGFloat displayHeight = self.frame.size.height;
    
    int total = (int)[self.accessoryArray count];
    
    int viewCount = total%8==0? total/8 : total/8+1;//显示几页
    self.contentSize = CGSizeMake(viewCount * displayWidth, 0);
    
    for (int i=0; i<viewCount; i++) {
        CGRect pageRect = CGRectMake(i*displayWidth, 0, displayWidth, displayHeight);
        UIView *pageView = [[UIView alloc] initWithFrame:pageRect];
        
        int subNum = i*8 + 8> total? total-i*8 : 8; //没有满一页
        NSRange range = NSMakeRange(i * 8, subNum);
        
        //平铺每页数据
        NSArray *pageArray = [self.accessoryArray subarrayWithRange:range];
        
        for (int j=0; j<subNum; j++) {
            NSDictionary  *itemDic = [pageArray objectAtIndex:j];
            
            NSString *normal = [itemDic  objectForKey:@"normalImg"];
            NSString *selected = [itemDic  objectForKey:@"selectedImg"];
            NSString *title = [itemDic  objectForKey:@"title"];
            
            UIImage *normalImg = [UIImage imageNamed:normal];
            UIImage *selectedImg = [UIImage imageNamed:selected];
            
            int itemRow = j/4<1 ? 0 : 1 ;//算出item所在行,从0开始
            int itemColoum = j%4;//所在列
            
            CGRect itemRect = CGRectMake(kMargin+itemColoum * (kItemWidth+kMargin), kMargin*.5+5+itemRow *(98-kMargin*.5), kItemWidth, kItemHeight);
            //每个按钮
            UIButton *itemBtn = [[UIButton alloc] initWithFrame:itemRect];
            
            //tag传递：
            itemBtn.tag = 1000+(i*8 + j);
            
            [itemBtn setTitle:title forState:UIControlStateNormal];
            itemBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];//systemFontOfSize:14];
            UIColor *titleColor = UIColorFromRGB(0X404243);//[UIColor colorWithRed:66.0/255.0 green:60.0/255.0 blue:47.0/255.0 alpha:1];
            [itemBtn setTitleColor:titleColor forState:UIControlStateNormal];
            
            //图片与标题的设置
            [itemBtn setTitleEdgeInsets:UIEdgeInsetsMake( 80.0,-normalImg.size.width, 0.0,0.0)];
            [itemBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0,0.0, -itemBtn.titleLabel.bounds.size.width)];
            
            [itemBtn setImage:normalImg forState:UIControlStateNormal];
            [itemBtn setImage:selectedImg forState:UIControlStateSelected];
            
            //[itemBtn setBackgroundImage:normalImg forState:UIControlStateNormal];
            [itemBtn addTarget:self action:@selector(itemBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [pageView addSubview:itemBtn];
        }
        
        [self addSubview:pageView];
    }
}

#pragma mark - item click
-(void)itemBtnDidClicked:(UIButton *)btn{
    int clickIdx = btn.tag%1000;
    NSDictionary  *itemDic = [self.accessoryArray objectAtIndex:clickIdx];
    
    //item点击后对应的方法
    /*
    NSValue *selectorValue = [itemDic objectForKey:@"selector"];
    NSArray *arr = @[selectorValue];
    SEL selector;
    [arr[0] getValue:&selector];
    */
    
    NSString *selectorStr= [itemDic objectForKey:@"selector"];
    SEL selector = NSSelectorFromString(selectorStr);
    
    //delegate 
    if ([self.accessoryDelegate respondsToSelector:selector]) {
        [self.accessoryDelegate performSelector:selector];
    }
}
@end
