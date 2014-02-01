//
//  PriceChangeDetailViewController.m
//  BookManager
//
//  Created by Justin Jeffress on 1/31/14.
//  Copyright (c) 2014 Booktrope. All rights reserved.
//

#import "PriceChangeDetailViewController.h"

@implementation PriceChangeDetailViewController

- (void)viewDidLoad
{
    self.navigationItem.title = @"Price Change"; //self.priceChangeInfo[@"book"][@"title"];
    
    NSString *headerPriceChange = @"Price Change";
    NSString *headerBookTitle = @"Book: ";
    NSString *headerNewPrice = @"New Price: ";
    NSString *headerDate = @"On or Before: ";
    
    
    NSString *formatter = @"%@\n\n%@%@\n%@$%.2f\n%@%@ 12:01 AM (PST)\n";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:self.priceChangeInfo[@"changeDate"]];
    
    
    NSString *displayText = [NSString stringWithFormat:formatter, headerPriceChange, headerBookTitle, self.priceChangeInfo[@"book"][@"title"], headerNewPrice, [self.priceChangeInfo[@"price"] doubleValue], headerDate, timeStamp];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:displayText];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:NSMakeRange(0,[headerPriceChange length])];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:NSMakeRange([displayText rangeOfString:headerBookTitle].location,[headerBookTitle length])];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:12]
                           range:NSMakeRange([displayText rangeOfString:self.priceChangeInfo[@"book"][@"title"]].location
                                              , [self.priceChangeInfo[@"book"][@"title"] length])];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:NSMakeRange([displayText rangeOfString:headerNewPrice].location, [headerNewPrice length])];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:NSMakeRange([displayText rangeOfString:headerDate].location, [headerDate length])];
    
    NSLog(@"ID: %@", self.priceChangeInfo.objectId);
    
    self.priceChangeText.attributedText = attributedText;
    //self.priceChangeText.text = [NSString stringWithFormat:formatter, self.priceChangeInfo[@"book"][@"title"], [self.priceChangeInfo[@"price"] doubleValue], timeStamp];
    
}

@end
