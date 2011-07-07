//
//  NSTreeController+IndexPathToObject.h
//  TagCloudCreator
//
//  Created by Kasprzak Ingo on 07.07.11.
//  Copyright 2011 Silutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTreeController (IndexPathToObject)

- (NSIndexPath *)indexPathToObject:(id)object;
- (NSIndexPath *)indexPathToObject:(id)object inTree:(NSTreeNode *)node;

- (NSTreeNode *)nodeForObject:(id)object;
- (NSTreeNode *)nodeForObject:(id)object inTree:(NSTreeNode *)treeNode;
@end
