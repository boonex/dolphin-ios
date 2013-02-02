//
//  ImagesHomeController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/26/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "ImagesAlbumsController.h"
#import "Dolphin6AppDelegate.h"
#import "ImagesListController.h"
#import "Designer.h"

@implementation ImagesAlbumsController

@synthesize isReloadRequired, navContrioller;

- (id)initWithProfile:(NSString*)aProfile title:(NSString*)aProfileTitle nav:(UINavigationController*)aNav {
	if ((self = [super initWithNibName:@"ImagesAlbumsView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
        self.title = NSLocalizedString(@"Images tab", @"Images tab title");
        self.tabBarItem.image = [UIImage imageNamed:@"tab_photos.png"];
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
	
	if ([profile isEqualToString:user.strUsername])
		self.navigationItem.title = NSLocalizedString(@"My Images", @"My Images view title");
	else
		self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"%@ images", @"User Images view title"), profileTitle];
		
	[self requestData];
}

- (void)viewWillAppear:(BOOL)animated {
	if (isReloadRequired)
		[self reloadData];
	[super viewWillAppear:animated];	
}

- (void)dealloc {
	[profile release];
	[profileTitle release];    
	[catList release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)reloadData {
	[catList release];
	catList = nil;
	[self requestData];
}

- (void)requestData {	
	
	if (nil == catList) {
		NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, profile, nil];
		[self addProgressIndicator];
		[user.connector execAsyncMethod:@"dolphin.getImageAlbums" withParams:myArray withSelector:@selector(actionRequestData:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
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

	NSDictionary *dict = [catList objectAtIndex:indexPath.row];
	NSString *identifer = [[dict valueForKey:@"Id"] retain];
	NSString *albumName = [[dict valueForKey:@"Title"] retain];
	
	UIViewController *ctrl = [[ImagesListController alloc] initWithProfile:profile album:identifer albumName:albumName nav:navContrioller];
	[navContrioller pushViewController:ctrl animated:YES];			
	[ctrl release];
	[identifer release];
}


/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * callback function on contacts list request 
 */
- (void)actionRequestData:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"image albums: %@", resp);
	
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
