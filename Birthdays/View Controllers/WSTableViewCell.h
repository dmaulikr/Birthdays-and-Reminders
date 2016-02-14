//
//  WSTableViewCell.h
//  Birthdays
//
//  Created by Irfan Lone on 11/2/15.
//  Copyright © 2015 Irfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *facebook;
@property (weak, nonatomic) IBOutlet UILabel *giftIdeas;

@end
