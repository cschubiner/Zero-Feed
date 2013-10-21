//
//  MasterViewController.m
//  ARSSReader
//
//  Created by Marin Todorov on 29/10/2012.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "TableHeaderView.h"

#import "RSSLoader.h"
#import "RSSItem.h"

@interface MasterViewController ()
{
    NSArray *_objects;
    NSURL* feedURL;
    UIRefreshControl* refreshControl;
}
@end

@implementation MasterViewController
@synthesize userName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //configuration
    self.title = @"Articles";
 //   feedURL = [NSURL URLWithString:@"http://feeds.feedburner.com/TouchCodeMagazine"];
    
    //add refresh control to the table view
    refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self
                       action:@selector(refreshInvoked:forState:)
             forControlEvents:UIControlEventValueChanged];
    
   // NSString* fetchMessage = [NSString stringWithFormat:@"Fetching: %@",feedURL];
    
    NSString* fetchMessage = @"Refreshing your feeds...";

    
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:fetchMessage
                                                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:11.0]}];
    
    [self.tableView addSubview: refreshControl];
    
    //add the header
    self.tableView.tableHeaderView = [[TableHeaderView alloc] initWithText:@"Generating articles..."];
    
    [self refreshFeed];
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state
{
    [self refreshFeed];
}

-(void)refreshFeed
{
 /*   RSSLoader* rss = [[RSSLoader alloc] init];
    [rss fetchRssWithURL:feedURL
                complete:^(NSString *title, NSArray *results) {

                    //completed fetching the RSS
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //UI code on the main queue
                        [(TableHeaderView*)self.tableView.tableHeaderView setText:title];
                        
                        _objects = results;
                        [self.tableView reloadData];
                        
                        // Stop refresh control
                        [refreshControl endRefreshing];
                    });
                }];*/
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    NSString * articlesURL = [NSString stringWithFormat:@"/u/46621227/zerofeed/articles/%@.json", userName];
    [objectManager getObjectsAtPath: articlesURL
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                NSArray* statuses = [mappingResult array];
                              //  NSLog(@"Loaded statuses: %@", statuses);
                                _objects = statuses;
                                [self.tableView reloadData];
                                [(TableHeaderView*)self.tableView.tableHeaderView setText:@"Generated News Articles"];
                                // Stop refresh control
   
                            }
                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                message:[error localizedDescription]
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                                [alert show];
                                NSLog(@"Hit error: %@", error);
                            }];

}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    RSSItem *object = _objects[indexPath.row];
    //cell.textLabel.attributedText = object.cellMessage;
    object.description = @"Feed description here";
    cell.textLabel.attributedText = [object cellMessage];
    cell.textLabel.numberOfLines = 0;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSSItem *item = [_objects objectAtIndex:indexPath.row];
    CGRect cellMessageRect = [item.cellMessage boundingRectWithSize:CGSizeMake(200,10000)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                            context:nil];
    return cellMessageRect.size.height;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RSSItem *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
