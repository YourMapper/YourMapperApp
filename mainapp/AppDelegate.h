//
//  AppDelegate.h
//  mainapp
//
//  Created by Eric Roland on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Location.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSDictionary *defaults;
    UITabBarController *_tabBarController;
}

@property (nonatomic, retain, readonly) NSDictionary *defaults;
@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

- (void)saveContext;
- (NSString *)applicationDocumentsDirectory;
- (BOOL)validateEmail:(NSString *)candidate;
- (NSString *)stringWithUrl:(NSURL *)url;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+ (UIImage *)scale:(UIImage *)image toSize:(CGSize)size;
+ (void)showConnectionError;
+ (BOOL)isRetina;

@end
