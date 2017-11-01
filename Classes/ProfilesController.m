//
//  ProfilesController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "ProfilesController.h"
#import "ProfileController.h"
#import "ProfileIconBlock.h"
#import "DataButton.h"
#import "Designer.h"

@implementation ProfilesController

- (id)initWithNavigation:(UINavigationController *)aNav {
	if ((self = [super initWithNibName:@"ProfilesView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
		navController = aNav;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self requestData];	
}

- (void)dealloc {
	[profilesList release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void) requestData {
	
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

- (void)actionRequestFillProfilesArray:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	    
	NSLog(@"profiles list: %@", resp);

    if([resp isKindOfClass:[NSDictionary class]] && nil != [(NSDictionary *)resp objectForKey:@"error"]) {        
        [BxConnector showDictErrorAlertWithDelegate:self responce:resp];
        return;
    }
    
    if (profilesList != nil) {
        [profilesList release];
        profilesList = nil;
    }
    
	profilesList = [resp retain];
	[table reloadData];
}

/**
 * reload data
 */
- (IBAction)actionReload:(id)sender {
	[self requestData];
}

/**
 * switch to edit mode
 */
- (IBAction)actionEdit:(id)sender {
	if (YES == table.editing) {
		[table setEditing:NO animated:YES];
		self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Edit", @"Edit button title");
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
	} else {
		
		[table setEditing:YES animated:YES];
		self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Done", @"Done button title");
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
	}			
}

/**********************************************************************************************************************
 DELEGATES: UITableView
 **********************************************************************************************************************/

#pragma mark - UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return nil == profilesList ? 0 : [profilesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	
	ProfileIconBlock *cell;
	
	NSMutableDictionary *dict = [profilesList objectAtIndex:indexPath.row];
	cell = [dict valueForKey:@"Cell"];
	if (cell != nil)
		return cell;
	    
	NSString* nick = [dict valueForKey:@"Nick"];
	NSString* icon = [dict valueForKey:@"Thumb"];	
    NSString* title = [Dolphin6AppDelegate formatUserTitle:dict];
	NSString* info = [Dolphin6AppDelegate formatUserInfo:dict];
	NSString* location = [Dolphin6AppDelegate formatUserLocation:dict];
    
	cell = [[[ProfileIconBlock alloc] initWithData:dict reuseIdentifier:nil] autorelease];
	[cell setProfile:nick title:title iconUrl:icon info:info location:location];
	
	[dict setValue:cell forKey:@"Cell"];
	
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableDictionary *dict = [profilesList objectAtIndex:indexPath.row];
	NSString* nick = [dict valueForKey:@"Nick"];
	ProfileController * ctrl = [[ProfileController alloc] initWithProfile:nick nav:navController];
	[navController pushViewController:ctrl animated:YES];			
	[ctrl release];			
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [ProfileIconBlock getHeight];
}

@end
