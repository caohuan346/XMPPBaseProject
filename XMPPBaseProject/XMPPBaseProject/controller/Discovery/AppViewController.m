//
//  AppViewController.m
//  XMPPBaseProject
//
//  Created by hc on 14-5-11.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "AppViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MJRefresh.h"

NSString *const MyCollectionCellID = @"MyCollectionCellID";

@interface AppViewController ()<MJRefreshBaseViewDelegate>{
    NSMutableArray *_fakeColor;
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
}

@property(nonatomic,strong)NSMutableArray *groupsInfoArray;
@property(nonatomic,strong)NSMutableArray *photoURLs;
@property(nonatomic,strong)NSMutableDictionary *photosDic;

@end

@implementation AppViewController
- (id)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(80, 80);
    layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;
    return [self initWithCollectionViewLayout:layout];
}

#pragma mark - life circle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
     在iOS6中，我们可以更加方便的使用Cell，系统总是为我们初始化Cell。我们可以直接使用。只需要简单的按照两步走即可：
    
     1）  必须使用下面的方法进行Cell类的注册：
     - (void)registerClass:forCellWithReuseIdentifier:
     - (void)registerClass:forSupplementaryViewOfKind:withReuseIdentifier:
     - (void)registerNib:forCellWithReuseIdentifier:
     - (void)registerNib:forSupplementaryViewOfKind:withReuseIdentifier:
     
     2）  从队列中取出一个Cell,具体方法如下：
     -(id)dequeueReusableCellWithReuseIdentifier:forIndexPath:
     -(id)dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
     */
    
    //注册
    //[self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"MY_CELL"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
     [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:MyCollectionCellID];
    
    self.photoURLs = [NSMutableArray array];
    self.photosDic = [NSMutableDictionary dictionary];
    self.groupsInfoArray = [NSMutableArray array];
    
    // 2.假数据
    _fakeColor = [NSMutableArray array];
    for (int i = 0; i<5; i++) {
        // 添加随机色
        [_fakeColor addObject:[UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]];
    }

    
    // 集成刷新控件
    // 1.下拉刷新
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.collectionView;
    header.delegate = self;
    // 自动刷新
    [header beginRefreshing];
    _header = header;
    
    //2.上拉加载更多
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.collectionView;
    footer.delegate = self;
    _footer = footer;

}

-(void)viewWillAppear:(BOOL)animated{
    
    //[self getImgs];
    
    //[self handlePhotoData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [_header free];
    [_footer free];
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _fakeColor.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MyCollectionCellID forIndexPath:indexPath];
    cell.backgroundColor = _fakeColor[indexPath.row];
    return cell;
}

#pragma mark - refresh view
- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // 刷新表格
    [self.collectionView reloadData];
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}
#pragma mark - Refresh Delegate
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    NSLog(@"%@----开始进入刷新状态", refreshView.class);
    
    // 1.添加假数据
    for (int i = 0; i<5; i++) {
        UIColor *color = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
        
        if ([refreshView isKindOfClass:[MJRefreshHeaderView class]]) {
            [_fakeColor insertObject:color atIndex:0];
        } else {
            [_fakeColor addObject:color];
        }
    }
    
    // 2.2秒后刷新表格UI
    [self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:2.0];
}

- (void)refreshViewEndRefreshing:(MJRefreshBaseView *)refreshView
{
    NSLog(@"%@----刷新完毕", refreshView.class);
}

- (void)refreshView:(MJRefreshBaseView *)refreshView stateChange:(MJRefreshState)state
{
    switch (state) {
        case MJRefreshStateNormal:
            NSLog(@"%@----切换到：普通状态", refreshView.class);
            break;
            
        case MJRefreshStatePulling:
            NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
            break;
            
        case MJRefreshStateRefreshing:
            NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
            break;
        default:
            break;
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}


#pragma mark - get images
-(void)getImgs{
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    dispatch_async(dispatch_get_main_queue(), ^{
        /*
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
            NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
            if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
                NSLog(@"无法访问相册.请在'设置->定位服务'设置为打开状态.");
            }else{
                NSLog(@"相册访问失败.");
            }
        };
        */
    
        //1：检测权限
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error){
            NSString *errorMessage = nil;
            switch ([error code]) {
                case ALAssetsLibraryAccessUserDeniedError:
                case ALAssetsLibraryAccessGloballyDeniedError:errorMessage = @"The user has declined access to it.";
                    break;
                default:errorMessage = @"Reason unknown.";
                    break;
            }
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Opps"message:errorMessage delegate:self cancelButtonTitle:@"Cancel"otherButtonTitles:nil, nil];
            [alertView show];
        };
        
        //迭代每个group中的图片
        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
            if (result!=NULL) {
                
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//图片的url
                    NSLog(@"图片的url-----:%@",urlstr);
                    [self.photoURLs addObject:urlstr];
                    
                    /*
                     result.defaultRepresentation.fullScreenImage//图片的大图
                    result.thumbnail                             //图片的缩略图小图
                    // NSRange range1=[urlstr rangeOfString:@"id="];
                    // NSString *resultName=[urlstr substringFromIndex:range1.location+3];
                    // resultName=[resultName stringByReplacingOccurrencesOfString:@"&ext=" withString:@"."];//格式demo:123456.png
                    */
                }
            }
            
        };
        
        //迭代获得全部照片group
        ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
            if (group != nil) {
                
                //获取相簿的组
                NSString *itemGroup=[NSString stringWithFormat:@"%@",group];
                NSLog(@"gg:%@",itemGroup);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
                
                NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
                //NSString *type = [group valueForProperty:ALAssetsGroupPropertyType];
                NSInteger count = [group numberOfAssets];
                [self.groupsInfoArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:name,@"name",[NSNumber numberWithInteger:count],@"count", nil]];
                
                /*
                 //有多少图片
                NSString *groupInfoStr = [itemGroup substringFromIndex:16 ] ;
                NSArray *arr = [groupInfoStr componentsSeparatedByString:@","];
                NSString *countStr = [[arr objectAtIndex:2] substringFromIndex:14];
                 */
                
                //组name
                /*
                NSString *g2=[[arr objectAtIndex:0] substringFromIndex:5];
                if ([g2 isEqualToString:@"Camera Roll"]) {
                    g2=@"相机胶卷";
                }
                */
                
                [group enumerateAssetsUsingBlock:groupEnumerAtion];
            }else {
                NSLog(@"no group");
            }
            
        };
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:libraryGroupsEnumeration
                             failureBlock:failureBlock];
//    });

    //dispatch_async(dispatch_get_main_queue(), ^{
    
    //});
    NSLog(@"1111");
    NSLog(@"11111");
}

-(void)handlePhotoData{
    NSInteger groupCount = self.groupsInfoArray.count;
    int flag=0;
    for (int i = 0;i < groupCount;i++) {
        NSMutableDictionary *item = self.groupsInfoArray[i];
        NSInteger count = [[item objectForKey:@"count"] integerValue];
        NSArray *itemURLs = [self.photoURLs subarrayWithRange:NSMakeRange(flag, count)];
        [item setObject:itemURLs forKey:@"urls"];
        
        flag += count;
    }
    
    NSLog(@"1111");
}

//------------------------根据图片的url反取图片－－－－－
//
//ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
//NSURL *url=[NSURL URLWithString:urlStr];
//[assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
//    UIImage *image=[UIImage imageWithCGImage:asset.thumbnail];
//    cellImageView.image=image;
//    
//}failureBlock:^(NSError *error) {
//    NSLog(@"error=%@",error);
//}
// ];


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
