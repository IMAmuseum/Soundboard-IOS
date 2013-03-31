//
//  MainViewController.m
//  Sound Board
//
//  Created by Daniel Cervantes on 3/30/13.
//  Copyright (c) 2013 ima. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "SBSound.h"

@interface MainViewController ()
@property (nonatomic, weak) IBOutlet UITableView *questionListTable;
@property (nonatomic, strong) NSMutableArray *filteredSounds;
@property (nonatomic, strong) NSArray *sounds;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;

- (IBAction)reloadData:(id)sender;
- (void)loadData;
- (void)playSound:(SBSound *)sound;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.questionListTable reloadData];
    [self.questionListTable deselectRowAtIndexPath:[self.questionListTable indexPathForSelectedRow] animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
}

- (void)loadData
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SBSound" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setEntity:entityDescription];
    
    NSError *error;
    
    // retrieve sounds
    self.sounds = [[NSArray alloc] initWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    self.filteredSounds = [NSMutableArray arrayWithCapacity:[self.sounds count]];
    
    if (self.savedSearchTerm) {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setText:self.savedSearchTerm];
        self.savedSearchTerm = nil;
    }
    [self.questionListTable reloadData];
}

- (void)playSound:(SBSound *)sound
{
    NSHTTPURLResponse *response;
    NSError  *error;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *soundBoardEndpoint = [defaults objectForKey:@"SoundBoardEndpoint"];
    
    NSString *commandEndpoint = [NSString stringWithFormat:@"%@/%@", soundBoardEndpoint, sound.command];
    NSURL *url = [NSURL URLWithString:commandEndpoint];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    
    [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    if (error == nil && response.statusCode == 200) {
        NSLog(@"Sent");
    } else {
        NSLog(@"Failed to send");
    }
}

#pragma mark - Actions
- (IBAction)reloadData:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate loadSounds];
    [self loadData];
    
    [self.questionListTable deselectRowAtIndexPath:[self.questionListTable indexPathForSelectedRow] animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredSounds count];
    } else {
        return [self.sounds count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBSound *sound;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SoundCell"];
	if (cell == nil) {
		// Create a new reusable table cell
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SoundCell"];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        sound = [self.filteredSounds objectAtIndex:indexPath.row];
    } else {
        sound = [self.sounds objectAtIndex:indexPath.row];
    }
    [cell.textLabel setText:sound.title];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self playSound:[self.filteredSounds objectAtIndex:indexPath.row]];
    } else {
        [self playSound:[self.sounds objectAtIndex:indexPath.row]];
    }
    [self.questionListTable deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.filteredSounds removeAllObjects];
    
    for (SBSound *sound in self.sounds) {
        NSComparisonResult result = [(NSString *)sound.title compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        if (result == NSOrderedSame) {
            [self.filteredSounds addObject:sound];
        }
    }
}

#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate loadSounds];
    [self loadData];
    
    [self.questionListTable deselectRowAtIndexPath:[self.questionListTable indexPathForSelectedRow] animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

@end
