//
//  TagCloudView.m
//  TagCloudCreator
//
//  Created by Ingo Kasprzak on 11.05.11.
//  Copyright 2011 Silutions. All rights reserved.
//

#import "TagCloudView.h"

@implementation TagCloudView
@synthesize cloudView;

#pragma mark Private
-(BOOL)hasCollision:(CGRect)frame {
	BOOL result = NO;
	for (NSView *view in [cloudView subviews]) {
		if (CGRectIntersectsRect(frame, NSRectToCGRect([view frame]))) {
			result = YES;
			break;
		}
	}
	return result;
}

#pragma mark Setup
- (void)clearCloud {
	// Remove old subviews
	NSArray *views = [NSArray arrayWithArray:[cloudView subviews]];
	for (NSView *view in views) [view removeFromSuperview];
	[cloudView setFrame:[self bounds]];
	[cloudView setNeedsDisplay:YES];
	srand(42);
	[tagCache removeAllObjects];
}

- (void)recalculateAllTags {
	NSSize oldSize = [cloudView bounds].size;
	[cloudView setFrame:[self bounds]];
	[cloudView setNeedsDisplay:YES];
	NSSize newSize = [cloudView bounds].size;
	NSSize delta = NSMakeSize(newSize.width-oldSize.width, newSize.height-oldSize.height);

	for (NSView *tagView in tagCache) {
		NSRect frame = [tagView frame];
		frame.origin.x += delta.width/2.0f;
		frame.origin.y += delta.height/2.0f;
		[tagView setFrame:frame];
	}
}

- (void)createLabelWithText:(NSString*)text
					   font:(NSFont*)font
					  color:(NSColor*)color
					  frame:(CGRect)frame 
                   rotation:(CGFloat)rotation {
    
	NSTextField *textField = [[NSTextField alloc] initWithFrame:NSRectFromCGRect(frame)];

	[textField setStringValue:text];
	[textField setTextColor:color];
	[textField setFont:font];
    [textField setFrameRotation:rotation];
    
	[textField setBezeled:NO];
	[textField setBordered:NO];
	[textField setEditable:NO];
	[textField setBackgroundColor:[NSColor clearColor]];
	[textField setAutoresizingMask:0];
    
	[cloudView addSubview:textField];
	[tagCache addObject:textField];

	[textField release];
}

- (CGRect)calculatePositionForString:(NSString*)text withFont:(NSFont*)font {
	NSSize size = [text sizeWithAttributes:
                   [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    
	size.width += 4;
	CGRect superFrame = NSRectToCGRect([cloudView bounds]);
	CGFloat centerX = superFrame.size.width / 2.0f;
	CGFloat centerY = superFrame.size.height / 2.0f;
	CGRect textFrame;
	
	if ([[cloudView subviews] count]==0) {
		textFrame = CGRectMake(centerX-(size.width / 2.0f), centerY-(size.height / 2.0f), size.width, size.height);
	} else {
		CGFloat angle = 0.0f;
		CGFloat distance = 0.0f;
		
		do {
			angle += 5;
			if (angle>=360) {
				angle = rand();
				angle = angle * 360.0f / RAND_MAX;
				distance += 4.0f;
			}
			CGFloat xpos = sinf(2*pi*angle/360.0f) * distance;
			//if (xpos>=0) { xpos+=size.width/2.0f; } else { xpos-=size.width/2.0f; }
			CGFloat ypos = cosf(2*pi*angle/360.0f) * distance;
			//if (ypos>=0) { ypos+=size.height/2.0f; } else { ypos-=size.height/2.0f; }
			textFrame = CGRectMake(centerX-(size.width / 2.0f)+xpos, centerY-(size.height / 2.0f)+ypos, size.width, size.height);
		} while ([self hasCollision:textFrame]);
	}
	return textFrame;
}

- (void)newCreateLabelWithText:(NSString*)text
                          font:(NSFont*)font
                         color:(NSColor*)color
                      rotation:(CGFloat)rotation {
    NSTextField *textField = [[NSTextField alloc] init];
    
	[textField setStringValue:text];
	[textField setTextColor:color];
	[textField setFont:font];
    

    [textField sizeToFit];
    
    NSRect rect = [textField frame];
    NSPoint newOrigin;
    newOrigin.x = rect.size.width/2.0f;
    newOrigin.y = rect.size.height/2.0f;
    [textField setFrameOrigin:newOrigin];
    
    [textField setFrameRotation:rotation];
    
    CGRect superFrame = NSRectToCGRect([cloudView bounds]);
	CGFloat centerX = superFrame.size.width / 2.0f;
	CGFloat centerY = superFrame.size.height / 2.0f;
    CGRect textFrame;
    textFrame.origin.x = rect.origin.x;
    textFrame.origin.y = rect.origin.y;
    textFrame.size.width = rect.size.width;
    textFrame.size.height = rect.size.height;
    
    if ([[cloudView subviews] count]==0) {
		textFrame = CGRectMake(centerX-(textFrame.size.width / 2.0f), centerY-(textFrame.size.height / 2.0f), textFrame.size.width, textFrame.size.height);
	} else {
		CGFloat angle = 0.0f;
		CGFloat distance = 0.0f;
		
		do {
			angle += 5;
			if (angle>=360) {
				angle = rand();
				angle = angle * 360.0f / RAND_MAX;
				distance += 4.0f;
			}
			CGFloat xpos = sinf(2*pi*angle/360.0f) * distance;
			//if (xpos>=0) { xpos+=size.width/2.0f; } else { xpos-=size.width/2.0f; }
			CGFloat ypos = cosf(2*pi*angle/360.0f) * distance;
			//if (ypos>=0) { ypos+=size.height/2.0f; } else { ypos-=size.height/2.0f; }
			textFrame = CGRectMake(centerX-(textFrame.size.width / 2.0f)+xpos, centerY-(textFrame.size.height / 2.0f)+ypos, textFrame.size.width, textFrame.size.height);
		} while ([self hasCollision:textFrame]);
	}
    
    [textField setFrame:textFrame];
    
    [textField setBezeled:NO];
	[textField setBordered:YES];
	[textField setEditable:NO];
	[textField setBackgroundColor:[NSColor clearColor]];
	[textField setAutoresizingMask:0];
    
	[cloudView addSubview:textField];
	[tagCache addObject:textField];
    
	[textField release];
}


#pragma mark Drawing
- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	[self recalculateAllTags];

	[NSGraphicsContext saveGraphicsState];
	[[NSColor whiteColor] set];
    [NSBezierPath fillRect:dirtyRect];
	[[NSColor shadowColor] set];
	[NSBezierPath strokeRect:dirtyRect];
	[NSGraphicsContext restoreGraphicsState];
}
- (BOOL) needsDisplay {
	BOOL result = [super needsDisplay];
/*
	if (result) {
		[self recalculateAllTags];
	}
*/
	return result;
}

#pragma mark Initialization
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		tagCache = [[NSMutableArray alloc] init];
		cloudView = [[[NSView alloc] initWithFrame:frame] autorelease];
		[cloudView setAutoresizingMask: NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
        
		[self addSubview:cloudView];
    }
    
    return self;
}
- (void)dealloc {
	[tagCache release];
    [super dealloc];
}

@end
