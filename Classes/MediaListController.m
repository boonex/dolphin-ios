//
//  ImagesListController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/27/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "MediaListController.h"
#import "Dolphin6AppDelegate.h"
#import "ImageIconBlock.h"
#import "MediaPlayerController.h"
#import "Designer.h"

@implementation MediaListController

@synthesize isReloadRequired;

- (id)initWithProfile:(NSString*)aProfile album:(NSString*)anAlbum nav:(UINavigationController*)aNav {
	if ((self = [super initWithNibName:@"MediaListView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
		profile = [aProfile copy];
		album = [anAlbum copy];
		navController = aNav;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self requestMedia];
}

- (void)viewWillAppear:(BOOL)animated {
	if (isReloadRequired)
		[self reloadData];
	[super viewWillAppear:animated];	
}

- (void)dealloc {
	[mediaList release];
	[profile release];
	[album release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom functions

- (void)requestMedia {	
	
	if (nil == mediaList) {
		NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, profile, album, nil];
		[self addProgressIndicator];
		[user.connector execAsyncMethod:method withParams:myArray withSelector:@selector(actionRequestMedia:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
	}
	
}

- (void)reloadData {
	[mediaList release];
	mediaList = nil;
	[self requestMedia];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions
	
/**
 * callback function on contacts list request 
 */
- (void)actionRequestMedia:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self responce:resp];
		return;
	}
	
	NSLog(@"media in album (%@): %@", album, resp);
	
	mediaList = [resp retain];
	isReloadRequired = NO;
	
	[table reloadData];
	
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
	return [mediaList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	
	ImageIconBlock *cell;
	
	NSMutableDictionary *dict = [mediaList objectAtIndex:indexPath.row];
	cell = [dict valueForKey:@"Cell"];
	if (cell != nil)
		return cell;
	
	NSString* title = [dict valueForKey:@"title"];
	NSString* thumb = [dict valueForKey:@"thumb"];
	NSString* desc = [dict valueForKey:@"desc"];
	NSString* rate = [dict valueForKey:@"rate"];
	
	cell = [[[ImageIconBlock alloc] initWithData:dict reuseIdentifier:nil] autorelease];
	[cell setTitle:title iconUrl:thumb desc:desc rate:rate];

	[dict setValue:cell forKey:@"Cell"];
	
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableDictionary *dict = [mediaList objectAtIndex:indexPath.row];
	NSString* strUrl = [dict valueForKey:@"file"];
    
    UIViewController *ctrl = [[MediaPlayerController alloc] initWithUrl:strUrl nav:navController];
    [navController pushViewController:ctrl animated:YES];
    [ctrl release];    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [ImageIconBlock getHeight];
}

@end
