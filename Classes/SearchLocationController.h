//
//  SearchLocationController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/11/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchBaseFormController.h"
#import "CountryPickerController.h"

@interface SearchLocationController : SearchBaseFormController <CountryPickerDelegate> {
		
	IBOutlet UITextField *textCountry;
	IBOutlet UITextField *textCity;
	
	IBOutlet UIButton *btnCountry;
	
	NSString *countryName;
	NSString *countryCode;
}

@property (nonatomic, copy) NSString *countryName;
@property (nonatomic, copy) NSString *countryCode;

- (id)init;
- (void)setCountry:(NSString*)aName code:(NSString*)aCode;
- (IBAction)actionSelectCountry:(id)sender;

@end
