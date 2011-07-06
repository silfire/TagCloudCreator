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
	NSMutableArray *tagCache;
}

@property (nonatomic, assign) IBOutlet NSView* cloudView;

- (void)clearCloud;

- (void)createLabelWithText:(NSString*)text
					   font:(NSFont*)font
					  color:(NSColor*)color
					  frame:(CGRect)frame
                   rotation:(CGFloat)rotation;

- (void)newCreateLabelWithText:(NSString*)text
                          font:(NSFont*)font
                         color:(NSColor*)color
                      rotation:(CGFloat)rotation;

- (CGRect)calculatePositionForString:(NSString*)text withFont:(NSFont*)font;

- (void)recalculateAllTags;
@end
