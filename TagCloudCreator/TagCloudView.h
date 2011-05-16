//
//  TagCloudView.h
//  TagCloudCreator
//
//  Created by Ingo Kasprzak on 11.05.11.
//  Copyright 2011 Silutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TagCloudView : NSView {
@private
	NSView* cloudView;
}
@property (nonatomic, assign) IBOutlet NSView* cloudView;

- (void)clearCloud;

- (void)createLabelWithText:(NSString*)text
					   font:(NSFont*)font
					  color:(NSColor*)color
					  frame:(CGRect)frame;

- (CGRect)calculatePositionForString:(NSString*)text withFont:(NSFont*)font;

@end
