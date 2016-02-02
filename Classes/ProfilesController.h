//
//  ProfilesController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h"

@interface ProfilesController : BaseUserTableController {
	NSMutableArray *profilesList;
	UINavigationController *navController;
}

- (id) initWithNavigation:(UINavigationController *)aNav;
- (void) viewDidLoad;
- (void) requestData;
- (void) actionRequestFillProfilesArray:(id)idData;
- (IBAction) actionReload:(id)sender;
- (IBAction) actionEdit:(id)sender;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
