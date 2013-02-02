//
//  BaseUserThumbTableController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/6/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h" 

@class ProfileBlock;

@interface BaseUserThumbTableController : BaseUserTableController {
	ProfileBlock *cellProfileBlock;
}

@end
