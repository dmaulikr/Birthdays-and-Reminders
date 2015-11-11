//
//  AddNewItemViewController.m
//  Birthdays
//
//  Created by Irfan Lone on 11/11/15.
//  Copyright © 2015 Yuzu. All rights reserved.
//

#import "AddNewItemViewController.h"
#import "SDCoreDataController.h"

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
    
    NSManagedObjectContext *moc = [[SDCoreDataController sharedInstance] newManagedObjectContext];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Birthday" inManagedObjectContext:moc];
    [newManagedObject setValue:self.facebook.text forKey:@"facebook"];
    [newManagedObject setValue:self.birthday.text forKey:@"birthday"];
    [newManagedObject setValue:self.name.text forKey:@"name"];
    
    [moc performBlockAndWait:^{
        BOOL success = [moc save:nil];
        if (!success) {
            NSLog(@"Unable to save context for class ");
        }
    }];
    [[SDCoreDataController sharedInstance] saveMasterContext];
    [self dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self postRequest];
        });
    }];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)postRequest
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSDictionary * jsonData = @{@"name":self.name.text, @"facebook": self.facebook.text, @"giftIdeas": self.birthday.text};
    NSURLRequest * urlRequest = [self createRequestWithDictionary:jsonData];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger responseStatusCode = httpResponse.statusCode;
        
        if (error == nil && (responseStatusCode >= 200 && responseStatusCode <= 299)) {
            
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
            NSLog(@"%@",responseDictionary);
        } else {
            
        }
    }];
    [dataTask resume];
    [session finishTasksAndInvalidate];
}

#pragma mark private

- (NSMutableURLRequest *)createRequestWithDictionary:(NSDictionary*)parameters
{
    NSString * urlstr = @"https://api.parse.com/1/classes/Birthday";
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSError * error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    [request setHTTPBody:jsonData];
    NSDictionary * headers = [self generateHeader];
    request.allHTTPHeaderFields = headers;
    return request;
}


- (NSMutableDictionary<NSString *, NSString *> *)generateHeader
{
    NSMutableDictionary<NSString *, NSString *> *headers = [NSMutableDictionary dictionary];
    [headers setValue:@"RplMa0mTwS9oIldaaG3kvJbnqqMUIU4PZmv9UlEb" forKey:@"X-Parse-REST-API-Key"];
    [headers setValue:@"ZXZJQAqUyVrq1HJel5DoOHquqxw1jqbfMumRQdib" forKey:@"X-Parse-Application-Id"];
    [headers setValue:@"application/json" forKey:@"Content-Type"];
    return headers;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
