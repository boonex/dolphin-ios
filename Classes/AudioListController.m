//
//  ImagesListController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/27/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "AudioListController.h"
#import "Dolphin6AppDelegate.h"

@implementation AudioListController

- (id)initWithProfile:(NSString*)aProfile album:(NSString*)anAlbum nav:(UINavigationController*)aNav {
	if ((self = [super initWithProfile:aProfile album:anAlbum nav:aNav])) {
		method = @"dolphin.getAudioInAlbum";
	}
	return self;
}

- (void)viewDidLoad {
	self.navigationItem.title =[NSString stringWithFormat:NSLocalizedString(@"%@ music", @"User Music view title"), profile];
	[super viewDidLoad];
}

@end
