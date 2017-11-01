//
//  InitialController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/4/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "InitialController.h"
#import "DolphinUsers.h"
#import "Dolphin6AppDelegate.h"
#import "AboutController.h"
#import "SiteAddController.h"
#import "LoginController.h"
#import "Designer.h"
#import "AsyncImageView.h"

@implementation InitialController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = NSLocalizedString(@"App Title", @"Initial View title");
	}
	return self;
}

- (void)viewDidLoad {
	
	// right nav item
	UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"About", @"About button title") style:UIBarButtonItemStylePlain target:self action:@selector(actionAbout:)];
	self.navigationItem.rightBarButtonItem = aboutButton;
	[aboutButton release];	
	
    if (nil == BX_LOCK_APP) {
        // left nav item
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"Edit button title") style:UIBarButtonItemStylePlain target: self action:@selector(actionEdit:)];
        self.navigationItem.leftBarButtonItem = editButton;
        [editButton release];
	}
		
    [Designer applyStylesClear:table];    
    [Designer applyStylesForTableBackgroundClear:table];
	[Designer applyStylesForScreen:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
	
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [table indexPathForSelectedRow];
	[table deselectRowAtIndexPath:tableSelection animated:NO];
	
	// reload the table data
	[table reloadData];
	
	[super viewWillAppear:animated];
}

- (void)dealloc {
	[logo release];
	[table release];
	[super dealloc];
}

/**********************************************************************************************************************
 DELEGATES: UITableView
 **********************************************************************************************************************/

#pragma mark - UITableView delegates

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	DolphinUsers *users = [DolphinUsers sharedDolphinUsers];
	
	NSUInteger usersCount = [users countOfUsers];
	
	if (indexPath.section == 0) {		
		if ([users countOfUsers] == indexPath.row || usersCount == 0) {
			return UITableViewCellEditingStyleNone;
		}
	}
	return UITableViewCellEditingStyleDelete;
	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

	DolphinUsers *users = [DolphinUsers sharedDolphinUsers];
	
	if (editingStyle != UITableViewCellEditingStyleDelete) 
		return;
		
	if ([users countOfUsers] == indexPath.row) {			

		return;
		 
	} else {			

		NSLog(@"Deleting row: %d", (int)indexPath.row); 
		[users removeUserAtIndex:(indexPath.row)];
		[users saveUsers];
		[table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];

	}
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (/* DISABLES CODE */ nil == BX_LOCK_APP)
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        default:
        case 0:
            return [[DolphinUsers sharedDolphinUsers] countOfUsers];
        case 1:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	DolphinUsers *users = [DolphinUsers sharedDolphinUsers];
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
    
    switch (indexPath.section) {
        default:
        case 0:
        {
            BxUser *user = [users userAtIndex:(indexPath.row)];
            cell.textLabel.text = user.strSite;
            
            cell.imageView.image = [UIImage imageNamed:@"icon_empty.png"];
            
            if (nil == user.iconSite) {
                
                AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];// cell.imageView.frame];
                NSString *strLogoUrl = [[NSString alloc] initWithFormat:@"%@../%@", user.connector.urlServerXMLRPC.absoluteString, BX_MOBILE_LOGO_PATH];
                NSLog(@"%@", strLogoUrl);
                NSURL *url = [[NSURL alloc] initWithString:strLogoUrl];
                [asyncImage loadImageFromURL:url];
                user.iconSite = asyncImage;
                [asyncImage release];
                [strLogoUrl release];
                [url release];
                
            } 
            
            [cell.imageView addSubview:user.iconSite];
            
            user.cell = cell;
        }
        break;
        case 1:
        {
            if ([users countOfUsers] == 0)
                cell.textLabel.text = NSLocalizedString(@"Add Dolphin Site", @"Add site table row, while adding first site");
            else
                cell.textLabel.text = NSLocalizedString(@"Add Another Dolphin Site", @"Add site table row, while adding second and futher sites");
            
            cell.imageView.image = [UIImage imageNamed:@"icon_add_community.png"];
        }
    }

	[Designer applyStylesForCell:cell];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return BX_TABLE_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	DolphinUsers *users = [DolphinUsers sharedDolphinUsers];
	
    [self setupBackButton];
    
    switch (indexPath.section) {
        case 0:
        {
			BxUser *aUser = [users userAtIndex:(indexPath.row)];
			LoginController *loginController = (LoginController *)[[LoginController alloc] initWithUserObject:aUser];
            
			Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
			[app.navigationController pushViewController:loginController animated:YES];
			[loginController release];
        }
        break;
        case 1:
        {
			SiteAddController * siteAddController = [[SiteAddController alloc] init];
			siteAddController.title = NSLocalizedString(@"Add Site", @"Add site view title");
            
			Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
			[app.navigationController pushViewController:siteAddController animated:YES];
			[siteAddController release];
        }
            
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil == BX_LOCK_APP && indexPath.section == 0 ? YES : NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0 == section ? 0 : BX_TABLE_FOOTER_INITIAL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return 0 == section ? nil : logo;
}


/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * show about view
 */
- (IBAction)actionAbout:(id)sender {
    [self setupBackButton];
    
	AboutController * cntrl = [[AboutController alloc] initWithNibName:@"AboutView" bundle:nil];
	cntrl.title = NSLocalizedString(@"About", @"About view title");
	
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	[app.navigationController pushViewController:cntrl animated:YES];
	[cntrl release];    
}

/**
 * switch to edit mode
 */
- (IBAction)actionEdit:(id)sender {
	
	if (YES == table.editing) {
		
		[table setEditing:NO animated:YES];
		self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Edit", @"Edit button title");
		
	} else {

		[table setEditing:YES animated:YES];
		self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Done", @"Done button title");

	}		
}

@end
