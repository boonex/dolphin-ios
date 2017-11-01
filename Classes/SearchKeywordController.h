//
//  SearchLocationController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/11/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchBaseFormController.h"

@interface SearchKeywordController : SearchBaseFormController {
	IBOutlet UITextField *textKeyword;
}

- (id)init;

@end
