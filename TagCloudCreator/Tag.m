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

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super init])) {
		self.text	= [decoder decodeObjectForKey:@"text"];
		self.ratio	= [decoder decodeObjectForKey:@"ratio"];
		self.sortIndex = [decoder decodeObjectForKey:@"sortIndex"];
		self.group = [decoder decodeObjectForKey:@"group"];
        self.group.color = [decoder decodeObjectForKey:@"group.color"];
        self.group.font = [decoder decodeObjectForKey:@"group.font"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.ratio forKey:@"ratio"];
    [aCoder encodeObject:self.sortIndex forKey:@"sortIndex"];
    [aCoder encodeObject:self.group forKey:@"group"];
    [aCoder encodeObject:self.group.color forKey:@"group.color"];
    [aCoder encodeObject:self.group.font forKey:@"group.font"];
}

@end
