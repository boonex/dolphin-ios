//
//  User.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/21/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "Msg.h"

@implementation BxMsg

@synthesize strSubj;
@synthesize strBody;
@synthesize intId;

- (id) initWithDataId:(NSInteger)integerId subject:(NSString*)stringSubj andBody:(NSString*) stringBody {
	
    if ((self = [super init])) {
		[self setDataId:integerId subject:stringSubj andBody:stringBody];	
    }
    return self;
}

- (void) setDataId:(NSInteger)integerId subject:(NSString*)stringSubj andBody:(NSString*) stringBody {
	self.strSubj = stringSubj; // copy via accessor
	self.strBody = stringBody; // copy via accessor
	self.intId = integerId;
}

- (void) dealloc {
	[strSubj release];
	[strBody release];
	[super dealloc];
}

@end
