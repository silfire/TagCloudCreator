//
//  NSArray-Shuffle.m
//  Agricola
//
//  Created by Ingo Kasprzak on 10.10.09.
//  Copyright 2009 Silutions. All rights reserved.
//
//  Shuffle objects in an array

#import "NSArray-Shuffle.h"

@implementation NSArray(Shuffle)
-(NSArray *)shuffledArray {
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
	NSMutableArray *copy = [self mutableCopy];
	while ([copy count] > 0) {
		int index = (int)(arc4random() % [copy count]);
		id objectToMove = [copy objectAtIndex:index];
		[array addObject:objectToMove];
		[copy removeObjectAtIndex:index];
	}
	[copy release];
	return array;
}
@end
