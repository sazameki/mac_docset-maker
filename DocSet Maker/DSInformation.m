//
//  DSInformation.m
//  DocSet Maker
//
//  Created by numata on 09/09/13.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "DSInformation.h"


NSInteger DSCompareInfo(id anInfo1, id anInfo2, void *context)
{
    NSString *value1 = ((DSInformation *)anInfo1).value;
    NSString *value2 = ((DSInformation *)anInfo2).value;
	
    return [value1 compare:value2 options:NSCaseInsensitiveSearch];
}    


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
    NSArray *appendableTagNames = [NSArray arrayWithObjects:/*@"@param",*/ @"@discussion", @"@return", nil];
    
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

- (NSArray *)allChildInfos
{
    return mChildInfos;
}

- (BOOL)hasChildWithTag:(NSString *)tag
{
    for (DSInformation *aChildInfo in mChildInfos) {
        if ([aChildInfo.tagName isEqualToString:tag]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)declaration
{
    NSString *decl = nil;
    NSArray *decls = [self childInfosWithTag:@"@declare"];
    if ([decls count] > 0) {
        DSInformation *declInfo = [decls objectAtIndex:0];
        decl = declInfo.value;
    }
    if ([decl length] == 0) {
        decl = nil;
    }
    return decl;
}

- (NSString *)docIdentifier
{
    if (![self.tagName isEqualToString:@"@method"] && ![self.tagName isEqualToString:@"@function"]) {
        return self.value;
    }
    NSString *decl = [self declaration];
    if (!decl) {
        return self.value;
    }
    NSMutableString *ret = [NSMutableString string];
    [ret appendFormat:@"%@/", self.value];
    unsigned pos = 0;
    unsigned length = [decl length];
    BOOL wasSpace = NO;
    while (pos < length) {
        unichar c = [decl characterAtIndex:pos++];
        if (isspace((int)c)) {
            if (!wasSpace) {
                [ret appendString:@"_"];
                wasSpace = YES;
            }
        } else if (c == '#') {
            [ret appendString:@"_pp_"];
            wasSpace = NO;
        } else if (c == '&') {
            [ret appendString:@"@"];
            wasSpace = NO;
        } else if (c == '<' || c == '>') {
            [ret appendString:@"@"];
            wasSpace = NO;
        } else {
            [ret appendFormat:@"%C", c];
            wasSpace = NO;
        }
    }
    return ret;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"info{ tag=%@, value=\"%@\", children=%@ }", mTagName, mValue, mChildInfos];
}

@end


