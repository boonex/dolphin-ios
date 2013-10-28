//
//  HomeButtonView.m
//  Dolphin6
//
//  Created by Alex Trofimov on 9/03/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import "HomeButtonView.h"
#import "Designer.h"
#import "AsyncImageView.h"

@implementation HomeButtonView

- (id)initWithOrigin:(CGPoint)anOrigin text:(NSString*)aText imageResource:(NSString*)anImageRes index:(NSInteger)anIndex indexAction:(NSInteger)anIndexAction delegate:(NSObject<HomeButtonViewDelegate> *)aDelegate {
	
	CGRect frame = CGRectMake(anOrigin.x, anOrigin.y, BX_HOME_BUTTON_WIDTH, BX_HOME_BUTTON_HEIGHT);
	
	if ((self = [super initWithFrame:frame])) {
			
		delegate = [aDelegate retain];
		
		index = anIndex;
        indexAction = anIndexAction;
        title = [aText retain];
		
        viewImage = [self createImageView:anImageRes];
		//viewImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:anImageRes]];
		//viewImage.frame = CGRectMake(13, 5, 54, 54);		
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(4, 70, 85, 15)];
		label.text = title;
		[Designer applyStylesForLabelHomeButton:label];
		
		bubble = [[BackgroundBubbleView alloc] initWithOrigin:CGPointMake(BX_HOME_BUTTON_WIDTH-2.0, 2.0) text:@""];
		bubble.hidden = YES;
		
		[self addSubview:viewImage];
		[self addSubview:label];
		[self addSubview:bubble];
		
		[self setUserInteractionEnabled:YES];
		
		[Designer applyStylesForHomeButton:self];
	}
	
	return self; 
}

- (void)dealloc {	
    [title release];
	[viewImage release];
	[label release];
	[bubble release];
	[delegate release];
    [super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)setBubbleText:(NSString*)s {
	if (nil == s || 0 == [s length] || NSOrderedSame == [s compare:@"0"]) {
		bubble.hidden = YES;
	} else {
		[bubble setText:s];
		bubble.hidden = NO;
	}		
}

- (void)clickEvent {
	[delegate homeButtonPressed:index indexAction:indexAction];
}

- (void)changeOrigin:(CGPoint)anOrigin {
    CGRect frame = CGRectMake(anOrigin.x, anOrigin.y, BX_HOME_BUTTON_WIDTH, BX_HOME_BUTTON_HEIGHT);   
    self.frame = frame;
}
/*
- (UIView*)createImageView:(NSString*)sImageName {
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:sImageName]];
    image.frame = CGRectMake(13, 5, 54, 54);    
    return (UIView*)image;
}
*/
- (UIView*)createImageView:(NSString*)sImageName {
    
    if ([sImageName hasPrefix:@"http://"] || [sImageName hasPrefix:@"https://"]) {    
        AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(20, 12, 54, 54)];
        NSURL *url = [[NSURL alloc] initWithString:sImageName];
        [asyncImage loadImageFromURL:url];
        [asyncImage setUserInteractionEnabled:NO];
        return (UIView*)asyncImage;
    } else {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:sImageName]];
        image.frame = CGRectMake(20, 12, 54, 54);    
        [image setUserInteractionEnabled:NO];
        return (UIView*)image;    
    }
}


/**********************************************************************************************************************
 TOUCHES FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Touches Functions

- (void)swapHomeBtnBg:(BOOL)isSelected {
    if (isSelected) {
        UIView *vSelected = [self viewWithTag:BX_DESIGNER_BG_TAG_SEL];
        vSelected.alpha = 1;
        
        UIView *v = [self viewWithTag:BX_DESIGNER_BG_TAG];
        [self sendSubviewToBack:v];
    } else {
        UIView *vSelected = [self viewWithTag:BX_DESIGNER_BG_TAG_SEL];
        vSelected.alpha = 0;
        [self sendSubviewToBack:vSelected];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self swapHomeBtnBg:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self swapHomeBtnBg:NO];
	
    UITouch *touch = [touches anyObject]; 
    if([touch tapCount] == 1) {
        [self clickEvent];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self swapHomeBtnBg:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self swapHomeBtnBg:NO];
}

- (NSString*)getTitle {
    return title;
}

@end
