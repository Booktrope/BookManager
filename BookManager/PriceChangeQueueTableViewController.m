//
//  ViewController.m
//  BookManager
//
//  Created by Justin Jeffress on 1/29/14.
//  Copyright (c) 2014 Booktrope. All rights reserved.
//

#import "PriceChangeQueueTableViewController.h"
#import <Parse/Parse.h>
#import "PriceChangeQueueCell.h"
#import "PriceChangeDetailViewController.h"

@interface PriceChangeQueueTableViewController ()
@property (nonatomic,retain) NSMutableArray *priceChangeQueue;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSURLSessionConfiguration *sessionConfiguration;
@end

@implementation PriceChangeQueueTableViewController

@synthesize tableView = _tableView;
@synthesize priceChangeQueue = _priceChangeQueue;
@synthesize session = _session;
@synthesize sessionConfiguration = _sessionConfiguration;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.priceChangeQueue count];
}

#pragma UITableViewHeaderFooterView
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    NSDictionary *sectionDictionary = [self.priceChangeQueue objectAtIndex:section];
    NSInteger status = [[sectionDictionary objectForKey:@"title"] integerValue];
    
    [self setUpHeaderFooterView:view forStatus:status];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    NSDictionary *sectionDictionary = [self.priceChangeQueue objectAtIndex:section];
    NSInteger status = [[sectionDictionary objectForKey:@"title"] integerValue];
    
    [self setUpHeaderFooterView:view forStatus:status];
}

-(void)setUpHeaderFooterView:(UIView *)view forStatus:(NSInteger)status
{
    UITableViewHeaderFooterView *headerFooterView = (UITableViewHeaderFooterView *)view;
    UIColor * color = [self colorForStatus:status];
    [headerFooterView.textLabel setTextColor:[UIColor whiteColor]];
    headerFooterView.contentView.backgroundColor = color;
    view.tintColor = color;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionDictionary = [self.priceChangeQueue objectAtIndex:section];
    return [self headerForStatus: [[sectionDictionary objectForKey:@"title"] integerValue]];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    
    return @"";
}

#pragma end of UITableViewHeaderFooterView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.priceChangeQueue objectAtIndex:section] objectForKey:@"data" ] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PriceChangeDetailViewController *priceChangeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BookDetailView"];
    
    NSDictionary *sectionDictionary = [self.priceChangeQueue objectAtIndex:indexPath.section];
    NSArray *sectionData = [sectionDictionary objectForKey:@"data"];
    PFObject *priceChangeInfo = [sectionData objectAtIndex:indexPath.row];
    PFObject *book = (PFObject *)priceChangeInfo[@"book"];
    
    priceChangeViewController.priceChangeInfo = priceChangeInfo;

    NSURL *url = [NSURL URLWithString:book[@"large_image"]];
    priceChangeViewController.dataTask = [self.session dataTaskWithURL:url completionHandler:
    ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error)
        {
            NSLog(@"ERROR: %@", error);
        }
        else
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200)
            {
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{priceChangeViewController.coverImage.image = image;});
            }
            else
            {
                NSLog(@"HTTP %ld",(long)httpResponse.statusCode);
            }
        }
    }];
    [priceChangeViewController.dataTask resume];
    
    [self.navigationController pushViewController:priceChangeViewController animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [priceChangeViewController.authorLabel setText:book[@"author"]];
        [priceChangeViewController.asinLabel setText:book[@"asin"]];

    });
    
}




#pragma HELPER FUNCTIONS
//Overriding the height for the UITableViewCell
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 172.0;
}

//returns a UIColor for a status number
-(UIColor *)colorForStatus:(NSInteger)status
{
    UIColor * color = [UIColor colorWithRed:33/255.0f green:99/255.0f blue:201/255.0f alpha:1.0f];
    
    switch (status) {
        case 0:
            color = [UIColor colorWithRed:240/255.0f green:216/255.0f blue:23/255.0f alpha:1.0f];
            break;
        case 25:
            color = [UIColor colorWithRed:230/255.0f green:88/255.0f blue:62/255.0f alpha:1.0f];
            break;
        case 50:
            color = [UIColor colorWithRed:139/255.0f green:122/255.0f blue:106/255.0f alpha:1.0f];
            break;
        case 99:
            color = [UIColor colorWithRed:174/255.0f green:217/255.0f blue:145/255.0f alpha:1.0f];
            break;
        default:
            break;
    }
    
    return color;
}

//returns the text for a status number.
-(NSString *)headerForStatus:(NSInteger)status
{
    NSString *result = @"";
    switch (status)
    {
        case 0:
            result = @"\tScheduled";
            break;
        case 25:
            result = @"\tAttempted";
            break;
        case 50:
            result = @"\tSet But Unconfirmed";
            break;
        case 99:
            result = @"\tConfirmed";
            break;
        default:
            break;
    }
    return result;
}
#pragma end of HELPER FUNCTIONS

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PriceChangeQueueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pc_change_queue_cell"];
    
    NSDictionary *sectionDictionary = [self.priceChangeQueue objectAtIndex:indexPath.section];
    NSArray *sectionData = [sectionDictionary objectForKey:@"data"];
    PFObject *item = [sectionData objectAtIndex:indexPath.row];
    
    PFObject *book = (PFObject *)item[@"book"];
    [cell.titleLabel setText:book[@"title"]];
    [cell.authorLabel setText:book[@"author"]];
    [cell.asinLabel setText:item[@"asin"]];
    [cell.priceLabel setText:[item[@"price"] stringValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    
    NSDate *changeDate = item[@"changeDate"];
    
    NSString *timeStamp = [dateFormatter stringFromDate:changeDate];
    
    [cell.dateLabel setText:timeStamp];
    
    if (cell.imageDownloadTask)
    {
        [cell.imageDownloadTask cancel];
    }
    
    cell.bookCover.image = nil;
    NSURL *imageUrl = [NSURL URLWithString:book[@"large_image"]];
    if (imageUrl) {
        cell.imageDownloadTask = [self.session dataTaskWithURL:imageUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            if(error)
            {
                NSLog(@"ERROR: %@", error);
            }
            else
            {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if(httpResponse.statusCode == 200)
                {
                    UIImage *image = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{cell.bookCover.image = image;});
                }
                else
                {
                    NSLog(@"Couldn't load image at URL: %@", imageUrl);
                    NSLog(@"HTTP %ld", (long)httpResponse.statusCode);
                }
            }
        }];
    }
    //IMPORTANT: forgetting to call resume = no download for you!
    [cell.imageDownloadTask resume];
    
    return cell;
}

//Called by the block to process the results from parse.com and convert it into a sectioned table based on status.
- (void)handleQueue:(NSArray *)queue
{
    NSInteger previous_status = -1;
    NSMutableArray *sectionedQueueArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *sectionedQueueDictionary;
    for (PFObject *item in queue)
    {
        if (previous_status != [item[@"status"] integerValue])
        {
            if (previous_status >= 0)
            {
                [sectionedQueueArray addObject:sectionedQueueDictionary];
            }
            sectionedQueueDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                    item[@"status"], @"title",
                    [[NSMutableArray alloc] init], @"data", nil];
        }
        [sectionedQueueDictionary[@"data"] addObject:item];
        
        previous_status = [item[@"status"] integerValue];
    }
    if (sectionedQueueArray)
    {
        [sectionedQueueArray addObject:sectionedQueueDictionary];
    }
    
    self.priceChangeQueue = sectionedQueueArray;
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)findDataFromParse
{
    //Querying the PriceChangeQueue from parse.com
    PFQuery *query = [PFQuery queryWithClassName:@"PriceChangeQueue"];
    query.limit = 1000; //TODO: support more than 1000 books/paging etc.
    [query includeKey:@"book"];
    [query orderByAscending:@"status,changeDate"]; //sorting based on status and changeDate
    
    //running the query in the background
    [query findObjectsInBackgroundWithBlock:^(NSArray *queue, NSError *error)
     {
         //TODO: Might be able to run a block on dispatch_get_main_queue instead of calling handleQueue
         [self handleQueue:queue];
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Setting up the NSURLSession which is used to download the book images from amazon.
    self.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration];
    
    
    UIRefreshControl *refresher = [[UIRefreshControl alloc] init];
    refresher.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresher addTarget:self action:@selector(findDataFromParse) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresher;
    
    [self findDataFromParse];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
