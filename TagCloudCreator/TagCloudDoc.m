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
@property (retain) 	TagGroup *selectedItemForEdit;
@end

@implementation TagCloudDoc
@synthesize selectedItemForEdit; 
@synthesize fontManager;

#pragma mark -
#pragma mark Private Methods

-(void)updateFontPanel{
    [fontManager setSelectedFont:selectedItemForEdit.font isMultiple:NO];
}

#pragma mark Actions

- (IBAction)pushShuffle:(id)sender {
	[self drawCloudWithTags:[self shuffleAllTags] toView:tagCloudView];
}

- (IBAction)pushRedraw:(id)sender {
	[self drawCloudWithTags:self.tags toView:tagCloudView];
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

- (IBAction)pushFont:(id)sender {
	[self updateFontPanel];
    [fontManager orderFrontFontPanel:self];
}

- (void)pushColor:(id)sender {
	NSColorPanel *panel = [NSColorPanel sharedColorPanel];

	[panel setColor:selectedItemForEdit.color];
	[panel setDelegate:self];
	[panel setTarget:self];
	[panel setAction:@selector(changeColor:)];
	[panel orderFrontRegardless];
	
}

#pragma mark -
#pragma mark FontPanel Delegates

-(void)changeFont:(id)sender {
    NSFont *oldFont = [fontManager selectedFont];
    NSFont *newFont = [fontManager convertFont:oldFont];       
    self.selectedItemForEdit.font = newFont;
}

#pragma mark ColorPanel Delegates

- (void) changeColor:(id)sender {
	self.selectedItemForEdit.color = [sender color];
}

#pragma mark -
#pragma mark Manage Objects
- (TagGroup*)addTagGroup {
	NSManagedObjectModel *managedObjectModel = [self managedObjectModel];
	NSEntityDescription *entity = [[managedObjectModel entitiesByName] objectForKey:TagGroupEntityKey];
	TagGroup *tagGroup = [[[TagGroup alloc] initWithEntity:entity
						   insertIntoManagedObjectContext:[self managedObjectContext]] autorelease];
	return tagGroup;
}

- (Tag*)addTagToGroup:(TagGroup*)tagGroup {
	NSManagedObjectModel *managedObjectModel = [self managedObjectModel];
	NSEntityDescription *entity = [[managedObjectModel entitiesByName] objectForKey:TagEntityKey];
	Tag *tag = [[[Tag alloc] initWithEntity:entity
				 insertIntoManagedObjectContext:[self managedObjectContext]] autorelease];
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

-(void)drawCloudWithTags:(NSArray *)tags toView:(TagCloudView*)view {
    [view clearCloud];
	for (Tag *dataSet in tags) {
		NSString *text = dataSet.text;
		CGRect textFrame = [view calculatePositionForString:text withFont:dataSet.font];
        
        [view createLabelWithText:text
                             font:dataSet.font
                            color:dataSet.color
                            frame:textFrame];
    }
}

// Lightweight Versioning of Models
- (BOOL)configurePersistentStoreCoordinatorForURL:(NSURL *)url
										   ofType:(NSString *)fileType
							   modelConfiguration:(NSString *)configuration
									 storeOptions:(NSDictionary *)storeOptions
											error:(NSError **)error {
	NSMutableDictionary *extendedOptions;
	if (storeOptions) {
		extendedOptions = [[storeOptions mutableCopy] autorelease];
	} else {
		extendedOptions = [NSMutableDictionary dictionaryWithCapacity:2];
	}
	[extendedOptions setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
	[extendedOptions setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];

	return [super configurePersistentStoreCoordinatorForURL:url
													 ofType:fileType
										 modelConfiguration:configuration
											   storeOptions:extendedOptions
													  error:error];
}

#pragma mark Notifications

- (void)managedObjectsDidChangeNotification:(NSNotification*)notification {
	NSDictionary *userInfo = [notification userInfo];
	if (([[userInfo objectForKey:NSInsertedObjectsKey] count]>0) ||
		([[userInfo objectForKey:NSDeletedObjectsKey] count]>0)) {
		self.tagGroups = nil;
	}
	[tagTree reloadData];
	[self drawCloudWithTags:self.tags toView:tagCloudView];
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

#pragma mark -
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

- (void) outlineViewSelectionDidChange:(NSNotification *)notification {
	NSInteger selection = [tagTree selectedRow];
	Tag *tag;
	TagGroup *group;                       
	if (selection>=0) {
		id item = [tagTree itemAtRow:selection];
		if ([item class]==[Tag class]) {
			tag = item;
            group = [item group];
		} else {
			NSInteger i = -1;
			for (tag in [item tags]) {
				if (i>=0 && [tag.ratio integerValue]!=i) {
					i=-1;
					break;
				} else {
					i = [tag.ratio integerValue];
				}
			}
			if (i>=0) {
				tag = [[(TagGroup*)item tags] anyObject];
			}
            
            group = item;                       
		}
        self.selectedItemForEdit = group;             
        [self updateFontPanel];
    }
}


#pragma mark -
#pragma mark Printing

- (NSRect)coordinatesOfPrintArea {

    NSArray *subTagCloudViews = [tagCloudView.cloudView subviews];
    CGFloat coordinateLeft = MAXFLOAT;
	CGFloat coordinateRight = 0.0f;
	CGFloat coordinateBottom = MAXFLOAT;
	CGFloat coordinateTop = 0.0f;
	
	for (NSView *view in subTagCloudViews) {
		coordinateLeft = fmin(view.frame.origin.x, coordinateLeft);
		coordinateRight = fmax(view.frame.origin.x + view.frame.size.width, coordinateRight);
		coordinateBottom = fmin(view.frame.origin.y, coordinateBottom);
		coordinateTop = fmax(view.frame.origin.y + view.frame.size.height, coordinateTop);
	}
	return NSMakeRect(0, 0, coordinateRight-coordinateLeft+5.0f, coordinateTop-coordinateBottom+5.0f); // 5 = 1 für 0 als Koordinate und 2+2 für Rand links und Rechts um View
}

- (BOOL)shouldChangePrintInfo:(NSPrintInfo *)newPrintInfo {
	return YES;
}

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError **)outError {
    NSRect rectToPrint = [self coordinatesOfPrintArea];
    TagCloudView *viewToPrint = [[[TagCloudView alloc] initWithFrame:rectToPrint] autorelease];
    [self drawCloudWithTags:self.tags toView:viewToPrint];
    
    NSPrintInfo *printInfo = [self printInfo];
    
	NSSize viewSize = [viewToPrint frame].size;
	NSSize canvasSize = [printInfo paperSize];
	canvasSize.width -= [printInfo leftMargin] + [printInfo rightMargin];
	canvasSize.height -= [printInfo topMargin] + [printInfo bottomMargin];
	CGFloat scaleFactor = fmin(canvasSize.width / viewSize.width, canvasSize.height / viewSize.height);
	
	[viewToPrint.cloudView scaleUnitSquareToSize:NSMakeSize(scaleFactor, scaleFactor)];
	NSRect frame = [viewToPrint frame];
	frame.size.width *= scaleFactor;
	frame.size.height *= scaleFactor;
	[viewToPrint setFrame:frame];
	[viewToPrint.cloudView setFrame:frame];
 
    NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView:viewToPrint printInfo:printInfo];
    [printOperation setJobTitle:[self displayName]];
    return printOperation;
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
    [selectedItemForEdit release];
	
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
	
    
    // sharedFontManager holen denn zuerst muss dem ein Font uebergeben werden, damit er ueberhaupt was zurueck gibt .... WEIRD!!!!!
    fontManager = [NSFontManager sharedFontManager];
    [fontManager setDelegate:self];
    [fontManager setSelectedFont:[NSFont systemFontOfSize:16.0f] isMultiple:NO];
    // -----
    
    NSInteger index = [tagTree columnWithIdentifier:OutlineViewColorColumnName];
	ColorCell *cell = [[[tagTree tableColumns] objectAtIndex:index] dataCell];
	[cell setAction:@selector(pushColor:)];
	[cell setTarget:self];
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(managedObjectsDidChangeNotification:)
												 name: NSManagedObjectContextObjectsDidChangeNotification
											   object: [self managedObjectContext]];
	[self drawCloudWithTags:self.tags toView:tagCloudView];
}

@end
