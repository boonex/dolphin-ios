//
//  TesterController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/26/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "TesterController.h"
#import "config.h"
#import "User.h"

#define BX_TEST_USER	@"hihi"

#define BX_TEST_PWD		@"5xxxxxxxxxxxxxxx2" // ms5 of clear password 

#define BX_TEST_SITE	@"http://192.168.1.215/d70/"

#define BX_TEST_LANG	@"en"
#define BX_TEST_USER2	@"hihi2"

#define BX_KEY_METHOD	@"method"

#define BX_INDEX_METHOD	0
#define BX_INDEX_PARAMS	1

@implementation TesterController

- (id)init {
	if ((self = [super initWithNibName:@"TesterView" bundle:nil])) {
		
		sUser = BX_TEST_USER;
		sPwd = BX_TEST_PWD;
		sSite = BX_TEST_SITE;		

		// ORDER IS IMPORTANT !
		
		NSData *imgData = UIImageJPEGRepresentation([UIImage imageNamed:@"128x128.png"], 0.8);
		NSString *sDataLen = [NSString stringWithFormat:@"%d", (int)[imgData length]];
		
		runQueue = [[NSArray alloc] initWithObjects:

			// 0 - util			
			[NSArray arrayWithObjects:@"dolphin.getContacts", [NSArray array], nil],
			[NSArray arrayWithObjects:@"dolphin.getCountries", [NSArray arrayWithObjects:BX_TEST_LANG, nil], nil],
					
			// 2 - user
			[NSArray arrayWithObjects:@"dolphin.getHomepageInfo", [NSArray array], nil],
			[NSArray arrayWithObjects:@"dolphin.getUserInfo", [NSArray arrayWithObjects:sUser, BX_TEST_LANG, nil], nil],
			[NSArray arrayWithObjects:@"dolphin.getUserInfoExtra", [NSArray arrayWithObjects:sUser, BX_TEST_LANG, nil], nil],

			// 5 - messages
			[NSArray arrayWithObjects:@"dolphin.getMessagesInbox", [NSArray array], nil],
			[NSArray arrayWithObjects:@"dolphin.getMessagesSent", [NSArray array], nil],
			[NSArray arrayWithObjects:@"dolphin.sendMessage", [NSArray arrayWithObjects:@"hihi", @"test subj", @"test text", @"inbox", nil], nil],
			[NSArray arrayWithObjects:@"dolphin.getMessageInbox", [NSMutableArray arrayWithObjects:@"8 - replace!", nil], nil],
			[NSArray arrayWithObjects:@"dolphin.getMessageSent", [NSMutableArray arrayWithObjects:@"9 - replace!", nil], nil],

			// 10 - friends			
			[NSArray arrayWithObjects:@"dolphin.addFriend", [NSArray arrayWithObjects:BX_TEST_USER2, BX_TEST_LANG, nil], nil],
			[NSArray arrayWithObjects:@"dolphin.getFriendRequests", [NSArray arrayWithObjects:BX_TEST_LANG, nil], nil],
			[NSArray arrayWithObjects:@"dolphin.declineFriendRequest", [NSArray arrayWithObjects:BX_TEST_USER2, nil], nil],
			[NSArray arrayWithObjects:@"dolphin.acceptFriendRequest", [NSArray arrayWithObjects:BX_TEST_USER2, nil], nil],
			[NSArray arrayWithObjects:@"dolphin.getFriends", [NSArray arrayWithObjects:sUser, BX_TEST_LANG, nil], nil],
			[NSArray arrayWithObjects:@"dolphin.removeFriend", [NSArray arrayWithObjects:BX_TEST_USER2, nil], nil],
			
			// 16 - search
			[NSArray arrayWithObjects:@"dolphin.getSearchResultsLocation", [NSArray arrayWithObjects:BX_TEST_LANG, @"AU", @"", @"0", @"0", @"0", @"10", nil], nil],
			[NSArray arrayWithObjects:@"dolphin.getSearchResultsKeyword", [NSArray arrayWithObjects:BX_TEST_LANG, @"test", @"0", @"0", @"0", @"10", nil], nil],
					
			// 18 - images
			[NSArray arrayWithObjects:@"dolphin.getImagesInAlbum", [NSArray arrayWithObjects:sUser, BX_DEFAULT_ALBUM, nil], nil],
			[NSArray arrayWithObjects:@"dolphin.getImageAlbums", [NSArray arrayWithObjects:sUser, nil], nil],
			[NSArray arrayWithObjects:@"dolphin.uploadImage", [NSArray arrayWithObjects:BX_DEFAULT_ALBUM, imgData, sDataLen, @"Test Title", @"test, tags", @"Test description", nil], nil],
//			[NSArray arrayWithObjects:@"dolphin.getImages", [NSArray arrayWithObjects:sUser, nil], nil],
			[NSArray arrayWithObjects:@"dolphin.makeThumbnail", [NSMutableArray arrayWithObjects:@"22 - replace!!!", nil], nil],
			[NSArray arrayWithObjects:@"dolphin.removeImage", [NSMutableArray arrayWithObjects:@"23 - replace!!!", nil], nil],
					
			// 24 - media
			[NSArray arrayWithObjects:@"dolphin.getAudioAlbums", [NSArray arrayWithObjects:sUser, nil], nil],
			[NSArray arrayWithObjects:@"dolphin.getVideoAlbums", [NSArray arrayWithObjects:sUser, nil], nil],
			[NSArray arrayWithObjects:@"dolphin.getAudioInAlbum", [NSArray arrayWithObjects:sUser, BX_DEFAULT_ALBUM, nil], nil],		
			[NSArray arrayWithObjects:@"dolphin.getVideoInAlbum", [NSArray arrayWithObjects:sUser, BX_DEFAULT_ALBUM, nil], nil],

			nil];
		
		NSLog(@"Number of tests: %d", (int)[runQueue count]);
		
		currentIndex = 0;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[[UIColor whiteColor] set];
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:20]};
    [@"Login" drawAtPoint:CGPointMake(50, 50) withAttributes:attributes];
}

- (void)viewDidLoad {
	
	sErrors = [[NSString alloc] init];
	
	user = [[BxUser alloc] initWithUser:sUser id:0 passwordHash:sPwd site:sSite protocolVer:0];
	
	NSString *sMethod = @"dolphin.login";
	NSLog(@" ");
	[self testBegin:@"Login"];
	
	NSMutableDictionary * data = [[NSMutableDictionary alloc] init];	
	[data setObject:sMethod forKey:BX_KEY_METHOD];	
	
	NSArray *aParams = [NSArray arrayWithObjects:sUser, sPwd, nil];
	[user.connector execAsyncMethod:sMethod withParams:aParams withSelector:@selector(callbackLogin:) andSelectorObject:self andSelectorData:data useIndicator:nil];
	[data release];
	
	progress.progress = 0;
	
	[self.view setNeedsDisplay];
}

- (void)runQueue {
	if ((currentIndex + 1) > [runQueue count])
	{
		progress.progress = 1;
		NSLog(@" ");
		NSLog(@"TESTS COMPLETED");
		status.text = @"TESTS COMPLETED";
		[errors loadHTMLString:[NSString stringWithFormat:@"<div style=\"font-size:12px;\">%@</div>", sErrors] baseURL:nil];	
		return;
	}
	
	progress.progress = (currentIndex + 1.0) / [runQueue count];
	
	NSArray *a = [runQueue objectAtIndex:currentIndex];
	NSString *sMethod = [a objectAtIndex:BX_INDEX_METHOD];
	NSArray *aParamsToAdd = [a objectAtIndex:BX_INDEX_PARAMS];	
	
	[self testBegin:sMethod];
	
	NSMutableDictionary * data = [[NSMutableDictionary alloc] init];	
	[data setObject:sMethod forKey:BX_KEY_METHOD];	

	NSArray *aParamsDefault = [NSArray arrayWithObjects:sUser, sPwd, nil];
	NSArray *aParams = [aParamsDefault arrayByAddingObjectsFromArray:aParamsToAdd];	
	
	[user.connector execAsyncMethod:sMethod withParams:aParams withSelector:@selector(callbackDefault:) andSelectorObject:self andSelectorData:data useIndicator:nil];
	[data release];
}

/**
 * default callback
 */
- (void)callbackDefault:(id)idData {	
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	NSString *sMethod = [idData valueForKey:BX_KEY_METHOD];
	
	if([resp isKindOfClass:[NSError class]])
		[self testEnd:NO ret:resp method:sMethod];
	else
		[self testEnd:YES ret:resp method:sMethod];	
	
	++currentIndex;
	
	[self runQueue];
}

/**
 * callback function on login 
 */
- (void)callbackLogin:(id)idData {	
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	NSString *sMethod = [idData valueForKey:BX_KEY_METHOD];
	
	// if error occured or returned members' id is 0 - show "login failed" popup 
	if([resp isKindOfClass:[NSError class]] || 0 == [resp intValue])
	{		
		[self testEnd:NO ret:resp method:sMethod];
		return;
	}
	
	[self testEnd:YES ret:resp method:sMethod];
	
	int iMemberId = [resp intValue];
	user.intId = iMemberId;
	
	[self runQueue];
}

- (void)dealloc {
	[user release];
	[status release];
	[runQueue release];
	[sErrors release];
	[super dealloc];
}

- (void)testBegin:(NSString*)s {
	status.text = s;
	NSLog(@"%@", s);
}

- (void)testEnd:(BOOL)isSuccess  ret:(id)resp method:(NSString*)sMethod {
	
	NSString *s = isSuccess ? @"OK" : @"FAIL";

	if([resp isKindOfClass:[NSError class]]) {
		
		s = [s stringByAppendingFormat:@" (%@)", [((NSError*)resp) localizedDescription]];
		
		NSString *sTmp = [[NSString alloc] initWithFormat:@"%@<b>%@</b> - %@<hr />", sErrors, sMethod, [((NSError*)resp) localizedDescription]];
		[sErrors release];
		sErrors = sTmp;
		
	} else if([resp isKindOfClass:[NSArray class]]) {
		
		s = [s stringByAppendingFormat:@" (Array: %d)", (int)[resp count]];
		
	} else if([resp isKindOfClass:[NSDictionary class]]) {
		
		s = [s stringByAppendingFormat:@" (NSDictionary: %d %@)", (int)[resp count], [[resp allKeys] componentsJoinedByString:@","]];
				
	} else if([resp isKindOfClass:[NSString class]]) {
			
		s = [s stringByAppendingFormat:@" (String: %@)", resp];
	
	} else if([resp isKindOfClass:[NSString class]]) {
			
		s = [s stringByAppendingFormat:@" (%@)", resp];
				 
	}

				 
	NSLog(@"%@", s);
	status.text = s;
	NSLog(@" ");
	
	if(![resp isKindOfClass:[NSError class]]) {
		[self customSituationForMethod:sMethod ret:resp];
	}
}

- (void)customSituationForMethod:(NSString*)sMethod ret:(id)resp {
	
	if ([sMethod isEqualToString:@"dolphin.getMessagesInbox"]) {
		
		if ([resp count]) {
			NSString *sId = [[resp objectAtIndex:0] valueForKey:@"ID"];

			NSMutableArray *a = [[runQueue objectAtIndex:8] objectAtIndex:1];
			[a replaceObjectAtIndex:0 withObject:sId];
		}
		
	} else if ([sMethod isEqualToString:@"dolphin.getMessagesSent"]) {

		if ([resp count]) {
			
			NSString *sId = [[resp objectAtIndex:0] valueForKey:@"ID"];
		
			NSMutableArray *a = [[runQueue objectAtIndex:9] objectAtIndex:1];
			[a replaceObjectAtIndex:0 withObject:sId];
		}
				
	} else if ([sMethod isEqualToString:@"dolphin.getImages"]) {
		
		NSInteger iCount = [resp count];
		if (iCount > 0) {
	
			NSString *sId = [[resp objectAtIndex:iCount-1] valueForKey:@"id"];
			NSLog(@"Image for making thumbnail and then deleting: %@", sId);
			
			NSMutableArray *a = [[runQueue objectAtIndex:22] objectAtIndex:1];
			[a replaceObjectAtIndex:0 withObject:sId];
			
			NSMutableArray *a2 = [[runQueue objectAtIndex:23] objectAtIndex:1];
			[a2 replaceObjectAtIndex:0 withObject:sId];
		}
		
	}
}

@end
