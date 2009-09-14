//
//  DSInformation.h
//  DocSet Maker
//
//  Created by numata on 09/09/13.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DSInformation : NSObject {
    NSString        *mTagName;
    NSString        *mValue;
    NSMutableArray  *mChildInfos;
}

@property(copy, readonly)   NSString *tagName;
@property(copy, readwrite)  NSString *value;

- (id)initWithTag:(NSString *)tag;

- (BOOL)appendValue:(NSString *)value;

- (void)addChildInformation:(DSInformation *)anInfo;

- (NSArray *)childInfosWithTag:(NSString *)tag;

- (NSString *)declaration;
- (NSString *)docIdentifier;

@end


NSInteger DSCompareInfo(id anInfo1, id anInfo2, void *context);


