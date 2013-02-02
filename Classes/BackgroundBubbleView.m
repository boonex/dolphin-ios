//
//  BackgroundBubbleView.m
//  Dolphin6
//
//  Created by Alex Trofimov on 10/03/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import "BackgroundBubbleView.h"
#import "config.h"
#import "Designer.h"

@implementation BackgroundBubbleView

- (id)initWithOrigin:(CGPoint)anOrigin text:(NSString*)aText {
	
	CGSize sz = [Designer sizeForBubbleLabel:aText maxWidth:BX_BUBBLE_WIDTH_MAX maxHeight:BX_BUBBLE_HEIGHT];
	CGRect frame = CGRectMake(anOrigin.x - sz.width - BX_BUBBLE_SPACE*2, anOrigin.y, sz.width + BX_BUBBLE_SPACE*2, BX_BUBBLE_HEIGHT);
	
    self = [super initWithFrame:frame];
    if (self) {
		CGRect frameLabel = CGRectMake(0, 0, frame.size.width, frame.size.height-1.0);
		label = [[UILabel alloc] initWithFrame:frameLabel];
		label.text = aText;
		[Designer applyStylesForLabelBubble:label];
		[self addSubview:label];
		
		self.backgroundColor = [UIColor clearColor];
    }
    return self;	
}

- (void)dealloc {
	[label release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
	
    // Drawing with a white stroke color 
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, BX_BUBBLE_BORDER_RED, BX_BUBBLE_BORDER_GREEN, BX_BUBBLE_BORDER_BLUE, BX_BUBBLE_BORDER_ALPHA);
    CGContextSetRGBFillColor(context, BX_BUBBLE_BG_RED, BX_BUBBLE_BG_GREEN, BX_BUBBLE_BG_BLUE, BX_BUBBLE_BG_ALPHA);
    CGContextSetLineWidth(context, BX_BUBBLE_BORDER_WIDTH);
    
    // If you were making this as a routine, you would probably accept a rectangle 
    // that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle. 
    CGFloat f = BX_BUBBLE_BORDER_WIDTH/2.0; 
    CGRect rrect = CGRectMake(rect.origin.x+f, rect.origin.y+f, rect.size.width-f*2.0, rect.size.height-f*2); 
    CGFloat radius = BX_BUBBLE_BORDER_RADIUS; 
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
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)setText:(NSString*)aText {
	CGSize sz = [Designer sizeForBubbleLabel:aText maxWidth:BX_BUBBLE_WIDTH_MAX maxHeight:BX_BUBBLE_HEIGHT];
	CGPoint origin;
	CGRect frame = self.frame;
	origin.x = frame.origin.x + frame.size.width;
	origin.y = frame.origin.y + frame.size.height;
	frame = CGRectMake(origin.x - sz.width - BX_BUBBLE_SPACE*2, origin.y - BX_BUBBLE_HEIGHT, sz.width + BX_BUBBLE_SPACE*2, BX_BUBBLE_HEIGHT);
	self.frame = frame;
	[self setNeedsDisplay];
	
	frame = CGRectMake(0, 0, frame.size.width, frame.size.height-1.0); 	
	label.frame = frame;
	label.text = aText;
}

@end
