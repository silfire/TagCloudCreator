//
//  ColorCell.m
//  TagCloudCreator
//
//  Created by Ingo Kasprzak on 11.05.11.
//  Copyright 2011 Silutions. All rights reserved.
//

#import "ColorCell.h"

@interface ColorCell ()
@property (readwrite, retain) NSColorWell *colorWell;
@end

@implementation ColorCell
@synthesize color, colorWell;

- (void)setObjectValue:(id <NSCopying>)object {
    self.color = [[object copyWithZone:nil] autorelease];
}

- (id)objectValue {
	return self.color;
}

- (void)dealloc {
    [color release];
	[colorWell release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    ColorCell *cell = (ColorCell *)[super copyWithZone:zone];
	cell->colorWell = nil;
	cell->color = [self.color copyWithZone:zone];
	[cell setTarget:[self target]];
	[cell setAction:[self action]];
    return cell;
}

/*
// Den Inhalt der Zelle bauen (überschriebene NSCell-Methode)
- (void)drawInteriorWithFrame :(NSRect)cellFrame inView :(NSView *)controlView {
	
	// Falls kein Control vorhanden ist, dann wird eins erstellt
    if (self.colorWell == nil) {
		self.colorWell = [[NSColorWell alloc] initWithFrame:cellFrame];
	} else {
		[self.colorWell setFrame:cellFrame];
	}

	[self.colorWell setColor:self.color];
	
	// Hat das Control einen SuperView? Sonst hinzufügen.
	if ([self.colorWell superview] == nil) {
        [controlView addSubview:self.colorWell];
	}
	
}
*/

- (NSRect)createColorSquareInFrame:(NSRect)frame {
	NSRect square = NSInsetRect (frame, 0.5, 0.5);
	
	// use the smallest size to sqare off the box & center the box
	if (square.size.height < square.size.width) {
		square.size.width = square.size.height;
		square.origin.x = square.origin.x + (frame.size.width - 
											 square.size.width) / 2.0;
	} else {
		square.size.height = square.size.width;
		square.origin.y = square.origin.y + (frame.size.height - 
											 square.size.height) / 2.0;
	}
	return square;
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
	NSUInteger result = 0;

	
	NSRect square = [self createColorSquareInFrame:cellFrame];
	NSPoint event_location = [event locationInWindow];
	NSPoint point = [controlView convertPoint:event_location fromView:nil];

	if (CGRectContainsPoint(NSRectToCGRect(square), NSPointToCGPoint(point))) {
		result = NSCellHitContentArea;
	}
	
	if (result && [event type]== NSLeftMouseUp) {
		[[self target] performSelector:[self action] withObject:controlView];
	}
	
	if (!result) {
		result = [super hitTestForEvent:event inRect:cellFrame ofView:controlView];
	}
	
	return result;
	// return NSCellHitContentArea;
}

- (void) drawInteriorWithFrame:(NSRect)cellFrame
				inView:(NSView*)controlView {

	NSRect square = [self createColorSquareInFrame:cellFrame];
	
	[[NSColor blackColor] set];
	[NSBezierPath strokeRect: square];
	
	if (self.color) {
		[self.color set];	
		[NSBezierPath fillRect: NSInsetRect (square, 2.0, 2.0)];
	}
}

@end
