//
//  Tag.m
//  TagCloudCreator
//
//  Created by Ingo Kasprzak on 11.05.11.
//  Copyright (c) 2011 Silutions. All rights reserved.
//

#import "Tag.h"
#import "TagGroup.h"

@implementation Tag
@dynamic text;
@dynamic ratio;
@dynamic sortIndex;
@dynamic group;

- (void) awakeFromInsert {
	self.text = @"New Item";
	self.ratio = [NSNumber numberWithInt:20];
}

- (NSColor*)color {
	return self.group.color;
}

- (NSFont*)font {
	return self.group.font;
}

@end
