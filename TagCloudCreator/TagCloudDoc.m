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

@interface TagCloudDoc ()
@property (readwrite, retain) NSArray *tagGroups;
@property (retain) 	TagGroup *selectedItemForColorEdit;
@end

@implementation TagCloudDoc
@synthesize selectedItemForColorEdit;

#pragma mark Actions

- (IBAction)pushShuffle:(id)sender {
	[tagCloudView clearCloud];
	
	NSArray *shuffledArray = [self.tags shuffledArray];
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
		self.tagGroups = nil;
		[tagTree reloadData];
	}
}

- (void)pushColor:(id)sender {
	NSLog(@"Color Button pressed!");
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

- (void) changeColor:(id)sender {
	self.selectedItemForColorEdit.color = [sender color];
	[tagTree reloadData];
}

#pragma mark Manage Objects
- (TagGroup*)addTagGroup {
	NSManagedObjectModel *managedObjectModel = [self managedObjectModel];
	NSEntityDescription *entity = [[managedObjectModel entitiesByName] objectForKey:TagGroupEntityKey];
	TagGroup *tagGroup = [[TagGroup alloc] initWithEntity:entity
						   insertIntoManagedObjectContext:[self managedObjectContext]];

	self.tagGroups = nil;
	[tagTree reloadData];
	return tagGroup;
}

- (Tag*)addTagToGroup:(TagGroup*)tagGroup {
	NSManagedObjectModel *managedObjectModel = [self managedObjectModel];
	NSEntityDescription *entity = [[managedObjectModel entitiesByName] objectForKey:TagEntityKey];
	Tag *tag = [[Tag alloc] initWithEntity:entity
				 insertIntoManagedObjectContext:[self managedObjectContext]];

	tag.group = tagGroup;

	[tagTree reloadData];
	return tag;
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

		NSError *error;
		self.tagGroups = [self.managedObjectContext executeFetchRequest:request error:&error];
		[request release];
		
	}
	
	return tagGroups;
}
- (NSArray*)tags {
	NSArray* tags = nil;
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [[[self managedObjectModel] entitiesByName] objectForKey:TagEntityKey];
	[request setEntity:entity];
		
	NSError *error;
	tags = [self.managedObjectContext executeFetchRequest:request error:&error];
	[request release];
	return tags;
}



- (void)setTagGroups:(NSArray *)array {
	[tagGroups release];
	tagGroups = array;
	[array retain];
}

#pragma mark Printing

- (NSRect)coordinatesOfPrintingArea {
    
    /*
    // The drawing bounds of an array of graphics is the union of all of their drawing bounds.
    NSRect drawingBounds = NSZeroRect;
    
    NSArray *subTagCloudViews = [tagCloudView subviews];
    unsigned int graphicCount = (unsigned int)[subTagCloudViews count];
    if (subTagCloudViews>0) {
		drawingBounds = [(NSView *)[subTagCloudViews objectAtIndex:0] bounds];
		for (unsigned int index = 1; index<graphicCount; index++) {
            drawingBounds = NSUnionRect(drawingBounds, [[subTagCloudViews objectAtIndex:index] drawingBounds]);
		}
    }
    return drawingBounds;
    */
    
    
     
    NSMutableArray *coordinateLeft, *coordinateRight, *coordinateBottom, *coordinateTop;
    coordinateLeft = [[NSMutableArray alloc] init];
    coordinateRight = [[NSMutableArray alloc] init];
    coordinateBottom = [[NSMutableArray alloc] init];
    coordinateTop = [[NSMutableArray alloc] init];
    
    NSArray *subTagCloudViews = [tagCloudView subviews];
    NSView *subTagCloudView = [subTagCloudViews objectAtIndex:0];
    
    for (NSView *view in [subTagCloudView subviews]) {
        [coordinateLeft addObject:[NSNumber numberWithFloat:view.frame.origin.x]];
        [coordinateRight addObject:[NSNumber numberWithFloat:(view.frame.origin.x + view.frame.size.width)]];
        [coordinateBottom addObject:[NSNumber numberWithFloat:view.frame.origin.y]];
        [coordinateTop addObject:[NSNumber numberWithFloat:(view.frame.origin.y + view.frame.size.height)]]; 
    }
   
    NSSortDescriptor *mySorterAscending = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
    NSSortDescriptor *mySorterDescending = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:NO];        
                                            
    [coordinateLeft sortUsingDescriptors:[NSArray arrayWithObject:mySorterAscending]];
    [coordinateRight sortUsingDescriptors:[NSArray arrayWithObject:mySorterDescending]];
    [coordinateBottom sortUsingDescriptors:[NSArray arrayWithObject:mySorterAscending]];
    [coordinateTop sortUsingDescriptors:[NSArray arrayWithObject:mySorterDescending]];
   
    /*
    NSArray *subTagCloudViews = [tagCloudView subviews];
    if ([subTagCloudViews count] > 0) {
        NSView *subTagCloudView = [subTagCloudViews objectAtIndex:0];
        CGFloat coordinateLeft, leftHelper;
        leftHelper = 0.0f;
        for (NSView *view in [subTagCloudView subviews]) {
            coordinateLeft = view.frame.origin.x;
            if ((coordinateLeft < leftHelper) || (coordinateLeft = leftHelper)) {
                
            }
            
        }
    
    
    }
    */
    NSPoint origin;
    origin.x = 0;
    origin.y = 0;
    NSSize size;
    size.width = [[coordinateRight objectAtIndex:0] floatValue] - [[coordinateLeft objectAtIndex:0] floatValue]; //right - left;
    size.height = [[coordinateTop objectAtIndex:0] floatValue] - [[coordinateBottom objectAtIndex:0] floatValue]; 
    NSRect result = NSZeroRect;
    result.origin = origin;
    result.size = size;
    
    return result;
    
}

-(NSView *)copyViewsToPrintView:(NSRect)rectToPrint {
    
    NSView *viewToPrint = [[NSView alloc] initWithFrame:rectToPrint];

    NSArray *subTagCloudViews = [tagCloudView subviews];
    NSView *subTagCloudView = [subTagCloudViews objectAtIndex:0];
    
    NSView *viewCopy;
    for (NSView *view in [subTagCloudView subviews]) {
        viewCopy = [view copy];
        [viewToPrint addSubview:viewCopy];
    }
    
    return viewToPrint;
}


- (void)printDocument:(id)sender {
    NSRect rectToPrint = [self coordinatesOfPrintingArea];
    NSView *viewToPrint = [self copyViewsToPrintView:rectToPrint];
    
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
	NSInteger index = [tagTree columnWithIdentifier:@"color"];
	ColorCell *cell = [[[tagTree tableColumns] objectAtIndex:index] dataCell];
	[cell setAction:@selector(pushColor:)];
	[cell setTarget:self];
    

}

@end
