//
//  MyTableViewCell.h
//  Birthdays
//
//  Created by Irfan Lone on 11/2/15.
//  Copyright © 2015 Yuzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *facebook;
@property (weak, nonatomic) IBOutlet UILabel *giftIdeas;

@end
