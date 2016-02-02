//
//  ProfileInfoController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/24/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "ProfileInfoController.h"
#import "HomeController.h"
#import "ProfileInfoBlock.h"
#import "ProfileBlock.h"
#import "Designer.h"

#define BX_PROFILE_INFO_LINE_HEIGHT 20.0

@implementation ProfileInfoController

- (id)initWithProfile:(NSString*)aProfile title:(NSString*)sTitle thumb:(NSString*)sThumb info:(NSString*)sInfo location:(NSString*)sLocation nav:(UINavigationController *)aNav {
	if ((self = [super initWithNibName:@"ProfileInfoView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
        self.title = NSLocalizedString(@"Profile tab", @"Profile tab title");
        self.tabBarItem.image = [UIImage imageNamed:@"tab_profile.png"];
		profile = [aProfile copy];
        title = [sTitle copy];
        thumb = [sThumb copy];
        info = [sInfo copy];
        location = [sLocation copy];
		navController = aNav;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

    [Designer applyStylesClear:table];
	[Designer applyStylesForScreen:self.view];
    
	[self requestUserInfo];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    if (nil == info && nil == thumb) {

        Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];            
        NSArray *viewControllers = [app.homeNavigationController viewControllers];
        HomeController *ctrlHome = (HomeController *)[viewControllers objectAtIndex:0];            

        NSLog(@"My Profile Info will appear - status:%@", ctrlHome.stringStatus);
        NSLog(@"My Profile Info will appear - title:%@", ctrlHome.stringUserTitle);
        NSLog(@"My Profile Info will appear - thumb:%@", ctrlHome.stringThumbUrl);
        NSLog(@"My Profile Info will appear - info:%@", ctrlHome.stringUserInfo);
        
        cellProfileBlock = [[ProfileBlock alloc] initWithData:nil reuseIdentifier:nil];
        [cellProfileBlock 
            setProfile:profile 
            title:ctrlHome.stringUserTitle
            iconUrl:ctrlHome.stringThumbUrl
            info:ctrlHome.stringUserInfo 
            location:ctrlHome.stringUserLocation
        ];        
    }
    
}


- (void)dealloc {
	[profileInfoList release];
	[profile release];
	[title release];    
    [thumb release];
    [info release];
    [location release];    
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)requestUserInfo {
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, profile, [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0], nil];
	[self addProgressIndicator];
	[user.connector execAsyncMethod:@"dolphin.getUserInfoExtra" withParams:myArray withSelector:@selector(actionRequestUserInfo:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * callback function on request info 
 */
- (void)actionRequestUserInfo:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [[idData valueForKey:BX_KEY_RESP] retain];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"requested info: %@", resp);
	
    if([resp isKindOfClass:[NSDictionary class]] && nil != [(NSDictionary *)resp objectForKey:@"error"]) {        
        [BxConnector showDictErrorAlertWithDelegate:self responce:resp];
        return;
    }
    
	profileInfoList = [resp retain];	
	[table reloadData];
	[resp release];
}

/**********************************************************************************************************************
 DELEGATES: UITableView
 **********************************************************************************************************************/

#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return profileInfoList && [profileInfoList count] > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return profileInfoList && [profileInfoList count] > 1 ? [profileInfoList count] + 1 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	
	if (0 == indexPath.row) {
		if (nil == cellProfileBlock) {                        
			cellProfileBlock = [[ProfileBlock alloc] initWithData:nil reuseIdentifier:nil];
            [cellProfileBlock 
                setProfile:profile 
                title:title
                iconUrl:(nil == thumb ? @"" : thumb)  
                info:(nil == info ? @"" : info) 
                location:location
            ];
		}
		return cellProfileBlock;
	}
    
	ProfileInfoBlock *cell;
	
	if (0 == [profileInfoList count])
		return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	NSArray *arraySection = [[profileInfoList objectAtIndex:indexPath.row-1] valueForKey:@"Info"];
	if (0 == [arraySection count])
		return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	NSMutableDictionary *dict = [arraySection objectAtIndex:0];
	if (nil == dict)
		return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	
	cell = [dict valueForKey:@"Cell"];
	if (cell == nil) {
		NSString *caption = [[profileInfoList objectAtIndex:indexPath.row-1] valueForKey:@"Title"];
		cell = [[[ProfileInfoBlock alloc] initWithCaption:caption info:arraySection data:nil table:tableView] autorelease];
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	if (0 == indexPath.row)
			return BX_TABLE_CELL_HEIGHT_THUMB;
    
	ProfileInfoBlock *cell;
	
	if (0 == [profileInfoList count])
		return 0;		
	NSArray *arraySection = [[profileInfoList objectAtIndex:indexPath.row-1] valueForKey:@"Info"];
	if (0 == [arraySection count])
		return 0;
	NSMutableDictionary *dict = [arraySection objectAtIndex:0];
	if (nil == dict)
		return 0;
	
	cell = [dict valueForKey:@"Cell"];
	if (cell == nil) {	
		NSString *caption = [[profileInfoList objectAtIndex:indexPath.row-1] valueForKey:@"Title"];
		cell = [[[ProfileInfoBlock alloc] initWithCaption:caption info:arraySection data:nil table:tableView] autorelease];
	}
			
	return [cell calcHeight];			
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

@end
