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

#define TagGroupTreeDatatype @"de.silutions.TagCloudCreator.TagGroupTreeDatatype"
#define TagTreeDatatype @"de.silutions.TagCloudCreator.TagTreeDatatype"

@interface TagCloudDoc ()
@property (readwrite, retain) NSArray *tagGroups;
@property (retain) 	TagGroup *selectedItemForEdit;
@end

@implementation TagCloudDoc
@synthesize selectedItemForEdit; 
@synthesize fontManager;
@synthesize rotationAngle;

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
	TagGroup *tagGroup = [self addTagGroup];
    
    // Neue TagGroup in OutlineView anwählen
    [tagTree reloadData];
    [tagTree reloadItem:nil reloadChildren:YES];
    NSInteger newTagGroupRow = [tagTree rowForItem:tagGroup];
    [tagTree selectRowIndexes:[NSIndexSet indexSetWithIndex:newTagGroupRow] byExtendingSelection:NO];
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
            [tagTree expandItem:group];
		}
		Tag *tag = [self addTagToGroup:group];

        // Neues Tag im OutlineView anwählen
        [tagTree reloadData];
        NSInteger newTagRow = [tagTree rowForItem:tag];
        [tagTree selectRowIndexes:[NSIndexSet indexSetWithIndex:newTagRow] byExtendingSelection:NO];
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

- (void)changeColor:(id)sender {
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
	tag.viewSortIndex = [NSNumber numberWithUnsignedLong:[[tagGroup tags] count]];
	return tag;
}

- (NSArray*)shuffleAllTags {
	NSArray *shuffledArray = [self.tags shuffledArray];
	NSUInteger i = 0;
	for (Tag *tag in shuffledArray) {
		tag.sortIndex = [NSNumber numberWithUnsignedInteger:i++];
        NSLog(@"%@ %lu", tag.text, i);
	}
	return shuffledArray;
}

-(void)drawCloudWithTags:(NSArray *)tags toView:(TagCloudView*)view {
    [view clearCloud];
	for (Tag *dataSet in tags) {
		NSString *text = dataSet.text;
		CGRect textFrame = [view calculatePositionForString:text withFont:dataSet.font];
        CGFloat rotation = [rotationAngle floatValue];
        /*
        [view createLabelWithText:text
                             font:dataSet.font
                            color:dataSet.color
                            frame:textFrame
                         rotation:rotation];
         */
        [view newCreateLabelWithText:text
                                font:dataSet.font 
                               color:dataSet.color
                            rotation:rotation];
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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if ([keyPath isEqualToString:@"rotationAngle"]) {
        [self drawCloudWithTags:self.tags toView:tagCloudView];
    }

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
		//result = [[[(TagGroup*)item tags] allObjects] objectAtIndex:index];
		
		result = [[item viewSortedTags] objectAtIndex:index];
		//NSArray *tags = [item viewSortedTags];
		//result = [tags objectAtIndex:index];
		NSLog(@"Item geliefert fuer Index %ld der Gruppe %@: Tag %@", index, [item text], [result text]);
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
	/*
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[outlineView reloadData];
	});
	 */
}

- (void) outlineViewSelectionDidChange:(NSNotification *)notification {
	NSInteger selection = [tagTree selectedRow];
	TagGroup *group = nil;                       
	if (selection>=0) {
		id item = [tagTree itemAtRow:selection];
		if ([item class]==[Tag class]) {
            group = [item group];
		} else if ([item class]==[TagGroup class]) {		
            group = item;                       
		}
        self.selectedItemForEdit = group;     // für Änderung der Color        
        [self updateFontPanel];
    }
}

#pragma mark -
#pragma mark Drag and Drop

- (BOOL)outlineView:(NSOutlineView *)outlineView 
         writeItems:(NSArray *)items 
       toPasteboard:(NSPasteboard *)pboard { 
    BOOL result = YES;
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	
    // TagGroup soll nicht dragbar sein
    // 1. prüfen ob TagGroup gedragt 
    int groupCounter = 0;
	int tagCounter = 0;
	for (id item in items) {
		NSInteger index = [outlineView rowForItem:item];
		if (index>=0) { [indexSet addIndex:index]; }
		if ([item isKindOfClass:[TagGroup class]]) {
			groupCounter++;
		} else {
			tagCounter++;
		}
	}
    // 2. wenn (auch )TagGroup gedragt, dann returnwert = NO
	if (tagCounter && groupCounter) result = NO;
    
    // Merken, ob Tag oder TagGroup gedragt wird
	NSString *datatype = (tagCounter ? TagTreeDatatype : TagGroupTreeDatatype);
	
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:indexSet];
    [pboard declareTypes:[NSArray arrayWithObject:datatype] owner:self];
    [pboard setData:data forType:datatype];
    return result;
}

-(NSDragOperation)outlineView:(NSOutlineView *)outlineView 
                 validateDrop:(id<NSDraggingInfo>)info 
                 proposedItem:(id)item 
           proposedChildIndex:(NSInteger)index {
	NSDragOperation result = NSDragOperationNone;
	
    // Drop zulassen, wenn Tag gedragt wurde
    NSString *datatype = [[info draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:TagTreeDatatype]];
	if (datatype) {
		NSDragOperation op = [info draggingSourceOperationMask];
		if (op & NSDragOperationEvery) {result = NSDragOperationMove;} 
	}
	return result;
}

-(BOOL)outlineView:(NSOutlineView*)outlineView 
        acceptDrop:(id<NSDraggingInfo>)info 
              item:(id)item 
        childIndex:(NSInteger)index {
    
    // item = TagGroup, auf die gedroppt wurde
    // index = Stelle, an die gedroppt wurde
    // draggedItems enthält die gedraggten Items
    
    NSPasteboard *pboard = [info draggingPasteboard];
    NSData *data = [pboard dataForType:TagTreeDatatype];
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
	TagGroup *group = nil;
	if ([item isKindOfClass:[TagGroup class]]) {
		group = item;
	} else {
		group = [item group];
	}
	NSArray *tags = [group viewSortedTags];
	
	__block NSInteger newIndex = 0;
	for (Tag *tag in tags) {
		if (newIndex == index) {
			[rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
				Tag *tagToInsert = [outlineView itemAtRow:idx];
				tagToInsert.group = group;
				tagToInsert.viewSortIndex = [NSNumber numberWithInteger:newIndex];
				newIndex++;
			}];
		}
		tag.viewSortIndex = [NSNumber numberWithInteger:newIndex];
		newIndex++;
	}
     
    return YES;
}

/*
-(id)outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item {
    return item;
}
*/

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
	[rotationAngle release];
    
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
	
    //Drag'n'Drop
    [tagTree registerForDraggedTypes:[NSArray arrayWithObject:TagTreeDatatype]];
    
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
    
    [self addObserver:self forKeyPath:@"rotationAngle" options:NSKeyValueObservingOptionNew context:NULL];
    
	[self drawCloudWithTags:self.tags toView:tagCloudView];
}

@end
