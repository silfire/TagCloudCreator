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
		if (CGRectIntersectsRect(frame, [view frame])) {
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
	[cloudView setFrame:CGRectMake(0, 0, [self frame].size.width, [self frame].size.height)];
	srand(42);
}

- (void)createLabelWithText:(NSString*)text
					   font:(NSFont*)font
					  color:(NSColor*)color
					  frame:(CGRect)frame {
	NSTextField *textField = [[NSTextField alloc] initWithFrame:frame];
	
	[textField setStringValue:text];
	[textField setTextColor:color];
	[textField setFont:font];

	[textField setBezeled:NO];
	[textField setBordered:NO];
	[textField setEditable:NO];
	[textField setBackgroundColor:[NSColor clearColor]];
	[textField setAutoresizingMask:0];
	[cloudView addSubview:textField];
	[textField release];
}

- (CGRect)calculatePositionForString:(NSString*)text withFont:(NSFont*)font {
	NSSize size = [text sizeWithAttributes:
				   [NSDictionary dictionaryWithObjectsAndKeys:
					font, NSFontAttributeName, nil]];
	size.width += 4;
	CGRect superFrame = [cloudView frame];
	CGFloat centerX = superFrame.size.width / 2.0f;
	CGFloat centerY = superFrame.size.height / 2.0f;
	CGRect textFrame;
	
	if ([[cloudView subviews] count]==0) {
		textFrame = CGRectMake(centerX-(size.width / 2.0f), centerY-(size.height / 2.0f), size.width, size.height);
	} else {
		CGFloat angle;
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


#pragma mark Drawing
- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
}

#pragma mark Initialization
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		cloudView = [[[NSView alloc] initWithFrame:frame] autorelease];
		[self addSubview:cloudView];
    }
    return self;
}
- (void)dealloc {
    [super dealloc];
}

@end
