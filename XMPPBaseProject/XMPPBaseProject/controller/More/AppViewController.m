//
//  AppViewController.m
//  XMPPBaseProject
//
//  Created by hc on 14-5-11.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "AppViewController.h"
#import "Cell.h"
#import "LineLayout.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface AppViewController ()

@property(nonatomic,strong)NSMutableArray *groupsInfoArray;
@property(nonatomic,strong)NSMutableArray *photoURLs;
@property(nonatomic,strong)NSMutableDictionary *photosDic;

@end

@implementation AppViewController

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
    
    [self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"MY_CELL"];
    
    self.photoURLs = [NSMutableArray array];
    self.photosDic = [NSMutableDictionary dictionary];
    self.groupsInfoArray = [NSMutableArray array];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
//    [self getAllImages];
    
    [self getImgs];
    
    [self handlePhotoData];
    
    NSLog(@"1111");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    
    // Configure thecell's content
    
    // cell.imageView.image= ...
    
    return cell;
    

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
