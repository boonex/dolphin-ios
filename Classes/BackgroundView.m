//
//  BackgroundView.m
//  Dolphin6
//
//  Created by Alex Trofimov on 24/02/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import "BackgroundView.h"
#import "config.h"

@implementation BackgroundView

- (id)initWithFrame:(CGRect)frame selected:(Boolean)isSelected withSpaces:(Boolean)isWithSpaces {
    self = [super initWithFrame:frame];
    if (self) {
        selected = isSelected;
		withSpaces = isWithSpaces;
		self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;	
}

- (void)dealloc {
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {

    // Drawing with a white stroke color 
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, BX_BORDER_RED, BX_BORDER_GREEN, BX_BORDER_BLUE, BX_BORDER_ALPHA);
    CGContextSetLineWidth(context, BX_BORDER_WIDTH);
	if (selected)
		CGContextSetRGBFillColor(context, BX_TABLE_SEL_RED, BX_TABLE_SEL_GREEN, BX_TABLE_SEL_BLUE, BX_TABLE_SEL_ALPHA); 
	else
		CGContextSetRGBFillColor(context, BX_TABLE_BG_RED, BX_TABLE_BG_GREEN, BX_TABLE_BG_BLUE, BX_TABLE_BG_ALPHA); 
    
    // If you were making this as a routine, you would probably accept a rectangle 
    // that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle. 
    CGFloat fSpaceTop = withSpaces ? BX_SPACE_TOP : 0;
	CGFloat fSpaceBottom = withSpaces ? BX_SPACE_BOTTOM : 0;
    CGFloat f = BX_BORDER_WIDTH/2.0; 
    CGRect rrect = CGRectMake(
                              rect.origin.x + f, 
                              rect.origin.y + f + fSpaceTop, 
                              rect.size.width - f*2.0, 
                              rect.size.height - f*2 - fSpaceTop - fSpaceBottom); 
    CGFloat radius = BX_BORDER_RADIUS; 
    // NOTE: At this point you may want to verify that your radius is no more than half 
    // the width and height of your rectangle, as this technique degenerates for those cases. 
    
    // In order to draw a rounded rectangle, we will take advantage of the fact that 
    // CGContextAddArcToPoint will draw straight lines past the start and end of the arc 
    // in order to create the path from the current position and the destination position. 
    
    // In order to create the 4 arcs correctly, we need to know the min, mid and max positions 
    // on the x and y lengths of the given rectangle. 
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect); 
    
    // Next, we will go around the rectangle in the order given by the figure below. 
    //       minx    midx    maxx 
    // miny    2       3       4 
    // midy   1 9              5 
    // maxy    8       7       6 
    // Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't 
    // form a closed path, so we still need to close the path to connect the ends correctly. 
    // Thus we start by moving to point 1, then adding arcs through each pair of points that follows. 
    // You could use a similar tecgnique to create any shape with rounded corners. 
    
    // Start at 1 
    CGContextMoveToPoint(context, minx, midy); 
    // Add an arc through 2 to 3 
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius); 
    // Add an arc through 4 to 5 
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius); 
    // Add an arc through 6 to 7 
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius); 
    // Add an arc through 8 to 9 
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius); 
    // Close the path 
    CGContextClosePath(context); 
    // Fill & stroke the path 
    CGContextDrawPath(context, kCGPathFillStroke); 

    
/*    
	CGContextRef context = UIGraphicsGetCurrentContext();     
	
	CGFloat fSpaceTop = withSpaces ? BX_SPACE_TOP : 0;
	CGFloat fSpaceBottom = withSpaces ? BX_SPACE_BOTTOM : 0;
	
	// draw background
	
	if (selected)
		CGContextSetRGBFillColor(context, BX_TABLE_SEL_RED, BX_TABLE_SEL_GREEN, BX_TABLE_SEL_BLUE, BX_TABLE_SEL_ALPHA); 
	else
		CGContextSetRGBFillColor(context, BX_TABLE_BG_RED, BX_TABLE_BG_GREEN, BX_TABLE_BG_BLUE, BX_TABLE_BG_ALPHA); 
	
	CGRect rFill = CGRectMake(
						  rect.origin.x, 
						  rect.origin.y + fSpaceTop, 
						  rect.size.width, 
						  rect.size.height - fSpaceTop - fSpaceBottom);
	
	CGContextFillRect(context, rFill); 
	
	// draw border
	
	CGRect rStroke = CGRectMake(
						  rect.origin.x + BX_BORDER_WIDTH/2.0, 
						  rect.origin.y + BX_BORDER_WIDTH/2.0 + fSpaceTop, 
						  rect.size.width - BX_BORDER_WIDTH, 
						  rect.size.height - BX_BORDER_WIDTH - fSpaceTop - fSpaceBottom);
	
	CGContextSetRGBStrokeColor(context, BX_BORDER_RED, BX_BORDER_GREEN, BX_BORDER_BLUE, BX_BORDER_ALPHA); 	
	
	CGContextStrokeRectWithWidth(context, rStroke, BX_BORDER_WIDTH);
 */
}

@end
