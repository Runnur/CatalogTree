//
//  ViewController.m
//  CatalogTree
//
//  Created by Denis Yurchenko on 16.11.16.
//  Copyright © 2016 Yurchenko Denis. All rights reserved.
//

#import "ViewController.h"
#import "TreeNode.h"
#import "TreeTableView.h"
#import "DatabaseViewController.h"


@interface ViewController ()<TreeTableCellDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) DatabaseViewController *dbc;
@property (weak, nonatomic) IBOutlet UIView *trview;

@end

@implementation ViewController
{
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dbc = [[DatabaseViewController alloc] init];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [self makeRequest];
    
}



-(void)makeRequest
{
    if ([_dbc checkDBExistSetPathToDB]) {
        
        NSArray *data = [_dbc getRecordsFromDB];
        if ([data count] > 0) {
            [self createTableWithData:data];
        }
        
    } else {
        if ([self checkInternetConnection]) {
            
            [_dbc getRequestMakeTree];
            [self createTableWithData:[_dbc getRecordsFromDB]];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Отсутствует подключение к интернету" message:@"Повторить попытку?" delegate:self cancelButtonTitle:@"Нет" otherButtonTitles:@"Да", nil];
            [alert show];
        }
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self makeRequest];
    }
}


-(void)createTableWithData:(NSArray *)dataArray
{
    
    NSLog(@"%f", self.navigationController.navigationBar.frame.size.height);
    TreeTableView *tableView = [[TreeTableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) withData:dataArray];
    tableView.backgroundColor = [UIColor colorWithRed:204.0 green:255.0 blue:204.0 alpha:1.0f];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.treeTableCellDelegate = self;
    [self.view addSubview:tableView];
    
}


-(BOOL)checkInternetConnection
{
    NSURL *strUrl = [NSURL URLWithString:@"http://www.yandex.ru"];
    NSData *data = [NSData dataWithContentsOfURL:strUrl];
    if (data)
    {
        NSLog(@"Connected to internet");
        return YES;
    } else {
        NSLog(@"Not connected to internet");
        return NO;
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    //NSLog(@"%@", response);
}




-(void)cellClick:(TreeNode *)node{
    NSLog(@"%@", node.Name);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
