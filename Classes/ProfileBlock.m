//
//  ProfileBlock.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/6/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "ProfileBlock.h"
#import "User.h"

@implementation ProfileBlock

- (id)initWithData:(id)aData reuseIdentifier:(NSString *)reuseIdentifier {
	
	if ((self = [super initWithData:aData reuseIdentifier:reuseIdentifier])) {
		
		self.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return self;
}

@end
