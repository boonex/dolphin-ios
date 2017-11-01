//
//  AudioAlbumsController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/26/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "AudioAlbumsController.h"
#import "Dolphin6AppDelegate.h"
#import "AudioListController.h"

@implementation AudioAlbumsController

- (id)initWithProfile:(NSString*)aProfile title:(NSString*)aProfileTitle nav:(UINavigationController*)aNav {
	if ((self = [super initWithProfile:aProfile title:aProfileTitle nav:aNav])) {
		method = @"dolphin.getAudioAlbums";
	}
	return self;
}

- (id)initWithProfile:(NSString*)aProfile nav:(UINavigationController*)aNav {
    return [self initWithProfile:aProfile title:aProfile nav:aNav];
}

- (void)viewDidLoad {
	self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"%@ music", @"User Music view title"), profileTitle];
	[super viewDidLoad];
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSDictionary *dict = [catList objectAtIndex:indexPath.row];
	NSString *identifer = [[dict valueForKey:@"Id"] retain];
    NSString *albumName = [[dict valueForKey:@"Title"] retain];
    NSString *albumDefault = [dict valueForKey:@"DefaultAlbum"];
    BOOL isDefaultAlbum = (nil == albumDefault || [albumDefault isEqualToString:@"1"]) ? TRUE : FALSE;
	
	UIViewController *ctrl = [[AudioListController alloc] initWithProfile:profile album:identifer albumName:albumName albumDefault:isDefaultAlbum nav:navContrioller];
	[navContrioller pushViewController:ctrl animated:YES];
	[ctrl release];
	[identifer release];

}

@end
