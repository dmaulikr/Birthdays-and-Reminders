//
//  DetailViewController.h
//  Birthdays
//
//  Created by Irfan Lone on 11/1/15.
//  Copyright © 2015 Irfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

