//
//  ViewController.h
//  CatalogTree
//
//  Created by Denis Yurchenko on 16.11.16.
//  Copyright © 2016 Yurchenko Denis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <sqlite3.h>


@interface ViewController : UIViewController<NSURLConnectionDelegate>

-(BOOL)checkInternetConnection;

@end
