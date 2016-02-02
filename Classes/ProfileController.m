//
//  ProfileController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/5/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "ProfileController.h"
#import "MailComposeController.h"
#import "ImagesController.h"
#import "ProfileBlock.h"
#import "FriendsProfilesController.h"
#import "ProfileInfoController.h"
#import "ImagesAlbumsController.h"
#import "AudioAlbumsController.h"
#import "VideoAlbumsController.h"
#import "LocationViewController.h"
#import "WebPageController.h"
#import "Designer.h"

@implementation ProfileController

- (id)initWithProfile:(NSString*)aProfile nav:(UINavigationController *)aNav {
	if ((self = [super initWithNibName:@"ProfileView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
		profile = [aProfile copy];
		navController = aNav;
        bGoBackAfterAlert = NO;
	}
	return self;
}

- (void)deallocUserStrings {
    if (thumb != nil) {
        [thumb release];
        thumb = nil;
    }
    if (info != nil) {
        [info release];
        info = nil;
    }    
    if (location != nil) {
        [location release];
        location = nil;
    }        
}
- (void)dealloc {
    [aButtons release];
	[profile release];
    [self deallocUserStrings];
	[super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];
		
	// right nav item
	UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add Friend", @"Add Friend button") style:UIBarButtonItemStyleDone target:self action:@selector(actionAddFriend:)];
	self.navigationItem.rightBarButtonItem = btn2;
	[btn2 release];		

	self.navigationItem.title = profile;
	[self requestUserInfo];	
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)requestUserInfo {
    
    NSString *sMethod;
    NSLog(@"user.intProtocolVer = %d", user.intProtocolVer);
    if (user.intProtocolVer > 1) {
        sMethod = @"dolphin.getUserInfo2";
    } else {
        sMethod = @"dolphin.getUserInfo";
    }    

	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, profile, [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0], nil];
	[self addProgressIndicator];
	[user.connector execAsyncMethod:sMethod withParams:myArray withSelector:@selector(actionRequestUserInfo:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

- (void)requestAddFriend:(NSString*)aProfile {
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, aProfile, [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0], nil];
	[self addProgressIndicator];
	[user.connector execAsyncMethod:@"dolphin.addFriend" withParams:myArray withSelector:@selector(actionRequestAddFriend:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

- (void)initButtonsWithCountPhotos:(NSString*)sCountPhotos videos:(NSString*)sCountVideos sounds:(NSString*)sCountSounds friends:(NSString*)sCountFriends {

    if (nil != aButtons) {
        [aButtons release];
        aButtons = nil;
    }
    
    aButtons = 
    [[NSMutableArray alloc] initWithObjects:
        [NSDictionary 
         dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Profile Info block", @"Profile Info block caption"), @"1", nil] 
         forKeys:[NSArray arrayWithObjects:@"title", @"action", nil]],
        [NSDictionary 
         dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Contact profile block", @"Profile contact block caption"), @"2", nil] 
         forKeys:[NSArray arrayWithObjects:@"title", @"action", nil]],
        [NSDictionary 
         dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Friends profile block", @"Profile fiends block caption"), @"3", sCountFriends, nil] 
         forKeys:[NSArray arrayWithObjects:@"title", @"action", @"bubble", nil]],
        [NSDictionary 
         dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Photos profile block", @"Profile photos block caption"), @"4", sCountPhotos, nil] 
         forKeys:[NSArray arrayWithObjects:@"title", @"action", @"bubble", nil]],
        [NSDictionary 
         dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Music profile block", @"Profile music block caption"), @"5", sCountSounds, nil] 
         forKeys:[NSArray arrayWithObjects:@"title", @"action", @"bubble", nil]],
        [NSDictionary 
         dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Video profile block", @"Profile video block caption"), @"6", sCountVideos, nil] 
         forKeys:[NSArray arrayWithObjects:@"title", @"action", @"bubble", nil]],
        [NSDictionary 
         dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Location", @"locatin title"), @"7", nil] 
         forKeys:[NSArray arrayWithObjects:@"title", @"action", nil]],                
        nil
    ];

}

- (void)initButtons:(NSArray*)aMenu {
    
    if (nil != aButtons) {
        [aButtons release];
        aButtons = nil;
    }
    
    aButtons = [[NSMutableArray alloc] initWithArray:aMenu copyItems:YES];
    
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
	
	if ([resp isKindOfClass:[NSString class]]) {
		
		NSString *s = (NSString*)resp;
		NSString *sMsg;
		if ([s isEqualToString:@"-1"]) { 
			sMsg = NSLocalizedString(@"Access denied", @"Access denied alert msg");
		} else {
			sMsg = s;
		}
        
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"" message:sMsg delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Title") otherButtonTitles:NSLocalizedString(@"Add Friend", @"Add Friend button"), nil];
		[al show];
		[al release];
        
        [cellProfileBlock setProfile:@"" title:@"" iconUrl:nil info:@"" location:@""];
		
	} else {
		
        NSDictionary *dict;
        if (user.intProtocolVer > 1) {
            
            dict = (NSDictionary*)[resp valueForKey:@"info"];
            [self initButtons:(NSArray*)[resp valueForKey:@"menu"]];
            
        } else {
            
            dict = resp;
            
            NSString *sCountPhotos = (NSString*)[resp valueForKey:@"countPhotos"];
            NSString *sCountVideos = (NSString*)[resp valueForKey:@"countVideos"];
            NSString *sCountSounds = (NSString*)[resp valueForKey:@"countSounds"];
            NSString *sCountFriends = (NSString*)[resp valueForKey:@"countFriends"];

            [self initButtonsWithCountPhotos:sCountPhotos videos:sCountVideos sounds:sCountSounds friends:sCountFriends];
        }
                        
        [self deallocUserStrings];
        
        thumb = [[dict valueForKey:@"thumb"] copy];

        title = [[Dolphin6AppDelegate formatUserTitle:dict default:profile] copy];
        info = [[Dolphin6AppDelegate formatUserInfo:dict] copy];
        location = [[Dolphin6AppDelegate formatUserLocation:dict] copy];
        
        [cellProfileBlock setProfile:profile title:title iconUrl:thumb info:info location:location];            
        
        self.navigationItem.title = title;
        
        if (user.intProtocolVer > 2 && [dict valueForKey:@"user_friend"] && ((NSString*)[dict valueForKey:@"user_friend"]).intValue > 0) {
            // dont display "add to friends" button if users are already friends
            self.navigationItem.rightBarButtonItem = nil;            
        } 
                
		[table reloadData];
	}
	
	[resp release];
}

/**
 * callback function on request info 
 */
- (void)actionRequestAddFriend:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [[idData valueForKey:BX_KEY_RESP] retain];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"add friend result: %@", resp);

	UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add Friend title", @"Add Friend alert title") message:(NSString*)resp delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button text") otherButtonTitles:nil];
	[al show];
	[al release];	
	
	[resp release];
}

- (IBAction)actionAddFriend:(id)sender {
	[self requestAddFriend:profile];
}

/**********************************************************************************************************************
 DELEGATES: UITableView
 **********************************************************************************************************************/

#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [aButtons count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	
	if (0 == indexPath.row) {
		if (nil == cellProfileBlock) {
			cellProfileBlock = [[ProfileBlock alloc] initWithData:nil reuseIdentifier:nil];
		}
		return cellProfileBlock;
	}
	
    NSMutableDictionary *dict = [aButtons objectAtIndex:indexPath.row-1];
    
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

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSMutableDictionary *dict = [aButtons objectAtIndex:indexPath.row-1];
    
    int iAction = [[dict valueForKey:@"action"] intValue];
    
	UIViewController * ctrl = nil;
	switch (iAction)
	{
		case 2:
			ctrl = [[LocationViewController alloc] initWithProfile:profile nav:navController];
			break;			                        
		case 3:
			ctrl = [[MailComposeController alloc] initWithRecipient:profile recipientTitle:title subject:nil nav:navController];
			break;
		case 4:
			ctrl = [[FriendsProfilesController alloc] initWithProfile:profile title:title nav:navController];
			break;			
		case 5:
			ctrl = [[ProfileInfoController alloc] initWithProfile:profile title:title thumb:thumb info:info location:location nav:navController];
			break;            
		case 7:
			ctrl = [[ImagesAlbumsController alloc] initWithProfile:profile title:title nav:navController];
			break;
		case 8:
			ctrl = [[VideoAlbumsController alloc] initWithProfile:profile title:title nav:navController];
			break;
		case 9:
			ctrl = [[AudioAlbumsController alloc] initWithProfile:profile title:title nav:navController];
			break;
		case 10:
            {
                NSString *sSubject = [NSString stringWithFormat:NSLocalizedString(@"Reported Profile", @"Reported Profile Mail Subject"), profile];
                NSString *sMail = [dict valueForKey:@"action_data"];
                NSArray *aRecipients = [NSArray arrayWithObjects:sMail, nil];
                
                MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
                controller.mailComposeDelegate = self;
                [controller setToRecipients:aRecipients];
                [controller setSubject:sSubject];
                [controller setMessageBody:@"" isHTML:NO];
                if (controller)
                    [self presentModalViewController:controller animated:YES];
                [controller release];
            }
			break;
        case 100:
        case 101:
        {
            NSString *sTitle = [dict valueForKey:@"title"];
            NSString *sActionData = [dict valueForKey:@"action_data"];
            [self openPageUrl:sActionData title:sTitle nav:navController openInNewWindow:(101 == iAction ? YES : NO)];
            return;
        }            
	}
	[navController pushViewController:ctrl animated:YES];
	[ctrl release];
}

/**********************************************************************************************************
 DELEGATES: MFMailComposeViewController
 **********************************************************************************************************/


- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"message sent");
    }
    [self dismissModalViewControllerAnimated:YES];
}

/**********************************************************************************************************************
 DELEGATES: UIAlertView
 **********************************************************************************************************************/

#pragma mark - UIAlertView Delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        // add friend
        bGoBackAfterAlert = YES;
        [self actionAddFriend:nil];
    } else if (bGoBackAfterAlert || nil == alertView.title || 0 == [alertView.title length]) {
		[navController popViewControllerAnimated:YES];
    }
}

@end