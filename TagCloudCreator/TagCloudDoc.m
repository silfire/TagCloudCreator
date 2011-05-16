//
//  TagCloudDoc.m
//  TagCloudCreator
//
//  Created by Ingo Kasprzak on 11.05.11.
//  Copyright 2011 Silutions. All rights reserved.
//

#import "TagCloudDoc.h"
#import "TagCloudView.h"
#import "TagGroup.h"
#import "Tag.h"
#import "ColorCell.h"
#import "NSArray-Shuffle.h"

#define TagGroupEntityKey @"TagGroup"
#define TagEntityKey @"Tag"

#define OutlineViewColorColumnName @"color"
#define OutlineViewTextColumnName @"text"

@interface TagCloudDoc ()
@property (readwrite, retain) NSArray *tagGroups;
@property (retain) 	TagGroup *selectedItemForColorEdit;
@end

@implementation TagCloudDoc
@synthesize selectedItemForColorEdit;

#pragma mark Actions

- (IBAction)pushShuffle:(id)sender {
	[tagCloudView clearCloud];
	
	NSArray *shuffledArray = [self shuffleAllTags];
	for (Tag *dataSet in shuffledArray) {
		NSString *text = dataSet.text;
		NSInteger size = [dataSet.ratio integerValue]*20;
		NSFont *font = [NSFont systemFontOfSize:size];
		CGRect textFrame = [tagCloudView calculatePositionForString:text withFont:font];
		[tagCloudView createLabelWithText:text
									 font:font
									color:dataSet.color
									frame:textFrame];
	}
}

- (IBAction)pushRedraw:(id)sender {
	[tagCloudView clearCloud];
	
	NSArray *shuffledArray = self.tags;
	for (Tag *dataSet in shuffledArray) {
		NSString *text = dataSet.text;
		NSInteger size = [dataSet.ratio integerValue]*20;
		NSFont *font = [NSFont systemFontOfSize:size];
		CGRect textFrame = [tagCloudView calculatePositionForString:text withFont:font];
		[tagCloudView createLabelWithText:text
									 font:font
									color:dataSet.color
									frame:textFrame];
	}
}

- (IBAction)pushAddGroup:(id)sender {
	[self addTagGroup];
}

- (IBAction)pushAddItem:(id)sender {
	NSInteger selection = [tagTree selectedRow];
	TagGroup *group;
	if (selection>=0) {
		id item = [tagTree itemAtRow:selection];
		if ([item class]==[Tag class]) {
			group = [item group];
		} else {
			group = item;
		}
		[self addTagToGroup:group];
	}
}

- (IBAction)pushRemoveItem:(id)sender {
	NSInteger selection = [tagTree selectedRow];
	if (selection>=0) {
		id item = [tagTree itemAtRow:selection];
		[[self managedObjectContext] deleteObject:item];
	}
}

- (void)pushColor:(id)sender {
	NSColorPanel *panel = [NSColorPanel sharedColorPanel];
	NSInteger selection = [tagTree selectedRow];
	id item = [tagTree itemAtRow:selection];
	TagGroup *group;
	if ([item class]==[Tag class]) {
		group = [item group];
	} else {
		group = item;
	}
	self.selectedItemForColorEdit = group;
	[panel setColor:group.color];

	[panel setDelegate:self];
	[panel setTarget:self];
	[panel setAction:@selector(changeColor:)];
	[panel orderFrontRegardless];
	
}

#pragma mark Color Panel Delegates

- (void) changeColor:(id)sender {
	self.selectedItemForColorEdit.color = [sender color];
}

#pragma mark Notifications

- (void)managedObjectsDidChangeNotification:(NSNotification*)notification {
	self.tagGroups = nil;
	[tagTree reloadData];
}

#pragma mark Manage Objects
- (TagGroup*)addTagGroup {
	NSManagedObjectModel *managedObjectModel = [self managedObjectModel];
	NSEntityDescription *entity = [[managedObjectModel entitiesByName] objectForKey:TagGroupEntityKey];
	TagGroup *tagGroup = [[TagGroup alloc] initWithEntity:entity
						   insertIntoManagedObjectContext:[self managedObjectContext]];
	return tagGroup;
}

- (Tag*)addTagToGroup:(TagGroup*)tagGroup {
	NSManagedObjectModel *managedObjectModel = [self managedObjectModel];
	NSEntityDescription *entity = [[managedObjectModel entitiesByName] objectForKey:TagEntityKey];
	Tag *tag = [[Tag alloc] initWithEntity:entity
				 insertIntoManagedObjectContext:[self managedObjectContext]];
	tag.group = tagGroup;
	return tag;
}

- (NSArray*)shuffleAllTags {
	NSArray *shuffledArray = [self.tags shuffledArray];
	NSUInteger i = 0;
	for (Tag *tag in shuffledArray) {
		tag.sortIndex = [NSNumber numberWithUnsignedInteger:i++];
	}
	return shuffledArray;
}

#pragma mark Outline View Data Source

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
	id result = nil;
	
	if (item==nil) {
		result = [self.tagGroups objectAtIndex:index];
	} else if ([item class]==[TagGroup class]) {
		result = [[[(TagGroup*)item tags] allObjects] objectAtIndex:index];
	}
	return result;
}
- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	id result = nil;
	if (item==nil) {
		result = @"/";
	} else {
		result = [item valueForKey:[tableColumn identifier]];
	}
	return result;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return ([item class] == [Tag class]) ? NO : YES;
}

- (NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	NSInteger result = 0;
	if (item==nil) {
		result = [self.tagGroups count];
	} else if ([item class]==[TagGroup class]) {
		result = [[(TagGroup*)item tags] count];
	}
	return result;
}

- (void) outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	[item setValue:object forKey:[tableColumn identifier]];
}

#pragma mark Manual Properties
- (NSArray*)tagGroups {
	if (tagGroups == nil) {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [[[self managedObjectModel] entitiesByName] objectForKey:TagGroupEntityKey];
		[request setEntity:entity];
		
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:TagPropertyTextKey
																		 ascending:YES];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		
		NSError *error;
		self.tagGroups = [self.managedObjectContext executeFetchRequest:request error:&error];
		[request release];
	}
	return tagGroups;
}

- (void)setTagGroups:(NSArray *)array {
	[tagGroups release];
	tagGroups = array;
	[array retain];
}
- (NSArray*)tags {
	NSArray* tags = nil;
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [[[self managedObjectModel] entitiesByName] objectForKey:TagEntityKey];
	[request setEntity:entity];

	NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:TagPropertySortIndexKey ascending:YES];
	NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:TagPropertyTextKey ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil]];

	NSError *error;
	tags = [self.managedObjectContext executeFetchRequest:request error:&error];
	[request release];
	return tags;
}

#pragma mark Printing

- (NSRect)coordinatesOfPrintArea {

    NSArray *subTagCloudViews = [tagCloudView.cloudView subviews];
    CGFloat coordinateLeft = MAXFLOAT;
	CGFloat coordinateRight = 0.0f;
	CGFloat coordinateBottom = MAXFLOAT;
	CGFloat coordinateTop = 0.0f;
	
	for (NSView *view in subTagCloudViews) {
		coordinateLeft = fminf(view.frame.origin.x, coordinateLeft);
		coordinateRight = fmaxf(view.frame.origin.x+view.frame.size.width, coordinateRight);
		coordinateBottom = fminf(view.frame.origin.y, coordinateBottom);
		coordinateTop = fmaxf(view.frame.origin.y+view.frame.size.height, coordinateTop);
	}
	return NSMakeRect(0, 0, coordinateRight-coordinateLeft, coordinateTop-coordinateBottom);
}

-(TagCloudView *)createPrintView:(NSRect)rectToPrint {

    TagCloudView *viewToPrint = [[TagCloudView alloc] initWithFrame:rectToPrint];

	NSArray *tags = self.tags;
	for (Tag *dataSet in tags) {
		NSString *text = dataSet.text;
		NSInteger size = [dataSet.ratio integerValue]*20;
		NSFont *font = [NSFont systemFontOfSize:size];
		CGRect textFrame = [viewToPrint calculatePositionForString:text withFont:font];
		[viewToPrint createLabelWithText:text
									font:font
								   color:dataSet.color
								   frame:textFrame];
	}
    return viewToPrint;
}


- (void)printDocument:(id)sender {
    NSRect rectToPrint = [self coordinatesOfPrintArea];
    TagCloudView *viewToPrint = [self createPrintView:rectToPrint];
    
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
    [printInfo setHorizontallyCentered:YES];
    [printInfo setVerticallyCentered:YES];
    [printInfo setHorizontalPagination:NSFitPagination];
    [printInfo setVerticalPagination:NSFitPagination];
    
    [viewToPrint print:self];
//    NSLog(@"Drucken ist noch nicht implementiert.");
}

#pragma mark -
#pragma mark Initialization

- (id)init {
    self = [super init];
    if (self) {
		// Add your subclass-specific initialization here.
		// If an error occurs here, send a [self release] message and return nil.
    }
    return self;
}

- (void)dealloc {
	[tagGroups release];
	[selectedItemForColorEdit release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}

- (NSString *)windowNibName {
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"TagCloudDoc";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
	[super windowControllerDidLoadNib:aController];
	// Add any code here that needs to be executed once the windowController has loaded the document's window.
	NSInteger index = [tagTree columnWithIdentifier:OutlineViewColorColumnName];
	ColorCell *cell = [[[tagTree tableColumns] objectAtIndex:index] dataCell];
	[cell setAction:@selector(pushColor:)];
	[cell setTarget:self];
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(managedObjectsDidChangeNotification:)
												 name: NSManagedObjectContextObjectsDidChangeNotification
											   object: [self managedObjectContext]];
}

@end
