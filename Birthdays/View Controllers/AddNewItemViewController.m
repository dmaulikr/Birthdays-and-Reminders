//
//  AddNewItemViewController.m
//  Birthdays
//
//  Created by Irfan Lone on 11/11/15.
//  Copyright © 2015 Irfan. All rights reserved.
//

#import "AddNewItemViewController.h"
#import "WSCoreDataController.h"
#import "WSParseAPIClient.h"
#import "WSTransport.h"
#import "WSSyncEngine.h"

@interface AddNewItemViewController ()
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *birthday;
@property (weak, nonatomic) IBOutlet UITextField *facebook;

@end

@implementation AddNewItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)savePressed:(id)sender {
    
    if ([self.name.text isEqualToString:@""] || [self.facebook.text isEqualToString:@""] || [self.birthday.text isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"some field is empty" message:@"Please check again" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSManagedObjectContext *moc = [[WSCoreDataController sharedInstance] newManagedObjectContext];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Birthday" inManagedObjectContext:moc];
    [newManagedObject setValue:self.facebook.text forKey:@"facebook"];
    [newManagedObject setValue:self.birthday.text forKey:@"birthday"];
    [newManagedObject setValue:self.name.text forKey:@"name"];
    [newManagedObject setValue:[NSNumber numberWithInt:WSObjectCreated] forKey:@"syncStatus"];
    
    [moc performBlockAndWait:^{
        BOOL success = [moc save:nil];
        if (!success) {
            NSLog(@"Unable to save context for class ");
        }
    }];
    [[WSCoreDataController sharedInstance] saveMasterContext];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark private


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
