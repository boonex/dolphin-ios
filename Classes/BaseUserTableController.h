//
//  BaseUserTableController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/17/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserController.h"


@interface BaseUserTableController : BaseUserController {
	IBOutlet UITableView *table;
	IBOutlet UIImageView *tableImage;
}

@property (nonatomic, retain) UITableView *table;

- (void)switchToEditMode:(BOOL)isEditBegin textField:(UIView*)aTextField textCell:(UITableViewCell*)aTextCell offset:(NSInteger)anOffset;

@end
