//
//  ImagesHomeController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/26/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "MediaAlbumsController.h"
#import "Dolphin6AppDelegate.h"
#import "Designer.h"

@implementation MediaAlbumsController

@synthesize isReloadRequired, navContrioller;

- (id)initWithProfile:(NSString*)aProfile title:(NSString*)aProfileTitle nav:(UINavigationController*)aNav {    
	if ((self = [super initWithNibName:@"ImagesAlbumsView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
		profile = [aProfile copy];
		profileTitle = [aProfileTitle copy];
		navContrioller = aNav;
	}
	return self;
}

- (id)initWithProfile:(NSString*)aProfile nav:(UINavigationController*)aNav {
    return [self initWithProfile:aProfile title:aProfile nav:aNav];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
	// right nav item
	UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reload", @"Reload button title") style:UIBarButtonItemStyleBordered target:self action:@selector(actionReload:)];
	self.navigationItem.rightBarButtonItem = btn2;
	[btn2 release];
	
	[self requestData];
}

- (void)viewWillAppear:(BOOL)animated {
	if (isReloadRequired)
		[self reloadData];
	[super viewWillAppear:animated];	
}

- (void)dealloc {
	[profile release];
	[catList release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom functions

- (void)reloadData {
	[catList release];
	catList = nil;
	[self requestData];
}

- (void)requestData {	
	
	if (nil == catList) {
		NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, profile, nil];
		[self addProgressIndicator];
		[user.connector execAsyncMethod:method withParams:myArray withSelector:@selector(actionRequestData:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
	}
	
}


/**********************************************************************************************************************
 DELEGATES
 **********************************************************************************************************************/

#pragma mark - UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [catList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	
	NSDictionary *dict = [catList objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [dict valueForKey:@"Title"], [dict valueForKey:@"Num"]];
	
	[Designer applyStylesForCell:cell];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return BX_TABLE_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

- (void)actionRequestData:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self responce:resp];
		return;
	}
	
    NSLog(@"media albums (%@): %@", [resp class], resp);
    
    if([resp isKindOfClass:[NSDictionary class]] && nil != [(NSDictionary *)resp objectForKey:@"error"]) {        
        [BxConnector showDictErrorAlertWithDelegate:self responce:resp];
        return;
    }	
	
	catList = [resp retain];
	isReloadRequired = NO;
	
	[table reloadData];
}

- (void)actionReload:(id)idData {
	[self reloadData];
}

@end
