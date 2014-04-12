//
//  PriceChangeQueueCell.h
//  BookManager
//
//  Created by Justin Jeffress on 1/29/14.
//  Copyright (c) 2014 Booktrope. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PriceChangeQueueCell : UITableViewCell
//assigned and invoked by it's UITableViewController the completion block sets the bookCover
@property (strong, nonatomic) NSURLSessionDataTask *imageDownloadTask;
@property (strong, nonatomic) IBOutlet UIImageView *bookCover;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *amazonLabel;
@property (weak, nonatomic) IBOutlet UILabel *appleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nookLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end
