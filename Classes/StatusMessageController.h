//
//  StatusMessageController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/4/09.
//  Copyright 2009 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h"

@interface StatusMessageController : BaseUserController {
	IBOutlet UILabel *labelStatusMessage;
	IBOutlet UITextField *textStatusMessage;
	IBOutlet UIView *viewContainer;
	NSString *status;
}

- (id)initWithStatusMessage: (NSString*)aStatus;

@end
