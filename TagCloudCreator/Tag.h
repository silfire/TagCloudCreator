//
//  Tag.h
//  TagCloudCreator
//
//  Created by Ingo Kasprzak on 11.05.11.
//  Copyright (c) 2011 Silutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class TagGroup;

@interface Tag : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * ratio;
@property (nonatomic, retain) NSNumber * sortIndex;
@property (nonatomic, retain) TagGroup * group;

@property (readonly, nonatomic, retain) NSColor* color;

@end
