//
//  MoreViewController.m
//  XMPPBaseProject
//
//  Created by caohuan on 14-4-23.
//  Copyright (c) 2014年 caohuan. All rights reserved.
//

#import "MoreViewController.h"
#import "MoreOptionCell.h"
#import "ScanViewController.h"

@interface MoreViewController ()

@property(nonatomic,strong)NSDictionary *optionsDic;

@end

@implementation MoreViewController

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
    
    //options init from plist
    NSDictionary *sectionsDict=[NSDictionary dictionaryWithContentsOfFile:
                                 [[NSBundle mainBundle] pathForResource:@"MoreViewCtlOptions"
                                                                 ofType:@"plist"]];
    
    self.optionsDic = [sectionsDict objectForKey:@"items"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.optionsDic.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *items = [self.optionsDic objectForKey:[NSString stringWithFormat:@"section%d",section]];
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MoreOptionCell";
    MoreOptionCell *cell = (MoreOptionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
//        NSArray *nibs=[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
//        cell=[nibs objectAtIndex: 0];
    }
    NSArray *itemArray = [self.optionsDic objectForKey:[NSString stringWithFormat:@"section%d",indexPath.section]];
    
    NSDictionary *itemDic = [itemArray objectAtIndex:indexPath.row];
    NSString *title = [itemDic objectForKey:@"title"];
    NSString *icon = [itemDic objectForKey:@"icon"];
    
    cell.titleLabel.text = title;
    cell.iconImageView.image = [UIImage imageNamed:icon];
    
    return cell;
}

#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *itemArray = [self.optionsDic objectForKey:[NSString stringWithFormat:@"section%d",indexPath.section]];
    NSDictionary *itemDic = [itemArray objectAtIndex:indexPath.row];
    NSString *segueName = [itemDic objectForKey:@"segue"];
    if (segueName.length > 0) {
        [self performSegueWithIdentifier:segueName sender:self];
    }
}

#pragma mark - Segue event
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //扫描
    if ([segue.identifier isEqualToString:@"optionToScan"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ScanViewController *scan  = segue.destinationViewController;
    }else if ([segue.identifier isEqualToString:@"optionToScan"]) {
        
    }

}


@end
