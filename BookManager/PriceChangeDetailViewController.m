//
//  PriceChangeDetailViewController.m
//  BookManager
//
//  Created by Justin Jeffress on 1/31/14.
//  Copyright (c) 2014 Booktrope. All rights reserved.
//

#import "PriceChangeDetailViewController.h"

@implementation PriceChangeDetailViewController

-(NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    NSString *subject = @"";
    if ([activityType isEqualToString:UIActivityTypeMail])
    {
        subject = [NSString stringWithFormat:@"Price Change For %@", self.priceChangeInfo[@"book"][@"title"]];
    }
    else
    {
        //TODO: add support for more Activity Types
        ;
    }
    return subject;
}

-(id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    NSString *item;
    PFObject *book = self.priceChangeInfo[@"book"];
    NSString *timeStamp = [self convertPSTBackToUTC:(NSDate *)self.priceChangeInfo[@"changeDate"]];
    if ([activityType isEqualToString:UIActivityTypePostToTwitter])
    {
        NSString *formatter = @"will be $%.2f starting %@ for a limited time! http://amzn.com/%@";
        item = [NSString stringWithFormat:formatter, [self.priceChangeInfo[@"price"] doubleValue], timeStamp, book[@"asin"]];
        const NSInteger MaxTwitterLength = 140;
        const NSInteger EllipsesLength = 4; //3 dots plus 1 space
        
        NSString *title = book[@"title"];
        NSInteger leftOver;
        if ([title length] + [item length] > MaxTwitterLength)
        {
            leftOver = MaxTwitterLength - EllipsesLength - [title length];
            title = [NSString stringWithFormat: @"%@... ", [title substringToIndex:leftOver]];
        }
        item = [NSString stringWithFormat:@"%@%@", title, item];
    }
    else if([activityType isEqualToString:UIActivityTypeMail])
    {
        NSString *formatter = @"Price Change\n\nTitle:%@\nAuthor: %@\nPrice: %.2f\nDate: %@\nASIN: %@\nParse Object Id: %@";
        item = [NSString stringWithFormat:formatter, book[@"title"], book[@"author"], [self.priceChangeInfo[@"price"] doubleValue], timeStamp, book[@"asin"], self.priceChangeInfo.objectId];
    }
    
    return item;
}

-(id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"placeholder";
}



- (void)actionButtonPressed:(id)sender
{
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects: self,nil] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:^{}];
}

- (NSString *)convertPSTBackToUTC:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:date];
    return timeStamp;
}

- (void)viewDidLoad
{
    self.navigationItem.title = @"Price Change"; //self.priceChangeInfo[@"book"][@"title"];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    self.navigationItem.rightBarButtonItem = shareButton;
    
    NSString *headerPriceChange = @"Price Change";
    NSString *headerBookTitle = @"Book: ";
    NSString *headerNewPrice = @"New Price: ";
    NSString *headerDate = @"On or Before: ";
    
    
    NSString *formatter = @"%@\n\n%@%@\n%@$%.2f\n%@%@ 12:01 AM (PST)\n";
    
    NSString *timeStamp = [self convertPSTBackToUTC:(NSDate *)self.priceChangeInfo[@"changeDate"]];
   
    
    
    NSString *displayText = [NSString stringWithFormat:formatter, headerPriceChange, headerBookTitle, self.priceChangeInfo[@"book"][@"title"], headerNewPrice, [self.priceChangeInfo[@"price"] doubleValue], headerDate, timeStamp];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:displayText];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:NSMakeRange(0,[headerPriceChange length])];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:NSMakeRange([displayText rangeOfString:headerBookTitle].location,[headerBookTitle length])];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:12]
                           range:NSMakeRange([displayText rangeOfString:self.priceChangeInfo[@"book"][@"title"]].location
                                              , [self.priceChangeInfo[@"book"][@"title"] length])];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:NSMakeRange([displayText rangeOfString:headerNewPrice].location, [headerNewPrice length])];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:NSMakeRange([displayText rangeOfString:headerDate].location, [headerDate length])];
    
    self.priceChangeText.attributedText = attributedText;
}

@end
