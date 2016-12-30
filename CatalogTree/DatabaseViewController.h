//
//  DatabaseViewController.h
//  CatalogTree
//
//  Created by Denis Yurchenko on 16.11.16.
//  Copyright © 2016 Yurchenko Denis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "TreeNode.h"

@interface DatabaseViewController : UIViewController

#define URLSTR "https://money.yandex.ru/api/categories-list"

-(void)insertRowsInTable:(NSArray *)fromArray;
-(NSArray *)getRecordsFromDB;
-(BOOL)checkDBExistSetPathToDB;
-(void)createDataBase;
-(NSArray *)getRequestMakeTree;

@end