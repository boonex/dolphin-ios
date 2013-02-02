//
//  ImagesListController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/27/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "ImagesListController.h"
#import "Dolphin6AppDelegate.h"
#import "ImageIconBlock.h"
#import "ImagesController.h"
#import "ImageAddController.h"
#import "ImagesAlbumsController.h"
#import "Designer.h"

@implementation ImagesListController

@synthesize isReloadRequired;

- (id)initWithProfile:(NSString*)aProfile album:(NSString*)anAlbum albumName:(NSString*)anAlbumName nav:(UINavigationController*)aNav {
	if ((self = [super initWithNibName:@"ImagesListView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
		profile = [aProfile copy];
		album = [anAlbum copy];
		albumName = [anAlbumName copy];
		navController = aNav;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	if ([profile isEqualToString:user.strUsername])
	{
		// "Segmented" control on the right
		UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems:
											 [NSArray arrayWithObjects:
											  [UIImage imageNamed:@"icon_conf.png"],
											  [UIImage imageNamed:@"icon_add.png"],
											  nil]] autorelease];
		[segmentedControl addTarget:self action:@selector(actionEditAdd:) forControlEvents:UIControlEventValueChanged];
		segmentedControl.frame = CGRectMake(0, 0, 90, 30);
		segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		segmentedControl.tintColor = [UIColor blackColor];
		segmentedControl.momentary = YES;
	
		UIBarButtonItem *segmentBarItem = [[[UIBarButtonItem alloc] initWithCustomView:segmentedControl] autorelease];
		self.navigationItem.rightBarButtonItem = segmentBarItem;
		
		self.navigationItem.title = NSLocalizedString(@"My images", @"My Images view title");
		
	} else {
		self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"%@ images", @"User Images view title"), profile];	
	}
	
    [Designer applyStylesClear:table];
	[Designer applyStylesForScreen:self.view];
	
	[self requestImages];
}

- (void)viewWillAppear:(BOOL)animated {
	if (isReloadRequired)
		[self reloadData];
	[super viewWillAppear:animated];	
}

- (void)dealloc {
	[imagesList release];
	[profile release];
	[album release];
	[indexPathForRemoving release];
	[rightButtonSave2 release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)requestImages {	
	
	if (nil == imagesList) {
		NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, profile, album, nil];
		[self addProgressIndicator];
		[user.connector execAsyncMethod:@"dolphin.getImagesInAlbum" withParams:myArray withSelector:@selector(actionRequestImages:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
	}
	
}

- (void)requestRemoveImage:(NSString*)sImageId {	
	
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, sImageId, nil];
	[self addProgressIndicator];
	[user.connector execAsyncMethod:@"dolphin.removeImage" withParams:myArray withSelector:@selector(actionRequestRemoveImage:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
	
}

- (void)reloadData {
	[imagesList release];
	imagesList = nil;
	[self requestImages];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

- (void)actionRequestImages:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"images in album (%@): %@", album, resp);
	
	imagesList = [resp retain];
	isReloadRequired = NO;
	
	[table reloadData];
	
}

- (void)actionRequestRemoveImage:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self responce:resp];
		return;
	}
	
	NSLog(@"remove image: %@", resp);
	
	NSString *strResult = resp;
	
	if ([strResult isEqualToString:@"ok"] && indexPathForRemoving != nil)
	{
		[imagesList removeObjectAtIndex:indexPathForRemoving.row];
		[table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathForRemoving] withRowAnimation:YES];
		[indexPathForRemoving release];
		indexPathForRemoving = nil;
		
		// app.homeImages.isReloadRequired = YES;  - TODO:
		return;
	}
	
	UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:NSLocalizedString(@"Error occured", @"Error occured alert text") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title") otherButtonTitles:nil];
	[al show];
	[al release];
}


- (void)actionDone:(id)sender {
	if (YES == table.editing) {
		[table setEditing:NO animated:YES];
		self.navigationItem.rightBarButtonItem = rightButtonSave2;
		[rightButtonSave2 release];
		rightButtonSave2 = nil;
	}	
}

- (void)actionEditAdd:(id)sender {
	UISegmentedControl* segCtl = sender;
	
	NSInteger buttonIndex = [segCtl selectedSegmentIndex];
	switch (buttonIndex)
	{
		case 0:
			if (YES != table.editing) {
				[table setEditing:YES animated:YES];
				rightButtonSave2 = [self.navigationItem.rightBarButtonItem retain];
				UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done button title") style:UIBarButtonItemStyleDone target:self action:@selector(actionDone:)];
				self.navigationItem.rightBarButtonItem = btn2;
				[btn2 release];	
			}			
			break;
		case 1:
		{
			ImageAddController *ctrl = [[ImageAddController alloc] initWithAlbum:albumName imagesListController:self nav:navController];
			[navController pushViewController:ctrl animated:YES];
			[ctrl release];
			break;
		}
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
	return [imagesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	
	ImageIconBlock *cell;
	
	NSMutableDictionary *dict = [imagesList objectAtIndex:indexPath.row];
	cell = [dict valueForKey:@"Cell"];
	if (cell != nil)
		return cell;
	
	NSString* title = [dict valueForKey:@"title"];
	NSString* icon = [dict valueForKey:@"thumb"];
	NSString* desc = [dict valueForKey:@"desc"];
	NSString* rate = [dict valueForKey:@"rate"];
	
	cell = [[[ImageIconBlock alloc] initWithData:dict reuseIdentifier:nil] autorelease];
	[cell setTitle:title iconUrl:icon desc:desc rate:rate];
	
	[dict setValue:cell forKey:@"Cell"];
	
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ImagesController *ctrl = [[ImagesController alloc] initWithList:imagesList profile:profile nav:navController selectedImageIndex:indexPath.row makeThumbnailFlag:([profile isEqualToString:user.strUsername])];
    
    [ctrl setWantsFullScreenLayout:YES];
	[navController presentModalViewController:ctrl animated:YES];
	[ctrl release]; 	
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle != UITableViewCellEditingStyleDelete) 
		return;
	
	NSLog(@"Deleting row: %d", indexPath.row); 
	
	NSMutableDictionary *dict = [imagesList objectAtIndex:indexPath.row];
	NSString* sId = [dict valueForKey:@"id"];
	indexPathForRemoving = [indexPath retain];
	[self requestRemoveImage:sId];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [ImageIconBlock getHeight];
}


@end
