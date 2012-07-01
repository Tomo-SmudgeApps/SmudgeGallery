//
//  SmudgePhotoContainer.m
//  Smudge
//
//  This class reacts to the touch on the gallery to change state. Just fires a notification
//  Created by Hisatomo Umaoka on 7/29/10.
//  Copyright 2010 Smudge Apps Ltd. All rights reserved.
//

#import "SmudgePhotoContainer.h"


@implementation SmudgePhotoContainer

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesEnded:touches withEvent:event];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"changeGalleryViewState" object:nil];
}

@end
