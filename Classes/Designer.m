//
//  Designer.m
//  Dolphin6
//
//  Created by Alex Trofimov on 24/02/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Designer.h"
#import "config.h"
#import "BackgroundView.h"
#import "ProfileBlock.h"

@implementation Designer

+ (void)applyStylesForCell:(UITableViewCell*)cell {	
}

+ (void)applyStylesForContainer:(UIView*)view {
	UIView *viewBackground = [[[BackgroundView alloc] initWithFrame:view.bounds selected:false withSpaces:false] autorelease];
	viewBackground.backgroundColor = [UIColor clearColor];
    view.backgroundColor = [UIColor clearColor];
	[view addSubview:viewBackground];
	[view sendSubviewToBack:viewBackground];
}

+ (void)applyStylesClear:(UIView*)view {
    view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
}

+ (void)applyStylesForScreen:(UIView*)view {
	if ([BX_SCREEN_BG_IMAGE isEqualToString:@""])	
		view.backgroundColor = [UIColor colorWithRed:BX_SCREEN_BG_RED green:BX_SCREEN_BG_GREEN blue:BX_SCREEN_BG_BLUE alpha:BX_SCREEN_BG_ALPHA];
	else
		view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BX_SCREEN_BG_IMAGE]];
}

+ (void)applyStylesForTableBackgroundClear:(UITableView*)table {
    if ([table respondsToSelector:@selector(setBackgroundView:)])
        [table setBackgroundView:nil];
}

+ (void)applyStylesForLabel:(UILabel*)label {
	label.font = [UIFont boldSystemFontOfSize:16];
	label.textColor = [UIColor colorWithRed:BX_TEXT_RED green:BX_TEXT_GREEN blue:BX_TEXT_BLUE alpha:BX_TEXT_ALPHA];
	label.backgroundColor = [UIColor clearColor];
}

+ (void)applyStylesForLabelTitle:(UILabel*)label {
	[self applyStylesForLabel:label];
}

+ (void)applyStylesForLabelDesc:(UILabel*)label {
	[self applyStylesForLabel:label];
	label.font = [UIFont boldSystemFontOfSize:12];
}

+ (void)applyStylesForLabelNew:(UILabel*)label {
	label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
	label.textColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
	label.font = [UIFont boldSystemFontOfSize:12];
}

+ (void)applyStylesForTextEdit:(UITextField*)textEdit {
	textEdit.font = [UIFont boldSystemFontOfSize:17];
    textEdit.textColor = [UIColor colorWithRed:BX_TEXT_INPUT_RED green:BX_TEXT_INPUT_GREEN blue:BX_TEXT_INPUT_BLUE alpha:BX_TEXT_INPUT_ALPHA];
	if (textEdit.borderStyle != UITextBorderStyleRoundedRect)
		textEdit.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
}

+ (void)applyStylesForTextArea:(UITextView*)textArea {
	textArea.font = [UIFont boldSystemFontOfSize:14];
    textArea.textColor = [UIColor colorWithRed:BX_TEXT_AREA_RED green:BX_TEXT_AREA_GREEN blue:BX_TEXT_AREA_BLUE alpha:BX_TEXT_AREA_ALPHA];
	textArea.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];    
    textArea.layer.borderWidth = 1;
    textArea.layer.cornerRadius = 6;
    textArea.layer.borderColor = [[UIColor grayColor] CGColor];
}

+ (void)applyStylesForWebView:(UIWebView*)webView {
    webView.layer.borderWidth = 1;
    webView.layer.borderColor = [[UIColor grayColor] CGColor];
}

+ (void)applyStylesForButton:(UIButton*)btn {

}

+ (void)applyStylesForErrorMessageInsideThumbnail:(UILabel*)label {
	label.font = [UIFont systemFontOfSize:10];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
	label.numberOfLines = 0;
}

+ (void)applyStylesForSegmentedControl:(UISegmentedControl*)segmentedControl {
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    //segmentedControl.tintColor = [UIColor blackColor];
}


/**********************************************************************************************************************
 HOME BUTTONS STYLES
 **********************************************************************************************************************/

#pragma mark - Home buttons styles

+ (void)applyStylesForLabelHomeButton:(UILabel*)label {
	label.font = [UIFont boldSystemFontOfSize:13.0];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor colorWithRed:BX_HOME_TEXT_RED green:BX_HOME_TEXT_GREEN blue:BX_HOME_TEXT_BLUE alpha:BX_HOME_TEXT_ALPHA];
	label.backgroundColor = [UIColor clearColor];	
}

+ (void)applyStylesForHomeButtonCustom:(UIView*)view r:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue a:(CGFloat)alpha {
	UIView *viewBackground = [[[BackgroundView alloc] initWithFrameCustom:view.bounds withSpaces:false r:red g:green b:blue a:alpha] autorelease];
	viewBackground.backgroundColor = [UIColor clearColor];
	viewBackground.tag = BX_DESIGNER_BG_TAG;
	[view addSubview:viewBackground];
	[view sendSubviewToBack:viewBackground];
    
	UIView *viewBackgroundSel = [[[BackgroundView alloc] initWithFrameHome:view.bounds selected:true withSpaces:false] autorelease];
	viewBackgroundSel.backgroundColor = [UIColor clearColor];
	viewBackgroundSel.tag = BX_DESIGNER_BG_TAG_SEL;
    viewBackgroundSel.alpha = 0;
	[view addSubview:viewBackgroundSel];
	[view sendSubviewToBack:viewBackgroundSel];
    
}

+ (void)applyStylesForHomeButton:(UIView*)view {

	UIView *viewBackground = [[[BackgroundView alloc] initWithFrameHome:view.bounds selected:false withSpaces:false] autorelease];
	viewBackground.backgroundColor = [UIColor clearColor];
	viewBackground.tag = BX_DESIGNER_BG_TAG;
	[view addSubview:viewBackground];
	[view sendSubviewToBack:viewBackground];

	UIView *viewBackgroundSel = [[[BackgroundView alloc] initWithFrameHome:view.bounds selected:true withSpaces:false] autorelease];
	viewBackgroundSel.backgroundColor = [UIColor clearColor];
	viewBackgroundSel.tag = BX_DESIGNER_BG_TAG_SEL;
    viewBackgroundSel.alpha = 0;
	[view addSubview:viewBackgroundSel];
	[view sendSubviewToBack:viewBackgroundSel];
}

+ (void)applyStylesForLabelBubble:(UILabel*)label {
	label.font = [UIFont boldSystemFontOfSize:12.0];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor colorWithRed:BX_BUBBLE_TEXT_RED green:BX_BUBBLE_TEXT_GREEN blue:BX_BUBBLE_TEXT_BLUE alpha:BX_BUBBLE_TEXT_ALPHA];
	label.backgroundColor = [UIColor clearColor];	
	label.lineBreakMode = UILineBreakModeTailTruncation;
}

+ (CGSize)sizeForBubbleLabel:(NSString*)s maxWidth:(CGFloat)fMaxWidth maxHeight:(CGFloat)fMaxHeight {
	return [s sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(fMaxWidth, fMaxHeight) lineBreakMode:UILineBreakModeTailTruncation];
}

/**********************************************************************************************************************
 PROFILE STATUS STYLES
 **********************************************************************************************************************/

#pragma mark - Profile Status styles

+ (void)applyStylesForLabelStatus:(UILabel*)label {
	[self applyStylesForLabel:label];
	label.lineBreakMode = UILineBreakModeWordWrap;
	label.font = [UIFont systemFontOfSize:12.0];
}

+ (CGSize)sizeForProfileStatusLabel:(NSString*)s maxWidth:(CGFloat)fMaxWidth maxHeight:(CGFloat)fMaxHeight {
	return [s sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(fMaxWidth, fMaxHeight) lineBreakMode:UILineBreakModeWordWrap];
}

/**********************************************************************************************************************
 PROFILE INFO STYLES
 **********************************************************************************************************************/

#pragma mark - Profile Info styles

+ (void)applyStylesForLabelProfileInfoCaption:(UILabel*)label {	
	[self applyStylesForLabel:label];
	label.font = [UIFont boldSystemFontOfSize:16];
	label.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
}

+ (CGSize)sizeForLabelProfileInfoCaption:(NSString*)s maxWidth:(CGFloat)fMaxWidth maxHeight:(CGFloat)fMaxHeight {
	return [s sizeWithFont:[UIFont boldSystemFontOfSize:16.0] constrainedToSize:CGSizeMake(fMaxWidth, fMaxHeight) lineBreakMode:UILineBreakModeTailTruncation];
}

+ (void)applyStylesForLabelProfileInfo:(UILabel*)label {
	[self applyStylesForLabel:label];
	label.lineBreakMode = UILineBreakModeTailTruncation;
	label.font = [UIFont systemFontOfSize:13.0];
}

+ (CGSize)sizeForProfileInfo:(NSString*)s maxWidth:(CGFloat)fMaxWidth maxHeight:(CGFloat)fMaxHeight {
	return [s sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(fMaxWidth, fMaxHeight) lineBreakMode:UILineBreakModeTailTruncation];
}

+ (void)applyStylesForLabelProfileInfoArea:(UILabel*)label {
	[self applyStylesForLabel:label];
    label.numberOfLines = 0;
	label.lineBreakMode = UILineBreakModeTailTruncation;
	label.font = [UIFont systemFontOfSize:13.0];
}

+ (CGSize)sizeForProfileInfoArea:(NSString*)s maxWidth:(CGFloat)fMaxWidth maxHeight:(CGFloat)fMaxHeight {
	return [s sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(fMaxWidth, fMaxHeight) lineBreakMode:UILineBreakModeTailTruncation];
}

/**********************************************************************************************************************
 TOOLBAR STYLES
 **********************************************************************************************************************/

+ (void)applyStylesForTabbar:(UITabBar*)tabBar orientation:(UIInterfaceOrientation)interfaceOrientation {
}

@end
