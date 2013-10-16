//
//  MKAnnotationView+Extensions.m
//  mainapp
//
//  Created by Eric Roland on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MKAnnotationView+Extensions.h"
#import <objc/runtime.h>
static char ITEM_ID_KEY;

@implementation MKAnnotationView (Extensions)
@dynamic itemId;

- (NSString*)itemId {
    NSString *associatedItemId = (NSString*)objc_getAssociatedObject(self, &ITEM_ID_KEY);
    return associatedItemId;
}

- (void)setItemId:(NSString*)itemId {
    objc_setAssociatedObject(self, &ITEM_ID_KEY, itemId, OBJC_ASSOCIATION_RETAIN);
}

@end
