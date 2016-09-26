//
//  AppDelegate.m
//  ScreenCapture
//
//  Created by NSSimpleApps on 22.04.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "AppDelegate.h"
@import Photos;

@interface AppDelegate ()

@property (strong, nonatomic) PHAssetCollectionChangeRequest* collectionRequest;

@property (copy, nonatomic) NSString* existingAlbumIdentifier;

@end

@implementation AppDelegate

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        
        [self saveAssetToAlbum:[self grabWindow]];
    }
}

- (NSString*)applicationName {
    
    NSString* name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    if (name != nil) {
        
        return name;
    } else {
        
        return @"GrabbedImages";
    }
}

- (void)saveAssetToAlbum:(UIImage*)image {
    
    __block NSString* albumIdentifier = self.existingAlbumIdentifier;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        PHFetchResult* fetchCollectionResult;
        
        if (albumIdentifier) {
            
            fetchCollectionResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumIdentifier] options:nil];
        }
        
        if (!fetchCollectionResult || fetchCollectionResult.count ==0) {
            
            self.collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:[self applicationName]];
            albumIdentifier = self.collectionRequest.placeholderForCreatedAssetCollection.localIdentifier;
            
        } else {
            
            PHAssetCollection* exisitingCollection = fetchCollectionResult.firstObject;
            self.collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:exisitingCollection];
        }
        
        PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        [self.collectionRequest addAssets:@[createAssetRequest.placeholderForCreatedAsset]];
        
    } completionHandler:^(BOOL success, NSError *error) {
        
        if (success) {
            
            self.existingAlbumIdentifier = albumIdentifier;
            
            UILocalNotification* localNotification = [UILocalNotification new];
            localNotification.alertTitle = @"Screen has been captured";
            localNotification.alertBody = @"successfully";
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            
        } else {
            
            NSLog(@"%@", error);
        }
    }];
}

- (UIImage*)grabWindow {
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        
        UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, false, [UIScreen mainScreen].scale);
    } else {
        
        UIGraphicsBeginImageContext(self.window.bounds.size);
    }
    
    [self.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                                                         |UIUserNotificationTypeSound
                                                                                         |UIUserNotificationTypeAlert) categories:nil];
    [application registerUserNotificationSettings:settings];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    if (application.applicationState == UIApplicationStateInactive) {
        
        UIImagePickerController* imagePicker = [UIImagePickerController new];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self.window.rootViewController presentViewController:imagePicker animated:YES completion:nil];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
