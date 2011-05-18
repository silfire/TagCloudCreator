//
//  TagColor.h
//  TagCloudCreator
//
//  Created by Ingo Kasprzak on 11.05.11.
//  Copyright (c) 2011 Silutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tag;

@interface TagGroup : NSManagedObject {
@private
    
}

@property (nonatomic, assign) NSColor* color;
@property (nonatomic, retain) NSData * colorData;
@property (nonatomic, assign) NSFont* font;
@property (nonatomic, retain) NSData * fontData;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet* tags;

@end
