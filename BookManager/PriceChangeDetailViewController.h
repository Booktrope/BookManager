//
//  PriceChangeDetailViewController.h
//  BookManager
//
//  Created by Justin Jeffress on 1/31/14.
//  Copyright (c) 2014 Booktrope. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PriceChangeDetailViewController : UIViewController <UIActivityItemSource>

@property (nonatomic, retain) NSURLSessionDataTask *dataTask;
@property (nonatomic, weak) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *asinLabel;
@property (nonatomic, retain) PFObject *priceChangeInfo;
@property (weak, nonatomic) IBOutlet UITextView *priceChangeText;

@end
