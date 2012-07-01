//
//  SmudgeImageDLManager.h
//  Smudge
//
//  Created by Hisatomo Umaoka on 4/04/11.
//  Copyright 2011 Smudge Apps Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmudgeImageDLManager : NSObject

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSString *imagePath;

//The shared instance
+(SmudgeImageDLManager *) sharedManager;

//Call to download
-(void) downloadImageForLink:(NSString *) imageLink withQueuePriority:(int) queuePriority;

//Getters
-(NSString *)getImageNameForLink:(NSString *)imageLink;
-(UIImage *) getImageForLink:(NSString *)imageLink;

//Booleans
-(BOOL)imageExists:(NSString *)path;

//Creation
-(UIImage *)imageWithData:(NSData *)data;

//Helpers
/* This will skip the do not backup to iCloud attribute to any file */
-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end
