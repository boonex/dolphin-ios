//
//  UserPicker.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 10/31/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "BasePickerController.h"

@implementation BasePickerController

@synthesize reciver;

- (id)initWithReciver:(id)aReciver nav:(UINavigationController *)aNav {
	if ((self = [super initWithNibName:@"UserPickerView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
		self.reciver = aReciver; // retain via accessor
		dataList = nil;
		navController = aNav;
	}
	return self;
}

- (void)dealloc {		
	[lettersDict release];
	[reciver release];
	[dataList release];
	[super dealloc];
}

- (void)viewDidLoad {
	[self requestData];
	
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)requestData {	
	
}

/**********************************************************************************************************************
 DELEGATES
 **********************************************************************************************************************/

#pragma mark - UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return lettersDict ? [lettersDict count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (indexList) {
		NSString *strLetter = [indexList objectAtIndex:section];
		NSArray *a = [lettersDict valueForKey:strLetter];
		return [a count];
	} 
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	
	NSString *strLetter = [indexList objectAtIndex:indexPath.section];
	NSArray *a = [lettersDict valueForKey:strLetter];

	NSMutableDictionary *dict = [a objectAtIndex:indexPath.row];
	NSString* name = [dict valueForKey:nameKey];
	cell.textLabel.text = name; 	
	cell.accessoryType = UITableViewCellAccessoryNone;
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[navController popViewControllerAnimated:YES];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return indexList;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// The header for the section is the region name -- get this from the dictionary at the section index
	return [indexList objectAtIndex:section];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

- (void)actionRequestData:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"data list: %@", resp);
	
	if (nil == dataList)
	{
		dataList = [resp retain];
		[self buildIndex];
		[table reloadData];
	}
}

- (void) buildIndex {

	lettersDict = [[NSMutableDictionary alloc] init];
	
	for (NSMutableDictionary *dict in dataList) {
				
		NSString* name = [dict valueForKey:nameKey];
		
		NSString *firstLetter = [name substringToIndex:1];
		NSMutableArray *indexArray = [lettersDict objectForKey:firstLetter];
		if (indexArray == nil) {
			indexArray = [[NSMutableArray alloc] init];
			[lettersDict setObject:indexArray forKey:firstLetter];
			[indexArray release];
		}
		
		[indexArray addObject:dict];
	}
	indexList = [[lettersDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

@end
