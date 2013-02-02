//
//  SearchLocationController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/11/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h"

@interface SearchBaseFormController : BaseUserController {
	
	IBOutlet UIView *viewContainer;
	
	IBOutlet UILabel *labelOnlineOnly;
	IBOutlet UILabel *labelWithPhotosOnly;
	
	IBOutlet UISwitch *switchOnlineOnly;
	IBOutlet UISwitch *switchWithPhotosOnly;
}

- (id)initWithNibNameOnly:(NSString*)aNibName;

@end
