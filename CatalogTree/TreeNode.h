//
//  TreeNode.h
//  CatalogTree
//
//  Created by Denis Yurchenko on 16.11.16.
//  Copyright © 2016 Yurchenko Denis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreeNode : NSObject

@property (nonatomic, assign) int ParentId;
@property (nonatomic, assign) int NodeId;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, assign) int Depth;
@property (nonatomic, assign) BOOL IsExpand;


-(instancetype)initWithParentId:(int)parentId nodeId:(int)nodeId name:(NSString *)name depth:(int)depth isExpand:(BOOL)iExpand;

@end
