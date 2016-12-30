//
//  TreeTableView.m
//  CatalogTree
//
//  Created by Denis Yurchenko on 16.11.16.
//  Copyright © 2016 Yurchenko Denis. All rights reserved.
//

#import "TreeTableView.h"
#import "TreeNode.h"

@interface TreeTableView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSMutableArray *tempData;

@end

@implementation TreeTableView

- (instancetype)initWithFrame:(CGRect)frame withData:(NSArray *)data
{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        _data = data;
        _tempData = [self createTempData:data];
    }
    
    return self;
}

-(NSMutableArray *)createTempData:(NSArray *)data
{
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i=0; i<data.count; i++) {
        TreeNode *node = [_data objectAtIndex:i];
        if (node.IsExpand) {
            [tempArray addObject:node];
        }
    }
    
    return tempArray;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tempData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *NODE_CELL_ID = @"node_cell_id";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NODE_CELL_ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NODE_CELL_ID];
        
    }
    
    TreeNode *node = [_tempData objectAtIndex:indexPath.row];
    
    cell.indentationLevel = node.Depth;
    cell.indentationWidth = 30.0f;
    cell.textLabel.text = node.Name;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Light" size:14.0];
    
    return cell;
}

#pragma mark - Optional
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

#pragma mark - UITableViewDelegate
#pragma mark - Optional
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TreeNode *parentNode = [_tempData objectAtIndex:indexPath.row];
    if (_treeTableCellDelegate && [_treeTableCellDelegate respondsToSelector:@selector(cellClick:)])
    {
        [_treeTableCellDelegate cellClick:parentNode];
    }
    
    NSUInteger startPosition = indexPath.row + 1;
    NSUInteger endPosition = startPosition;
    BOOL expand = NO;
    for (int i = 0; i<_data.count; i++)
    {
        TreeNode *node = [_data objectAtIndex:i];
        if (node.ParentId == parentNode.NodeId)
        {
            node.IsExpand = !node.IsExpand;
            if (node.IsExpand)
            {
                [_tempData insertObject:node atIndex:endPosition];
                expand = YES;
                endPosition++;
            } else {
                expand = NO;
                endPosition = [self removeAllNodesAtParentNode:parentNode];
                break;
            }
        }
    }
    
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (NSUInteger i=startPosition; i<endPosition; i++)
    {
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPathArray addObject:tempIndexPath];
    }
    
    if  (expand)
    {
        [self insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

-(NSUInteger)removeAllNodesAtParentNode:(TreeNode *)parentNode
{
    NSUInteger startPosition = [_tempData indexOfObject:parentNode];
    NSUInteger endPosition = startPosition;
    for (NSUInteger i=startPosition+1; i<_tempData.count; i++) {
        TreeNode *node = [_tempData objectAtIndex:i];
        endPosition++;
        if (node.Depth <= parentNode.Depth)
        {
            break;
        }
        if (endPosition == _tempData.count - 1)
        {
            endPosition++;
            node.IsExpand = NO;
            break;
        }
        node.IsExpand = NO;
    }
    if (endPosition > startPosition)
    {
        [_tempData removeObjectsInRange:NSMakeRange(startPosition+1, endPosition-startPosition-1)];
    }
    
    return endPosition;
}


@end

