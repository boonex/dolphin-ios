//
//  MailHomeController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/17/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "SearchHomeController.h"
#import "SearchLocationController.h"
#import "SearchKeywordController.h"
#import "SearchNearMeController.h"
#import "WebPageController.h"
#import "Designer.h"

@implementation SearchHomeController

- (id)init {
	if ((self = [super initWithNibName:@"SearchHomeView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
        self.title = NSLocalizedString(@"Search tab", @"Search tab title");
        self.tabBarItem.image = [UIImage imageNamed:@"tab_search.png"];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.navigationItem.title = NSLocalizedString(@"Search", @"Search view title");
    
    [self requestMenu];
}

- (void)dealloc {
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)requestMenu {
    
    NSLog(@"user.intProtocolVer = %d", user.intProtocolVer);
    if (user.intProtocolVer < 3) {
        [self initMenuPredefined];
        return;
    }
    
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0], nil];
	[self addProgressIndicator];
	[user.connector execAsyncMethod:@"dolphin.getSeachHomeMenu3" withParams:myArray withSelector:@selector(actionRequestMenu:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

- (void)initMenu:(NSArray*)menu {
    
    if (nil != aMenu) {
        [aMenu release];
        aMenu = nil;
    }
    
    aMenu = [[NSMutableArray alloc] initWithArray:menu copyItems:YES];
    
    [table reloadData];
}

- (void)initMenuPredefined {
    
    if (nil != aMenu) {
        [aMenu release];
        aMenu = nil;
    }
    
    aMenu = 
    [[NSMutableArray alloc] initWithObjects:
     [NSDictionary 
      dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Search By Keyword row", @"Search by keyword row title"), @"30", nil] 
      forKeys:[NSArray arrayWithObjects:@"title", @"action", nil]],
     [NSDictionary 
      dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Location Search row", @"Location search row title"), @"31", nil] 
      forKeys:[NSArray arrayWithObjects:@"title", @"action", nil]],
     [NSDictionary 
      dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Search Near Me row", @"Search near me row title"), @"32", nil]
      forKeys:[NSArray arrayWithObjects:@"title", @"action", nil]],
     nil
     ];
    
    [table reloadData];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * callback function on request info 
 */
- (void)actionRequestMenu:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [[idData valueForKey:BX_KEY_RESP] retain];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"requested info: %@", resp);
			
    [self initMenu:(NSArray*)[resp valueForKey:@"menu"]];

	[resp release];
}


/**********************************************************************************************************************
 DELEGATES: UIViewTable
 **********************************************************************************************************************/

#pragma mark - UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [aMenu count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    
    NSMutableDictionary *dict = [aMenu objectAtIndex:indexPath.row];
    
    NSString *sTitle = [dict valueForKey:@"title"];
    NSString *sBubble = [dict valueForKey:@"bubble"];                        
    
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (nil == sBubble || [sBubble isEqualToString:@""] || [sBubble isEqualToString:@"0"]) {
        cell.textLabel.text = sTitle;
    } else {
        NSString *sFormat = NSLocalizedString(@"Menu Button", @"Menu button with bubble format");
        cell.textLabel.text = [NSString stringWithFormat:sFormat, sTitle, sBubble];
    }
	[Designer applyStylesForCell:cell];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return BX_TABLE_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSMutableDictionary *dict = [aMenu objectAtIndex:indexPath.row];
    
    int iAction = [[dict valueForKey:@"action"] intValue];
        
	UIViewController * ctrl = nil;
	switch (iAction)
	{
		case 30:
			ctrl = [[SearchKeywordController alloc] init];
			break;			                        
		case 31:
			ctrl = [[SearchLocationController alloc] init];
			break;
		case 32:
			ctrl = [[SearchNearMeController alloc] init];
			break;
        case 100:
        case 101:
        {
            NSString *sTitle = [dict valueForKey:@"title"];
            NSString *sActionData = [dict valueForKey:@"action_data"];
            Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
            [self openPageUrl:sActionData title:sTitle nav:app.homeNavigationController openInNewWindow:(101 == iAction ? YES : NO)];
            return;            
        }
	}
    
    Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	[app.searchNavigationController pushViewController:ctrl animated:YES];
	[ctrl release];	
    
}

@end
