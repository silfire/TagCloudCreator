//
//  NSTreeController+IndexPathToObject.m
//  TagCloudCreator
//
//  Created by Kasprzak Ingo on 07.07.11.
//  Copyright 2011 Silutions. All rights reserved.
//

#import "NSTreeController+IndexPathToObject.h"

@implementation NSTreeController (IndexPathToObject)

- (NSIndexPath *)indexPathToObject:(id)object inTree:(NSTreeNode *)node {

	NSIndexPath *indexPath = nil;
	for (NSTreeNode *currentNode in [node childNodes]) {
		if ([currentNode representedObject] == object) return [currentNode indexPath];
		
		indexPath = [self indexPathToObject:object inTree:currentNode];
		if (indexPath != nil) break;
	}
	return indexPath;
}

- (NSIndexPath *)indexPathToObject:(id)object {
	return [self indexPathToObject:object inTree:[self arrangedObjects]];
}



- (NSTreeNode *)nodeForObject:(id)object inTree:(NSTreeNode *)treeNode {
	
	NSTreeNode *node = nil;
	for (NSTreeNode *currentNode in [treeNode childNodes]) {
		if ([currentNode representedObject] == object) return currentNode;
		
		node = [self nodeForObject:object inTree:currentNode];
		if (node != nil) break;
	}
	return node;
}

- (NSTreeNode*)nodeForObject:(id)object {
	return [self nodeForObject:object inTree:[self arrangedObjects]];
}

@end
