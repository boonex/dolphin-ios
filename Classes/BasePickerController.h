//
//  UserPicker.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 10/31/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h"

@interface BasePickerController : BaseUserTableController <UITableViewDelegate, UITableViewDataSource> {	
	id reciver;
	NSMutableArray *dataList;
	NSArray *indexList;
	NSMutableDictionary *lettersDict;
	NSString* nameKey;
	UINavigationController *navController;
}

@property (nonatomic, retain) id reciver;

- (id)initWithReciver:(id)aReciver nav:(UINavigationController *)aNav;
- (void)requestData;
- (void)buildIndex;

@end
