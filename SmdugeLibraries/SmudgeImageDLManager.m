//
//  SmudgeImageDLManager.m
//  StuffNZ
//
//  This class is designed to be a drop in class for any project
//  To Use:
//  1 - Add an observer to the class with the name of the image link
//  2 - Call downloadImageForLink on the sharedManager (Singleton)
//  3 - Wait for the notificaiton then use the singleton instance to getImageForLink
//
//  All images are stored on /tmp/ following Apple's guidelines. You may change this however if you wanted to.
//
//  Created by Hisatomo Umaoka on 4/04/11.
//  Copyright 2011 Smudge Apps Ltd. All rights reserved.
//

#import "SmudgeImageDLManager.h"
#include <sys/xattr.h>

@interface SmudgeImageInvocations : NSInvocationOperation {
@private
    NSString *imageURL;
}
@property (nonatomic, retain) NSString *imageURL;
@end

@implementation SmudgeImageInvocations
@synthesize imageURL;
-(void) dealloc{
    self.imageURL = nil;
}

@end

@implementation SmudgeImageDLManager
@synthesize operationQueue,imagePath;

#if UIUserInterfaceIdiomPad
#define MAX_CONCURRENT_OP 1
#else
#define MAX_CONCURRENT_OP 1
#endif

#define IPAD_DATA_LIMIT 2000000
#define IPHONE_DATA_LIMIT 1000000

#pragma mark - File Modifications
-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL{
    
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

#pragma mark - Singletone
+(SmudgeImageDLManager *) sharedManager{
    static SmudgeImageDLManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SmudgeImageDLManager alloc] init];
    });
    
    return manager;
}

#pragma mark - Initialization
-(id) init{
    self = [super init];
    
    if (self) {
        self.imagePath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/"];
        self.operationQueue = [[NSOperationQueue alloc] init];
        [self.operationQueue setMaxConcurrentOperationCount:MAX_CONCURRENT_OP];
    }
    
    return self;
}

#pragma - BOOL Methods
-(BOOL)imageExists:(NSString *)path{
    
    //More safety checking
    if ([path isKindOfClass:[NSString class]]) {
        if (path.length <= 0) {
            return NO;
        }
    }
    else{
        return NO;
    }
    
	NSString *filePaths = [SmudgeImageDLManager sharedManager].imagePath;
	
	//get file name
	int pos = [path rangeOfString:@"/" options:NSBackwardsSearch].location;
	if(pos!=NSNotFound){
		NSString *fileName = [path substringFromIndex:pos+1];
		fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"."];
		NSString *saveLocation = [NSString stringWithFormat:@"%@%@", filePaths, fileName];
        
		return [[NSFileManager defaultManager] fileExistsAtPath:saveLocation];
	}
	return NO;
}

#pragma mark - Data Processing
-(UIImage *)imageWithData:(NSData *)data{
	UIImage *tempImage = [UIImage imageWithData:data];
	
	int scale = [UIScreen mainScreen].scale;
	if(scale==2){
		tempImage = [UIImage imageWithCGImage:tempImage.CGImage scale:2.0 orientation:UIImageOrientationUp];
	}
	
	return tempImage;
}

-(void) imageFinishedNotification:(NSString *)imageLink{
    [[NSNotificationCenter defaultCenter] postNotificationName:imageLink object:imageLink];
}

-(void) saveImageForLink:(NSString *)imageLink{
    @autoreleasepool {
        NSURL *url = [NSURL URLWithString:imageLink];
        NSString *filePaths = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/"];
        
        //get file name
        int pos = [imageLink rangeOfString:@"/" options:NSBackwardsSearch].location;
        
        NSString *fileName = nil;
            
            fileName = [imageLink substringFromIndex:pos+1];
            fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"."];
        
        NSString *saveLocation = [NSString stringWithFormat:@"%@%@", filePaths, fileName];
        
        NSData *data = [[NSData alloc] initWithContentsOfURL:url];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            if (data.length > IPAD_DATA_LIMIT) {
                [self performSelectorOnMainThread:@selector(imageFinishedNotification:) withObject:imageLink waitUntilDone:NO];
                return;
            }
        }
        else{
            if (data.length > IPHONE_DATA_LIMIT) {
                [self performSelectorOnMainThread:@selector(imageFinishedNotification:) withObject:imageLink waitUntilDone:NO];
                return;
            }}
        
        UIImage *image = [self imageWithData:data];
        
        if ([imageLink rangeOfString:@".png"].location != NSNotFound) {
            if ([UIImagePNGRepresentation(image) writeToFile:saveLocation atomically:YES]) {
                ;//File is written fine
                if (![self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:[saveLocation stringByReplacingOccurrencesOfString:@" " withString:@"\\ "]]]) {
                }
            }
        }
        else{
            if([UIImageJPEGRepresentation(image, 1.0) writeToFile:saveLocation atomically:YES]){
                ;//file is written fine
                if (![self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:[saveLocation stringByReplacingOccurrencesOfString:@" " withString:@"\\ "]]]) {
                }
            }
        }
        
        [self performSelectorOnMainThread:@selector(imageFinishedNotification:) withObject:imageLink waitUntilDone:NO];
    }        
}

#pragma mark - Download Methods
-(void) downloadImageForLink:(NSString *) imageLink withQueuePriority:(int) queuePriority{
    if ([self imageExists:imageLink]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:imageLink object:imageLink];
        return;
    }
    
    SmudgeImageInvocations *inv = nil;
    
    //Go through each operations and see if we've already requested it
    for (SmudgeImageInvocations *op in [operationQueue operations]) {
        if ([op.imageURL isEqualToString:imageLink]) {
            //Get a reference to it
            inv = op;
            break;
        }
    }
    
    //If we already requested the data before, then set the priority to high, else create a new operation
    if(inv != nil){
        [inv setQueuePriority:queuePriority];
    }
    else{
        SmudgeImageInvocations *operation = [[SmudgeImageInvocations alloc] initWithTarget:self selector:@selector(saveImageForLink:) object:imageLink];
        operation.imageURL = imageLink;
        [operation setQueuePriority:queuePriority];
        [operationQueue addOperation:operation];
    }
}

#pragma mark - Getters
-(UIImage *) getImageForLink:(NSString *)imageLink{
	NSString *filePaths = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/"];
	
    if (imageLink.length <= 0) {
        return nil;
    }
        
    //get file name
	int pos = [imageLink rangeOfString:@"/" options:NSBackwardsSearch].location;
    
    NSString *fileName = nil;
    
    fileName = [imageLink substringFromIndex:pos+1];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"."];
    
	NSString *saveLocation = [NSString stringWithFormat:@"%@%@", filePaths, fileName];
    
	if([[NSFileManager defaultManager] fileExistsAtPath:saveLocation]){
		UIImage *image = [self imageWithData:[NSData dataWithContentsOfFile:saveLocation]];
        
        return image;
	}
	
	return nil;
}

-(NSString *)getImageNameForLink:(NSString *)imageLink{    
    NSString *fileName = nil;
    int pos = [imageLink rangeOfString:@"/" options:NSBackwardsSearch].location;
    
    fileName = [imageLink substringFromIndex:pos+1];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"."];

    return fileName;
}

@end
