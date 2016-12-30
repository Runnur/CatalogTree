//
//  DatabaseViewController.m
//  CatalogTree
//
//  Created by Denis Yurchenko on 16.11.16.
//  Copyright © 2016 Yurchenko Denis. All rights reserved.
//

#import "DatabaseViewController.h"
#import "ViewController.h"

@interface DatabaseViewController ()<UIAlertViewDelegate>
{
    const char *dbpath;
}

@property (nonatomic, strong) NSString *databasePath;
@property (nonatomic) sqlite3 *TreeDB;


@end



@implementation DatabaseViewController
{
    NSMutableData *_responseData;
    NSURL *urlstr;
    NSMutableArray *mainGroup;
    NSMutableArray *subMainGroup;
    NSMutableArray *subSubGroup;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


-(BOOL)checkDBExistSetPathToDB {
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"TreeNodes.sqlite"]];
    NSLog(@"%@", _databasePath);
    
    dbpath = [_databasePath UTF8String];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_databasePath] == YES) {
        NSLog(@"Database exist");
        return YES;
    } else {
        NSLog(@"Database no exist");
        return NO;
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}


-(void)createDataBase
{
    if ([self checkDBExistSetPathToDB] == NO)
    {
        const char *pathdb = [_databasePath UTF8String];
        
        if (sqlite3_open(pathdb, &_TreeDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS TreeNodes (ID INTEGER PRIMARY KEY AUTOINCREMENT, ParentID INTEGER, NodeID INTEGER, NameNode TEXT, Depth INTEGER, IsExpand BOOL)";
            
            if (sqlite3_exec(_TreeDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSString *message1 = @"Failed to create table";
                NSLog(@"%@", message1);
            } else {
                NSString *message3 = @"Database created";
                NSLog(@"%@", message3);
            }
            sqlite3_close(_TreeDB);
        } else {
            NSString *message2 = @"Failed to open/create database";
            NSLog(@"%@", message2);
        }
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)insertRowsInTable:(NSArray *)fromArray
{
    if (![fromArray isKindOfClass:[NSNull class]])
    {
        [self executeQuery:@"DELETE FROM TreeNodes"];
        
        NSLog(@"%d", [[fromArray objectAtIndex:1] ParentId]);
        
        for(int i=0; i < fromArray.count; i++)
        {
            NSString *strInsert1 = [NSString stringWithFormat:@"INSERT INTO TreeNodes (ParentID, NodeID, NameNode, Depth, IsExpand) VALUES (\"%d\", \"%d\", \"%@\", \"%d\", \"%d\")", [[fromArray objectAtIndex:i] ParentId], [[fromArray objectAtIndex:i] NodeId], [[fromArray objectAtIndex:i] Name], [[fromArray objectAtIndex:i] Depth], [[fromArray objectAtIndex:i] IsExpand]];
            [self executeQuery:strInsert1];
        }
    } else {
        NSLog(@"Failed array parameter");
    }
}

-(void) executeQuery:(NSString *)queryString
{
    const char *pathdb;
    
    if (_databasePath == nil) {
        [self checkDBExistSetPathToDB];
    }
    
    pathdb = [_databasePath UTF8String];
    
    const char *sqlQuery = [queryString UTF8String];
    
    int linkDB;
    
    linkDB = sqlite3_open(pathdb, &_TreeDB);
    
    if (linkDB) {
        sqlite3_close(_TreeDB);
    } else {
        char *errMsg = 0;
        
        linkDB = sqlite3_exec(_TreeDB, sqlQuery, NULL, NULL, &errMsg);
        
        if (linkDB == SQLITE_OK) {
            NSLog(@"Successful");
        } else {
            NSString *strErr = [NSString stringWithUTF8String:errMsg];
            sqlite3_free(errMsg);
            NSLog(@"%@", strErr);
        }
        
        sqlite3_close(_TreeDB);
    }
    
}

-(NSArray *)getRecordsFromDB
{
    NSMutableArray *allNodes = [[NSMutableArray alloc] init];
    sqlite3_stmt* stmt =NULL;
    
    const char *pathdb = [_databasePath UTF8String];
    
    const char *sqlQuery;
    
    int linkDB = 0;
    
    linkDB = sqlite3_open_v2(pathdb, &_TreeDB, SQLITE_OPEN_READONLY, NULL);
    
    if (linkDB != SQLITE_OK) {
        sqlite3_close(_TreeDB);
        NSLog(@"Feiled connect to db");
    } else {
        NSString *queryString = @"SELECT * FROM TreeNodes";
        sqlQuery = [queryString UTF8String];
        linkDB = sqlite3_prepare_v2(_TreeDB, sqlQuery, -1, &stmt, NULL);
        if (linkDB == SQLITE_OK)
        {
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                TreeNode *node = [[TreeNode alloc] init];
                node.ParentId = sqlite3_column_int(stmt, 1);
                node.NodeId = sqlite3_column_int(stmt, 2);
                node.Name = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 3)];
                node.Depth = sqlite3_column_int(stmt, 4);
                node.IsExpand = sqlite3_column_int(stmt, 5);
                
                [allNodes addObject:node];
                NSLog(@"%@", [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 3)]);
            }
            sqlite3_finalize(stmt);
        } else {
            NSLog(@"Failed to prepare statement with linkDB:%d", linkDB);
        }
        sqlite3_close(_TreeDB);
    }
    
    return allNodes;
}


-(NSArray *)getRequestMakeTree
{
    urlstr = [NSURL URLWithString:@URLSTR];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlstr cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"Agent name goes here" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"ru-RU" forHTTPHeaderField:@"Accept-Language"];
    [request setAccessibilityLanguage:@"ru-RU"];
    
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSMutableArray *allNodes = [NSMutableArray array];
    
    if (data.length > 0 &&  error == nil) {
        
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        int intParentID = -1;
        int intNodeID = 0;
        int intDepth;
        BOOL boolIsExpand = YES;
        
        for (NSDictionary *dict in jsonDictionary)
        {
            
            NSLog(@"%@", [dict valueForKey:@"title"]);
            intDepth = 0;
            
            TreeNode *node = [[TreeNode alloc] init];
            node.ParentId = intParentID;
            node.NodeId = intNodeID;
            node.Name = [dict valueForKey:@"title"];
            node.Depth = intDepth;
            node.IsExpand = boolIsExpand;
            
            [allNodes addObject:node];
            
            NSArray *sub = [dict objectForKey:@"subs"];
            //NSLog(@"%@", [[[dict objectForKey:@"subs"] objectAtIndex:0] valueForKey:@"title"]);
            if ([[dict objectForKey:@"subs"] objectAtIndex:0] != NULL)
            {
                intParentID = intNodeID;
                for (int i=0; i < sub.count; i++)
                {
                    intDepth = 1;
                    NSLog(@"%@", [[[dict objectForKey:@"subs"] objectAtIndex:i] valueForKey:@"title"]);
                    TreeNode *node = [[TreeNode alloc] init];
                    node.ParentId = intParentID;
                    node.NodeId = intNodeID + 1;
                    node.Name = [[[dict objectForKey:@"subs"] objectAtIndex:i] valueForKey:@"title"];
                    node.Depth = intDepth;
                    node.IsExpand = YES;
                    
                    [allNodes addObject:node];
                    
                    intNodeID++;
                    
                    //NSLog(@"%@", [[[[[dict objectForKey:@"subs"] objectAtIndex:0] objectForKey:@"subs"] objectAtIndex:0] valueForKey:@"title"]);
                    //NSLog(@"%@", [[[[dict objectForKey:@"subs"] objectAtIndex:0] objectForKey:@"subs"] objectAtIndex:0]);
                    
                    if ([[[[dict objectForKey:@"subs"] objectAtIndex:i] objectForKey:@"subs"] objectAtIndex:0] != NULL)
                    {
                        NSLog(@"%@", [[[[[dict objectForKey:@"subs"] objectAtIndex:0] objectForKey:@"subs"] objectAtIndex:0] valueForKey:@"title"]);
                        NSArray *subSub = [[[dict objectForKey:@"subs"] objectAtIndex:0] objectForKey:@"subs"];
                        intParentID = intNodeID;
                        int intPrevParentID = intParentID-1;
                        
                        for (int j=0; j < subSub.count; j++)
                        {
                            intDepth = 2;
                            TreeNode *node = [[TreeNode alloc] init];
                            node.ParentId = intParentID;
                            node.NodeId = intNodeID + 1;
                            node.Name = [[[[[dict objectForKey:@"subs"] objectAtIndex:0] objectForKey:@"subs"] objectAtIndex:j] valueForKey:@"title"];
                            node.Depth = intDepth;
                            node.IsExpand = YES;
                            
                            [allNodes addObject:node];
                            
                            intNodeID++;
                            NSLog(@"%@", [[[[[dict objectForKey:@"subs"] objectAtIndex:0] objectForKey:@"subs"] objectAtIndex:j] valueForKey:@"title"]);
                        }
                        intParentID = intPrevParentID;
                    }
                }
            }
            intParentID = -1;
            intNodeID++;
        }
        
        [self createDataBase];
        [self insertRowsInTable:allNodes];
        
        
    }
    
    return allNodes;
    
}


- (IBAction)closeView:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


-(void)makeRequest
{
    ViewController *vc = [[ViewController alloc] init];
    
    if ([vc checkInternetConnection] == YES) {
        [self executeQuery:@"DELETE FROM TreeNodes"];
        [self getRequestMakeTree];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Отсутствует подключение к интернету" message:@"Повторить попытку?" delegate:self cancelButtonTitle:@"Нет" otherButtonTitles:@"Да", nil];
        [alert show];
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self makeRequest];
    }
}


- (IBAction)refreshTree:(id)sender
{
    [self makeRequest];
    
}

@end
