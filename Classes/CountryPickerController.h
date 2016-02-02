//
//  UserPicker.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 10/31/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasePickerController.h"

@protocol CountryPickerDelegate 
	- (void)setCountry:(NSString*)aName code:(NSString*)aCode;	
@end

@interface CountryPickerController : BasePickerController {
    
}

- (id)initWithReciver:(id)aReciver nav:(UINavigationController *)aNav;

@end