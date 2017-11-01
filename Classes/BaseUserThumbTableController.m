//
//  BaseUserThumbTableController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/6/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "BaseUserThumbTableController.h"
#import "BaseUserTableController.h"
#import "ProfileBlock.h"
#import "Designer.h"

@implementation BaseUserThumbTableController

- (void)viewDidLoad {
	[super viewDidLoad];
    
    [Designer applyStylesClear:table];
	[Designer applyStylesForScreen:self.view];
}

- (void)dealloc {
	[cellProfileBlock release];
	[super dealloc];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (0 == indexPath.row && 0 == indexPath.row) {		
		return nil;
	}
	return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case 0:
			return BX_TABLE_CELL_HEIGHT_THUMB;
		default:
			return BX_TABLE_CELL_HEIGHT;
	}
}

@end
