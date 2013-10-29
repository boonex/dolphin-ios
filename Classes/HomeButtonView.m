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
		
        viewImage = [self createImageView:[self imageFromString:anImageRes]];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(4, 70, 85, 15)];
		label.text = title;
		[Designer applyStylesForLabelHomeButton:label];
		
		bubble = [[BackgroundBubbleView alloc] initWithOrigin:CGPointMake(BX_HOME_BUTTON_WIDTH-2.0, 2.0) text:@""];
		bubble.hidden = YES;
		
		[self addSubview:viewImage];
		[self addSubview:label];
		[self addSubview:bubble];
		
		[self setUserInteractionEnabled:YES];
        
        NSString *sCustomColor = [self colorsFromString:anImageRes];
        CGFloat fRed = 0, fGreen = 0, fBlue = 0, fAlpha = 0;
        
        if (nil != sCustomColor) {
            fRed = [self colorFromString:sCustomColor index:0 default:0.3];
            fGreen = [self colorFromString:sCustomColor index:1 default:0.3];
            fBlue = [self colorFromString:sCustomColor index:2 default:0.3];
            fAlpha = [self colorFromString:sCustomColor index:3 default:1.0];
        } else {
            NSDictionary *colors = [NSDictionary
                                    dictionaryWithObjects: [NSArray arrayWithObjects:
                                            @"194,7,86",  // status
                                            @"207,60,25", // location
                                            @"43,104,32", // messages
                                            @"86,156,0",  // friends
                                            @"186,188,0", // info
                                            @"218,128,0", // search
                                            @"9,54,176",  // images
                                            @"0,146,148", // sounds
                                            @"0,143,184", // videos
                                            nil]
                                    forKeys:[NSArray arrayWithObjects:
                                             @"home_status.png",
                                             @"home_location.png",
                                             @"home_messages.png",
                                             @"home_friends.png",
                                             @"home_info.png",
                                             @"home_search.png",
                                             @"home_images.png",
                                             @"home_sounds.png",
                                             @"home_videos.png",
                                             nil]];
            NSString *sColor = [colors valueForKey:anImageRes];
            if (nil != sColor) {
                fRed = [self colorFromString:sColor index:0 default:0.3];
                fGreen = [self colorFromString:sColor index:1 default:0.3];
                fBlue = [self colorFromString:sColor index:2 default:0.3];
                fAlpha = [self colorFromString:sColor index:3 default:1.0];
            }
        }
        
        if (0 == fRed && 0 == fGreen && 0 == fBlue && 0 == fAlpha)
            [Designer applyStylesForHomeButton:self];
        else
            [Designer applyStylesForHomeButtonCustom:self r:fRed g:fGreen b:fBlue a:fAlpha];
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

- (NSString*)colorsFromString:(NSString*)s {
    NSRange range = [s rangeOfString:@"("];
    if (range.location == NSNotFound)
        return nil;
    return [s substringFromIndex:range.location];
}

- (NSString*)imageFromString:(NSString*)s {
    NSRange range = [s rangeOfString:@"("];
    if (range.location == NSNotFound)
        return s;
    return [s substringToIndex:range.location];
}

- (CGFloat)colorFromString:(NSString*)s index:(int)i default:(CGFloat)fDefValue {
    NSString *ss = [s stringByReplacingOccurrencesOfString:@"(" withString:@""];
    ss = [ss stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSArray *a = [ss componentsSeparatedByString:@","];
    if (nil == a)
        return fDefValue;
    if (i < 0 || i > ([a count]-1))
        return fDefValue;
    ss = [a objectAtIndex:i];
    ss = [ss stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    int iColor = [ss intValue];
    if (iColor > 255 || iColor < 0)
        return fDefValue;
    return iColor/255.0;
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
