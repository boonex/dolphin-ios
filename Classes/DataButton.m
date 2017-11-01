//
//  DataButton.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/10/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "DataButton.h"

@implementation DataButton

- (id)initWithFrame:(CGRect)aRect {
	if ((self = [super initWithFrame:aRect]))	{
		data = nil;
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
		self.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	}
	return self;	
}

- (void)dealloc {
	[data release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)setButtonData:(id)aData {
	[data release];
	data = [aData retain];
}

- (id) getButtonData {
	return data;
}

@end
