//
//  User.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/21/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "User.h"
#import "Dolphin6AppDelegate.h"

@implementation BxUser

@synthesize cell, strSite, strPwdHash, strUsername, intId, numUnreadLetters, numFriendRequests, connector, iconSite, rememberPassword, intProtocolVer;


- (id)initWithUser:(NSString*)anUsername id:(NSInteger)anId passwordHash:(NSString*)aHash site:(NSString*)aSite protocolVer:(NSInteger)aProtocolVer {
	
    if ((self = [super init])) {
		[self setUser:anUsername id:anId passwordHash:aHash site:aSite protocolVer:aProtocolVer];	
    }
    return self;
}

- (void)setUser:(NSString*)anUsername id:(NSInteger)anId passwordHash:(NSString*)aHash site:(NSString*)aSite protocolVer:(NSInteger)aProtocolVer {
	self.strSite = aSite; // copy via accessor
	self.strUsername = anUsername; // copy via accessor	
	self.strPwdHash = aHash; // copy via accessor
	intId = anId;
    intProtocolVer = aProtocolVer;
	connector = [[BxConnector alloc] initWithSite:strSite];
}

- (void)dealloc {
	[cell release];
	[iconSite release];
	[strSite release];
	[strUsername release];
	[strPwdHash release];
	[connector release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    self.strSite = [coder decodeObjectForKey:@"MVSite"]; // copy via accessor
	self.strUsername = [coder decodeObjectForKey:@"MVUsername"]; // copy via accessor
	self.strPwdHash = [coder decodeObjectForKey:@"MVPwdHash"]; // copy via accessor
	intId = [coder decodeIntForKey:@"MVId"];
    self.connector = [coder decodeObjectForKey:@"MVConnector"]; // retain via accessor
    if (YES == [coder containsValueForKey:@"MVProtocolVer"])
        intProtocolVer = [coder decodeIntForKey:@"MVProtocolVer"];
    else
        intProtocolVer = 1;
	self.rememberPassword = [self.strPwdHash isEqualToString:@""] ? NO : YES;
    NSLog(@"decoding: site=%@ protocol=%ld", self.strSite, (long)intProtocolVer);
    return self;	
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:strSite forKey:@"MVSite"];
	[coder encodeObject:strUsername forKey:@"MVUsername"];
	[coder encodeObject:(rememberPassword ? strPwdHash : @"") forKey:@"MVPwdHash"];
	[coder encodeInt:(int)intId forKey:@"MVId"];
	[coder encodeObject:connector forKey:@"MVConnector"];	
    [coder encodeInt:(int)intProtocolVer forKey:@"MVProtocolVer"];
    NSLog(@"encoding: site=%@ protocol=%ld", self.strSite, (long)intProtocolVer);
}

- (void)updateBadgeValues {
	
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	
	if (numUnreadLetters > 0)
		app.mailNavigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)numUnreadLetters];
	else
		app.mailNavigationController.tabBarItem.badgeValue = nil;
	
	if (numFriendRequests > 0)
		app.friendsNavigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)numFriendRequests];
	else
		app.friendsNavigationController.tabBarItem.badgeValue = nil;
}

- (void)setUnreadLettersNum:(NSInteger)aNum {
	numUnreadLetters = aNum;
	[self updateBadgeValues];
}

- (void)setFriendRequestsNum:(NSInteger)aNum {
	numFriendRequests = aNum;
	[self updateBadgeValues];
}

- (void)decUnreadLettersNum {
	--numUnreadLetters;
	[self updateBadgeValues];
}

- (void)decFriendRequestsNum {
	--numFriendRequests;
	[self updateBadgeValues];
}

- (void)setLoggenInCookiesForRequest:(NSMutableURLRequest*)request {
    if (intProtocolVer < 4)
        return;
    
    NSString *sCookieLoggedIn = [NSString stringWithFormat:@"memberID=%ld; memberPassword=%@; lang=%@", (long)intId, strPwdHash, [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0]];
    NSString *sCookieOld = [request valueForHTTPHeaderField: @"Cookie"];
    if (sCookieOld == nil) {
        [request addValue:sCookieLoggedIn forHTTPHeaderField:@"Cookie"];
    } else {
        NSString *sCookieNew = [NSString stringWithFormat:@"%@;%@", sCookieOld, sCookieLoggedIn];
        [request setValue:sCookieNew forHTTPHeaderField:@"Cookie"];
    }
}

@end
