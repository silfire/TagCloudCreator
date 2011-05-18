//
//  TagColor.m
//  TagCloudCreator
//
//  Created by Ingo Kasprzak on 11.05.11.
//  Copyright (c) 2011 Silutions. All rights reserved.
//

#import "TagGroup.h"
#import "Tag.h"


@implementation TagGroup
@dynamic fontData;
@dynamic colorData;
@dynamic text;
@dynamic tags;

- (void) awakeFromInsert {
	self.text = @"New Group";
	self.color = [NSColor blackColor];
    self.font = [NSFont systemFontOfSize:30.0f];
}

#pragma mark Setter & Getter
- (NSColor*)color {
	return [NSKeyedUnarchiver unarchiveObjectWithData:self.colorData];
}
- (void)setColor:(NSColor*)obj {
	self.colorData = [NSKeyedArchiver archivedDataWithRootObject:obj];
}

- (NSFont*)font {
	return [NSKeyedUnarchiver unarchiveObjectWithData:self.fontData];
}
- (void)setFont:(NSFont*)obj {
	self.fontData = [NSKeyedArchiver archivedDataWithRootObject:obj];
}

#pragma mark Core Data Foo

- (void)addTagsObject:(Tag *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"tags" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"tags"] addObject:value];
    [self didChangeValueForKey:@"tags" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeTagsObject:(Tag *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"tags" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"tags"] removeObject:value];
    [self didChangeValueForKey:@"tags" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addTags:(NSSet *)value {    
    [self willChangeValueForKey:@"tags" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"tags"] unionSet:value];
    [self didChangeValueForKey:@"tags" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeTags:(NSSet *)value {
    [self willChangeValueForKey:@"tags" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"tags"] minusSet:value];
    [self didChangeValueForKey:@"tags" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
