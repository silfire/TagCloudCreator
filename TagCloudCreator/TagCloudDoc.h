//
//  TagCloudDoc.h
//  TagCloudCreator
//
//  Created by Peter Hauke on 11.05.11.
//  Copyright 2011 Silutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TagCloudView;
@class TagGroup, Tag;

@interface TagCloudDoc : NSPersistentDocument <NSOutlineViewDataSource, NSOutlineViewDelegate, NSWindowDelegate> {
@private
	IBOutlet NSOutlineView *tagTree;
	IBOutlet TagCloudView *tagCloudView;
    TagGroup *selectedItemForEdit;
	NSArray *tagGroups;
    NSFontManager *fontManager;
    NSNumber *rotationAngle;
    
}
@property (readonly, retain) NSArray *tagGroups;
@property (readonly, retain) NSArray *tags;
@property (assign) NSFontManager *fontManager;
@property (retain) NSNumber *rotationAngle; 

- (TagGroup*)addTagGroup;
- (Tag*)addTagToGroup:(TagGroup*)tagGroup;
- (NSArray*)shuffleAllTags;
- (void)drawCloudWithTags:(NSArray*)tags toView:(TagCloudView*)view;

- (IBAction)pushShuffle:(id)sender;
- (IBAction)pushRedraw:(id)sender;
- (IBAction)pushAddGroup:(id)sender;
- (IBAction)pushAddItem:(id)sender;
- (IBAction)pushRemoveItem:(id)sender;
- (IBAction)pushFont:(NSButton *)sender;



@end
