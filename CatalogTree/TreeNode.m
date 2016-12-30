//
//  TreeNode.m
//  CatalogTree
//
//  Created by Denis Yurchenko on 16.11.16.
//  Copyright © 2016 Yurchenko Denis. All rights reserved.
//

#import "TreeNode.h"

@implementation TreeNode

-(instancetype)initWithParentId:(int)parentId nodeId:(int)nodeId name:(NSString *)name depth:(int)depth isExpand:(BOOL)isExpand
{
    self = [self init];
    if (self) {
        self.ParentId = parentId;
        self.NodeId = nodeId;
        self.Name = name;
        self.Depth = depth;
        self.IsExpand = isExpand;
    }
    
    return self;
}

@end
