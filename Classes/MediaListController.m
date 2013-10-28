//
//  MediaListController.m
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

- (id)initWithProfile:(NSString*)aProfile album:(NSString*)anAlbum albumName:(NSString*)anAlbumName albumDefault:(BOOL)isDefault nav:(UINavigationController*)aNav
{
	if ((self = [super initWithNibName:@"MediaListView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
		profile = [aProfile copy];
		album = [anAlbum copy];
        albumName = [anAlbumName copy];
		navController = aNav;
        isAlbumDefault = isDefault;
        isEditAllowed = true;
        isAddAllowed = true;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	if ([profile isEqualToString:user.strUsername])
	{
        if (isEditAllowed && isAddAllowed) {
            UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems:
                                                     [NSArray arrayWithObjects:
                                                      [UIImage imageNamed:@"icon_conf.png"],
                                                      [UIImage imageNamed:@"icon_add.png"],
                                                      nil]] autorelease];
            [segmentedControl addTarget:self action:@selector(actionEditAdd:) forControlEvents:UIControlEventValueChanged];
            segmentedControl.frame = CGRectMake(0, 0, 90, 30);
            segmentedControl.momentary = YES;
        
            [Designer applyStylesForSegmentedControl:segmentedControl];
            
            UIBarButtonItem *segmentBarItem = [[[UIBarButtonItem alloc] initWithCustomView:segmentedControl] autorelease];
            self.navigationItem.rightBarButtonItem = segmentBarItem;
            
        } else if (isEditAllowed && !isAddAllowed) {
            UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_conf.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(actionEdit:)];
            self.navigationItem.rightBarButtonItem = btn;
            [btn release];
        }
	}
    
    self.navigationItem.title = albumName;
    
	[self requestMedia];
}

- (void)viewWillAppear:(BOOL)animated
{
	if (isReloadRequired)
		[self reloadData];
	[super viewWillAppear:animated];	
}

- (void)dealloc
{
	[mediaList release];
	[profile release];
	[album release];
    [indexPathForRemoving release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom functions

- (void)requestMedia
{
	
	if (nil == mediaList) {
		NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, profile, album, nil];
		[self addProgressIndicator];
		[user.connector execAsyncMethod:method withParams:myArray withSelector:@selector(actionRequestMedia:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
	}
	
}

- (void)requestRemoveMedia:(NSString*)sMediaId
{
	
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, sMediaId, nil];
	[self addProgressIndicator];
	[user.connector execAsyncMethod:methodRemove withParams:myArray withSelector:@selector(actionRequestRemoveMedia:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
	
}

- (void)reloadData
{
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
- (void)actionRequestMedia:(id)idData
{
	
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

- (void)actionRequestRemoveMedia:(id)idData
{
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];

    NSLog(@"remove media: %@", resp);
    
	// if error occured
	if ([resp isKindOfClass:[NSError class]]) {
		[BxConnector showErrorAlertWithDelegate:self responce:resp];
		return;
	} else if ([resp isKindOfClass:[NSDictionary class]]) {
        [BxConnector showDictErrorAlertWithDelegate:self responce:resp];
        return;
    }
	
	NSString *strResult = resp;
	if ([resp isKindOfClass:[NSString class]] && [strResult isEqualToString:@"ok"] && indexPathForRemoving != nil) {
		[mediaList removeObjectAtIndex:indexPathForRemoving.row];
		[table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathForRemoving] withRowAnimation:YES];
		[indexPathForRemoving release];
		indexPathForRemoving = nil;
		
		// app.homeImages.isReloadRequired = YES;  - TODO:
	}
}

- (void)actionDone:(id)sender
{
	if (YES != table.editing)
        return;
    
    [table setEditing:NO animated:YES];
	self.navigationItem.rightBarButtonItem = rightButtonSave2;
	[rightButtonSave2 release];
	rightButtonSave2 = nil;
}

- (void)actionEdit:(id)sender {
    if (YES != table.editing) {
        [table setEditing:YES animated:YES];
        rightButtonSave2 = [self.navigationItem.rightBarButtonItem retain];
        UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done button title") style:UIBarButtonItemStyleDone target:self action:@selector(actionDone:)];
        self.navigationItem.rightBarButtonItem = btn2;
        [btn2 release];
    }
}

- (void)actionEditAdd:(id)sender
{
	UISegmentedControl* segCtl = sender;
	
	NSInteger buttonIndex = [segCtl selectedSegmentIndex];
	switch (buttonIndex)
	{
		case 0:
            [self actionEdit:sender];
			break;
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
	return [mediaList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
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

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *dict = [mediaList objectAtIndex:indexPath.row];
	NSString* strUrl = [dict valueForKey:@"file"];
    
    UIViewController *ctrl = [[MediaPlayerController alloc] initWithUrl:strUrl nav:navController];
    [navController pushViewController:ctrl animated:YES];
    [ctrl release];    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [ImageIconBlock getHeight];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if (editingStyle != UITableViewCellEditingStyleDelete)
		return;
	
	NSLog(@"Deleting row: %d", indexPath.row);
	
	NSMutableDictionary *dict = [mediaList objectAtIndex:indexPath.row];
	NSString* sId = [dict valueForKey:@"id"];
	indexPathForRemoving = [indexPath retain];
	[self requestRemoveMedia:sId];
}

@end
