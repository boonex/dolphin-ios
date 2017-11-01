//
//  BaseUserTableController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/17/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "BaseUserTableController.h"
#import "BaseUserController.h"
#import "Designer.h"

@implementation BaseUserTableController

@synthesize table;

- (void)viewDidLoad {
    [Designer applyStylesClear:table];
    [Designer applyStylesForTableBackgroundClear:table];
	[Designer applyStylesForScreen:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
	
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [table indexPathForSelectedRow];
	[table deselectRowAtIndexPath:tableSelection animated:NO];
	
	// reload the table data
	[table reloadData];
	
	[super viewWillAppear:animated];	
}

- (void)dealloc {
	[table release];
	[super dealloc];
}


- (void)switchToEditMode:(BOOL)isEditBegin textField:(UIView*)aTextField textCell:(UITableViewCell*)aTextCell offset:(NSInteger)anOffset {	
	if (nil != rightButtonSave && isEditBegin) return;
	if (nil == rightButtonSave && !isEditBegin) return;
	if (isEditBegin == isEditingMode) return;
	
	[aTextCell.superview bringSubviewToFront:aTextCell];	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	
	CGRect frame = aTextCell.frame;
	frame.origin.y += isEditBegin ? -anOffset : anOffset;
	aTextCell.frame = frame;
	
	
	[UIView commitAnimations];
	[self.view setNeedsDisplay];	
	
	[self displayDoneButton:isEditBegin textField:aTextField]; 			
}

@end
