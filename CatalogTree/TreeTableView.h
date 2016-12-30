//
//  TreeTableView.h
//  CatalogTree
//
//  Created by Denis Yurchenko on 16.11.16.
//  Copyright © 2016 Yurchenko Denis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class TreeNode;

@protocol TreeTableCellDelegate <NSObject>

-(void)cellClick:(TreeNode *)node;

@end

@interface TreeTableView : UITableView

@property (nonatomic, weak) id<TreeTableCellDelegate> treeTableCellDelegate;

-(instancetype)initWithFrame:(CGRect)frame withData:(NSArray *)data;

@end
