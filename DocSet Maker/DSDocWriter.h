//
//  DSDocWriter.h
//  DocSet Maker
//
//  Created by numata on 09/09/14.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DSDocWriter : NSObject {
}

- (BOOL)writeDocumentAtPath:(NSString *)path properties:(NSDictionary *)properties;

@end


