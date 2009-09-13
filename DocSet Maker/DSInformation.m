//
//  DSInformation.m
//  DocSet Maker
//
//  Created by numata on 09/09/13.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "DSInformation.h"


@implementation DSInformation

@synthesize tagName = mTagName;
@synthesize value = mValue;

- (id)initWithTag:(NSString *)tag
{
    self = [super init];
    if (self) {
        mTagName = [tag retain];
        self.value = @"";
        
        mChildInfos = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc
{
    [mTagName release];
    [mValue release];
    [mChildInfos release];
    [super dealloc];
}

- (BOOL)appendValue:(NSString *)value
{
    NSArray *appendableTagNames = [NSArray arrayWithObjects:@"@param", @"@discussion", @"@return", nil];
    
    if (![appendableTagNames containsObject:mTagName]) {
        return NO;
    }
    
    //value = [@" " stringByAppendingString:value];
    self.value = [self.value stringByAppendingString:value];
    return YES;
}

- (void)addChildInformation:(DSInformation *)anInfo
{
    [mChildInfos addObject:anInfo];
}

- (NSArray *)childInfosWithTag:(NSString *)tag
{
    NSMutableArray *ret = [NSMutableArray array];
    for (DSInformation *aChildInfo in mChildInfos) {
        if ([aChildInfo.tagName isEqualToString:tag]) {
            [ret addObject:aChildInfo];
        }
    }
    return ret;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"info{ tag=%@, value=\"%@\", children=%@ }", mTagName, mValue, mChildInfos];
}

@end


