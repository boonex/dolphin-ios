//
//  UserPicker.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 10/31/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasePickerController.h"

@protocol UserPickerDelegate 
    - (void)setRecipient:(NSString*)sRecipient title:(NSString*)sRecipientTitle;    
@end

@interface UserPickerController : BasePickerController {

}

@end
