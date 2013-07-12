//
//  ImagesAlbumsController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/26/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "ImagesAlbumsController.h"
#import "Dolphin6AppDelegate.h"
#import "ImagesListController.h"

@implementation ImagesAlbumsController

- (id)initWithProfile:(NSString*)aProfile title:(NSString*)aProfileTitle nav:(UINavigationController*)aNav {
	if ((self = [super initWithProfile:aProfile title:aProfileTitle nav:aNav])) {
		method = @"dolphin.getImageAlbums";
	}
	return self;
}

- (id)initWithProfile:(NSString*)aProfile nav:(UINavigationController*)aNav {
    return [self initWithProfile:aProfile title:aProfile nav:aNav];
}

- (void)viewDidLoad {
	if ([profile isEqualToString:user.strUsername])
		self.navigationItem.title = NSLocalizedString(@"My Images", @"My Images view title");
	else
		self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"%@ images", @"User Images view title"), profileTitle];
	[super viewDidLoad];
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSDictionary *dict = [catList objectAtIndex:indexPath.row];
	NSString *identifer = [[dict valueForKey:@"Id"] retain];
	NSString *albumName = [[dict valueForKey:@"Title"] retain];
	
	UIViewController *ctrl = [[ImagesListController alloc] initWithProfile:profile album:identifer albumName:albumName nav:navContrioller];
	[navContrioller pushViewController:ctrl animated:YES];			
	[ctrl release];
	[identifer release];
}

@end
