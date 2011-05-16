//
//  TagCloudDoc.h
//  TagCloudCreator
//
//  Created by Ingo Kasprzak on 11.05.11.
//  Copyright 2011 Silutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TagCloudView;
@class TagGroup, Tag;

@interface TagCloudDoc : NSPersistentDocument <NSOutlineViewDataSource, NSOutlineViewDelegate, NSWindowDelegate> {
@private
	IBOutlet NSOutlineView *tagTree;
	IBOutlet TagCloudView *tagCloudView;
	TagGroup *selectedItemForColorEdit;
	NSArray *tagGroups;
}
@property (readonly, retain) NSArray *tagGroups;
@property (readonly, retain) NSArray *tags;
- (TagGroup*)addTagGroup;
- (Tag*)addTagToGroup:(TagGroup*)tagGroup;
- (NSArray*)shuffleAllTags;

- (IBAction)pushShuffle:(id)sender;
- (IBAction)pushRedraw:(id)sender;
- (IBAction)pushAddGroup:(id)sender;
- (IBAction)pushAddItem:(id)sender;
- (IBAction)pushRemoveItem:(id)sender;

@end
