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

@interface PriceChangeQueueTableViewController ()
@property (nonatomic,retain) NSArray *priceChangeQueue;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSURLSessionConfiguration *sessionConfiguration;
@end

@implementation PriceChangeQueueTableViewController

@synthesize tableView = _tableView;
@synthesize priceChangeQueue = _priceChangeQueue;
@synthesize session = _session;
@synthesize sessionConfiguration = _sessionConfiguration;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.priceChangeQueue count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PriceChangeQueueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pc_change_queue_cell"];
    
    PFObject *item = [self.priceChangeQueue objectAtIndex:indexPath.row];
    PFObject *book = (PFObject *)item[@"book"];
    [cell.titleLabel setText:book[@"title"]];
    [cell.authorLabel setText:book[@"author"]];
    [cell.asinLabel setText:item[@"asin"]];
    [cell.priceLabel setText:[item[@"price"] stringValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd"];
    NSDate *changeDate = item[@"changeDate"];
    [cell.dateLabel setText:[dateFormatter stringFromDate:changeDate]];
    
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
    [cell.imageDownloadTask resume];
    
    return cell;
}

- (void)handleQueue:(NSArray *)queue
{
    self.priceChangeQueue = queue;
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration];
    
    PFQuery *query = [PFQuery queryWithClassName:@"PriceChangeQueue"];
    query.limit = 1000;
    [query includeKey:@"book"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *queue, NSError *error)
    {
        [self handleQueue:queue];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
