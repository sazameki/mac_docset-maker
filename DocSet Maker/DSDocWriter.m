//
//  DSDocWriter.m
//  DocSet Maker
//
//  Created by numata on 09/09/14.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "DSDocWriter.h"
#import "DSInfoRepository.h"
#import "DSInformation.h"
#import "NSString+Tokenizer.h"


@implementation DSDocWriter

- (BOOL)writeInstanceVariablesOfClassInfo:(DSInformation *)aClassInfo intoString:(NSMutableString *)htmlStr
{
    NSArray *vars = [aClassInfo childInfosWithTag:@"@var"];
    if ([vars count] == 0) {
        return NO;
    }

    [htmlStr appendString:@"<h2>Instance Variables</h2>"];

    for (DSInformation *aVarInfo in vars) {
        [htmlStr appendFormat:@"<h3>%@</h3>", aVarInfo.value];

        NSArray *abstracts = [aVarInfo childInfosWithTag:@"@abstract"];
        if ([abstracts count] > 0) {
            DSInformation *abstractInfo = [abstracts objectAtIndex:0];
            [htmlStr appendFormat:@"<p>%@</p>", abstractInfo.value];
        }

        NSArray *decls = [aVarInfo childInfosWithTag:@"@declare"];
        if ([decls count] > 0) {
            DSInformation *declInfo = [decls objectAtIndex:0];
            [htmlStr appendFormat:@"<p>%@</p>", declInfo.value];
        }
        
        NSArray *discussions = [aVarInfo childInfosWithTag:@"@discussion"];
        for (DSInformation *aDiscussInfo in discussions) {
            [htmlStr appendFormat:@"<p>%@</p>", aDiscussInfo.value];
        }
        
        // TODO: Prepare any kind of switch to set whether we use "Declared in" or not.
        /*
        NSArray *declareds = [aVarInfo childInfosWithTag:@"*declared-in"];
        if ([declareds count] > 0) {
            DSInformation *declaredInfo = [declareds objectAtIndex:0];
            [htmlStr appendString:@"<h5>Declared In</h5>"];
            NSString *declaringFilePath = declaredInfo.value;
            [htmlStr appendFormat:@"<p>%@</p>", [declaringFilePath lastPathComponent]];
        } 
         */
    }
    
    return YES;
}

- (BOOL)writeInstanceMethodsOfClassInfo:(DSInformation *)aClassInfo intoString:(NSMutableString *)htmlStr
{
    NSArray *methods = [aClassInfo childInfosWithTag:@"@method"];
    if ([methods count] == 0) {
        return NO;
    }
    
    NSMutableArray *classMethodInfos = [NSMutableArray array];
    NSMutableArray *instanceMethodInfos = [NSMutableArray array];

    for (DSInformation *aMethodInfo in methods) {
        NSString *decl = nil;
        NSArray *decls = [aMethodInfo childInfosWithTag:@"@declare"];
        if ([decls count] > 0) {
            DSInformation *declInfo = [decls objectAtIndex:0];
            decl = declInfo.value;
        }
        if (decl && [decl hasPrefix:@"static"]) {
            [classMethodInfos addObject:aMethodInfo];
        } else {
            [instanceMethodInfos addObject:aMethodInfo];
        }
    }
    
    if ([classMethodInfos count] > 0) {
        [htmlStr appendString:@"<h2>Class Methods</h2>"];
        
        for (DSInformation *aMethodInfo in classMethodInfos) {
            [htmlStr appendFormat:@"<a name=\"//apple_ref/cpp/clm/%@/%@\"></a>", aClassInfo.value, aMethodInfo.value];
            [htmlStr appendFormat:@"<h3>%@</h3>", aMethodInfo.value];
            
            NSArray *decls = [aMethodInfo childInfosWithTag:@"@declare"];
            if ([decls count] > 0) {
                DSInformation *declInfo = [decls objectAtIndex:0];
                [htmlStr appendFormat:@"<p>%@</p>", declInfo.value];
            }
            
            NSArray *abstracts = [aMethodInfo childInfosWithTag:@"@abstract"];
            if ([abstracts count] > 0) {
                DSInformation *abstractInfo = [abstracts objectAtIndex:0];
                [htmlStr appendFormat:@"<p>%@</p>", abstractInfo.value];
            }
            
            NSArray *params = [aMethodInfo childInfosWithTag:@"@param"];
            if ([params count] > 0) {
                [htmlStr appendString:@"<h5>Parameters</h5>"];
                [htmlStr appendString:@"<dl class=\"termdef\">"];
                for (DSInformation *aParamInfo in params) {
                    NSString *value = aParamInfo.value;
                    NSEnumerator *paramEnum = [value tokenize:@" "];
                    NSString *name = [paramEnum nextObject];
                    if (name) {
                        NSString *exp = [paramEnum nextObject];
                        NSString *str;
                        while (str = [paramEnum nextObject]) {
                            exp = [exp stringByAppendingString:@" "];
                            exp = [exp stringByAppendingString:str];
                        }
                        if (exp) {
                            [htmlStr appendFormat:@"<dt>%@</dt><dd>%@</dd>", name, exp];
                        } else {
                            [htmlStr appendFormat:@"<dt>%@</dt><dd></dd>", name];
                        }
                    }
                }
                [htmlStr appendString:@"</dl>"];
            }
            
            NSArray *returns = [aMethodInfo childInfosWithTag:@"@return"];
            if ([returns count] > 0) {
                DSInformation *returnInfo = [returns objectAtIndex:0];
                [htmlStr appendString:@"<h5>Return Value</h5>"];
                [htmlStr appendFormat:@"<p>%@</p>", returnInfo.value];
            }
            
            NSArray *discussions = [aMethodInfo childInfosWithTag:@"@discussion"];
            for (DSInformation *aDiscussInfo in discussions) {
                [htmlStr appendFormat:@"<p>%@</p>", aDiscussInfo.value];
            }
            
            // TODO: Prepare any kind of switch to set whether we use "Declared in" or not.
            /*
            NSArray *declareds = [aMethodInfo childInfosWithTag:@"*declared-in"];
            if ([declareds count] > 0) {
                DSInformation *declaredInfo = [declareds objectAtIndex:0];
                [htmlStr appendString:@"<h5>Declared In</h5>"];
                NSString *declaringFilePath = declaredInfo.value;
                [htmlStr appendFormat:@"<p>%@</p>", [declaringFilePath lastPathComponent]];
            }
             */
        }        
    }

    if ([instanceMethodInfos count] > 0) {
        [htmlStr appendString:@"<h2>Instance Methods</h2>"];
        
        for (DSInformation *aMethodInfo in instanceMethodInfos) {
            [htmlStr appendFormat:@"<a name=\"//apple_ref/cpp/instm/%@/%@\"></a>", aClassInfo.value, aMethodInfo.value];
            [htmlStr appendFormat:@"<h3>%@</h3>", aMethodInfo.value];
            
            NSArray *decls = [aMethodInfo childInfosWithTag:@"@declare"];
            if ([decls count] > 0) {
                DSInformation *declInfo = [decls objectAtIndex:0];
                [htmlStr appendFormat:@"<p>%@</p>", declInfo.value];
            }
            
            NSArray *abstracts = [aMethodInfo childInfosWithTag:@"@abstract"];
            if ([abstracts count] > 0) {
                DSInformation *abstractInfo = [abstracts objectAtIndex:0];
                [htmlStr appendFormat:@"<p>%@</p>", abstractInfo.value];
            }
            
            NSArray *params = [aMethodInfo childInfosWithTag:@"@param"];
            if ([params count] > 0) {
                [htmlStr appendString:@"<h5>Parameters</h5>"];
                [htmlStr appendString:@"<dl class=\"termdef\">"];
                for (DSInformation *aParamInfo in params) {
                    NSString *value = aParamInfo.value;
                    NSEnumerator *paramEnum = [value tokenize:@" "];
                    NSString *name = [paramEnum nextObject];
                    if (name) {
                        NSString *exp = [paramEnum nextObject];
                        NSString *str;
                        while (str = [paramEnum nextObject]) {
                            exp = [exp stringByAppendingString:@" "];
                            exp = [exp stringByAppendingString:str];
                        }
                        if (exp) {
                            [htmlStr appendFormat:@"<dt>%@</dt><dd>%@</dd>", name, exp];
                        } else {
                            [htmlStr appendFormat:@"<dt>%@</dt><dd></dd>", name];
                        }
                    }
                }
                [htmlStr appendString:@"</dl>"];
            }
            
            NSArray *returns = [aMethodInfo childInfosWithTag:@"@return"];
            if ([returns count] > 0) {
                DSInformation *returnInfo = [returns objectAtIndex:0];
                [htmlStr appendString:@"<h5>Return Value</h5>"];
                [htmlStr appendFormat:@"<p>%@</p>", returnInfo.value];
            }
            
            NSArray *discussions = [aMethodInfo childInfosWithTag:@"@discussion"];
            for (DSInformation *aDiscussInfo in discussions) {
                [htmlStr appendFormat:@"<p>%@</p>", aDiscussInfo.value];
            }
            
            // TODO: Prepare any kind of switch to set whether we use "Declared in" or not.
            /*
            NSArray *declareds = [aMethodInfo childInfosWithTag:@"*declared-in"];
            if ([declareds count] > 0) {
                DSInformation *declaredInfo = [declareds objectAtIndex:0];
                [htmlStr appendString:@"<h5>Declared In</h5>"];
                NSString *declaringFilePath = declaredInfo.value;
                [htmlStr appendFormat:@"<p>%@</p>", [declaringFilePath lastPathComponent]];
            }
             */
        }
    }
    
    return YES;
}

- (BOOL)writeClassInfo:(DSInformation *)aClassInfo atPath:(NSString *)classesPath
{
    BOOL isStruct = [aClassInfo.tagName isEqualToString:@"@struct"];
    
    NSString *className = aClassInfo.value;
    NSString *classDirPath = [classesPath stringByAppendingPathComponent:className];
    NSString *htmlPath = [classDirPath stringByAppendingPathComponent:@"index.html"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:classDirPath attributes:nil];

    NSMutableString *htmlStr = [NSMutableString string];
    [htmlStr appendString:@"<html lang=\"ja\">"];
    [htmlStr appendString:@"<head>"];
    [htmlStr appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />"];
    [htmlStr appendString:@"<link rel=\"stylesheet\" href=\"../../../css/adcstyle.css\" type=\"text/css\" />"];
    [htmlStr appendString:@"<link rel=\"stylesheet\" href=\"../../../css/karakuri_style.css\" type=\"text/css\" />"];
    if (isStruct) {
        [htmlStr appendFormat:@"<title>%@ Struct Reference</title>", className];
    } else {
        [htmlStr appendFormat:@"<title>%@ Class Reference</title>", className];
    }
    [htmlStr appendString:@"</head>"];
    
    [htmlStr appendString:@"<body>"];

    [htmlStr appendString:@"<div class=\"doc_body\">"];

    [htmlStr appendString:@"<p><a href=\"../../../index.html\">Back to TOC</a></p>"];
    
    [htmlStr appendFormat:@"<a name=\"//apple_ref/cpp/cl/%@\"></a>", className];
    if (isStruct) {
        [htmlStr appendFormat:@"<h1>%@ Struct Reference</h1>", className];
    } else {
        [htmlStr appendFormat:@"<h1>%@ Class Reference</h1>", className];
    }

    NSArray *abstracts = [aClassInfo childInfosWithTag:@"@abstract"];
    NSArray *discussions = [aClassInfo childInfosWithTag:@"@discussion"];

    if ([abstracts count] + [discussions count] > 0) {
        [htmlStr appendString:@"<h2>Overview</h2>"];
        
        if ([abstracts count] > 0) {
            DSInformation *abstractInfo = [abstracts objectAtIndex:0];
            [htmlStr appendFormat:@"<p>%@</p>", abstractInfo.value];
        }
        
        for (DSInformation *aDiscussInfo in discussions) {
            [htmlStr appendFormat:@"<p>%@</p>", aDiscussInfo.value];
        }
    }

    [self writeInstanceVariablesOfClassInfo:aClassInfo intoString:htmlStr];
    [self writeInstanceMethodsOfClassInfo:aClassInfo intoString:htmlStr];

    [htmlStr appendString:@"</div>"];

    [htmlStr appendString:@"</body>"];

    [htmlStr appendString:@"</html>"];

    NSData *htmlData = [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
    [htmlData writeToFile:htmlPath atomically:NO];

    return YES;
}

- (void)writeTOCGroupInfo:(NSString *)aGroupName toString:(NSMutableString *)htmlStr
{
    DSInformation *groupInfo = [[DSInfoRepository sharedRepository] groupInfoForName:aGroupName];
    NSArray *classInfos = [groupInfo childInfosWithTag:@"@class"];
    NSArray *functionInfos = [groupInfo childInfosWithTag:@"@function"];

    NSArray *structInfos = [groupInfo childInfosWithTag:@"@struct"];
    NSArray *enumInfos = [groupInfo childInfosWithTag:@"@enum"];
    NSArray *varInfos = [groupInfo childInfosWithTag:@"@var"];

    if ([classInfos count] + [functionInfos count] + [structInfos count] + [enumInfos count] + [varInfos count] == 0) {
        return;
    }

    [htmlStr appendFormat:@"<h2>%@</h2>", aGroupName];

    if ([classInfos count] > 0) {
        [htmlStr appendString:@"<div class=\"ref_col3\">"];
        [htmlStr appendString:@"<h3>Classes</h3>"];
        [htmlStr appendString:@"<ul>"];
        for (DSInformation *aClassInfo in classInfos) {
            [htmlStr appendFormat:@"<li><a href=\"%@/Classes/%@/index.html#//apple_ref/cpp/cl/%@\">%@</a></li>", aGroupName, aClassInfo.value, aClassInfo.value, aClassInfo.value];
        }
        [htmlStr appendString:@"</ul>"];
        [htmlStr appendString:@"</div>"];
    }
    
    if ([functionInfos count] > 0) {
        [htmlStr appendString:@"<div class=\"ref_col3\">"];
        [htmlStr appendString:@"<h3>Functions</h3>"];
        [htmlStr appendString:@"<ul>"];
        for (DSInformation *aFunctionInfo in functionInfos) {
            [htmlStr appendFormat:@"<li><a href=\"%@/Functions/index.html#//apple_ref/cpp/func/%@\">%@</a></li>", aGroupName, aFunctionInfo.value, aFunctionInfo.value];
        }
        [htmlStr appendString:@"</ul>"];
        [htmlStr appendString:@"</div>"];
    }
    
    if ([structInfos count] + [enumInfos count] + [varInfos count] > 0) {
        [htmlStr appendString:@"<div class=\"ref_col3\">"];
        [htmlStr appendString:@"<h3>Other References</h3>"];
        if ([structInfos count] > 0) {
            [htmlStr appendString:@"<h4>Structs</h4>"];
            [htmlStr appendString:@"<ul>"];
            for (DSInformation *aStructInfo in structInfos) {
                [htmlStr appendFormat:@"<li><a href=\"%@/DataTypes/%@/index.html#//apple_ref/cpp/tag/%@\">%@</a></li>", aGroupName, aStructInfo.value, aStructInfo.value, aStructInfo.value];
            }
            [htmlStr appendString:@"</ul>"];
        }
        if ([enumInfos count] > 0) {
            [htmlStr appendString:@"<h4>Enums</h4>"];
            [htmlStr appendString:@"<ul>"];
            for (DSInformation *anEnumInfo in enumInfos) {
                [htmlStr appendFormat:@"<li><a href=\"%@/DataTypes/index.html#//apple_ref/cpp/tag/%@\">%@</a></li>", aGroupName, anEnumInfo.value, anEnumInfo.value];
            }
            [htmlStr appendString:@"</ul>"];
        }
        if ([varInfos count] > 0) {
            [htmlStr appendString:@"<h4>Variables</h4>"];
            [htmlStr appendString:@"<ul>"];
            for (DSInformation *aVarInfo in varInfos) {
                [htmlStr appendFormat:@"<li><a href=\"%@/DataTypes/index.html#//apple_ref/cpp/data/%@\">%@</a></li>", aGroupName, aVarInfo.value, aVarInfo.value];
            }
            [htmlStr appendString:@"</ul>"];
        }
        [htmlStr appendString:@"</div>"];
    }

    [htmlStr appendString:@"<div style=\"clear:both;\"></div>"];
}

- (BOOL)writeTOCFileAtPath:(NSString *)tocFilePath properties:(NSDictionary *)properties
{
    NSMutableString *htmlStr = [NSMutableString string];
    
    [htmlStr appendString:@"<html lang=\"ja\">"];
    [htmlStr appendString:@"<head>"];
    [htmlStr appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />"];
    [htmlStr appendString:@"<link rel=\"stylesheet\" href=\"css/adcstyle.css\" type=\"text/css\" />"];
    [htmlStr appendString:@"<link rel=\"stylesheet\" href=\"css/karakuri_style.css\" type=\"text/css\" />"];
    [htmlStr appendFormat:@"<title>%@ Reference Library</title>", [properties objectForKey:@"DocSet Name"]];
    [htmlStr appendString:@"</head>"];

    [htmlStr appendString:@"<body>"];
    [htmlStr appendString:@"<div class=\"toc_body\">"];
    [htmlStr appendFormat:@"<h1>%@ Reference Library</h1>", [properties objectForKey:@"DocSet Name"]];
    
    NSArray *groupNames = [[DSInfoRepository sharedRepository] groupNames];
    for (NSString *aGroupName in groupNames) {
        [self writeTOCGroupInfo:aGroupName toString:htmlStr];
    }
    
    [htmlStr appendString:@"</div>"];
    [htmlStr appendString:@"</body>"];

    [htmlStr appendString:@"</html>"];

    NSData *htmlData = [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
    [htmlData writeToFile:tocFilePath atomically:NO];

    return YES;
}

- (BOOL)writeFunctionDoc:(NSArray *)functionInfos atPath:(NSString *)path groupName:(NSString *)groupName properties:(NSDictionary *)properties
{    
    NSMutableString *htmlStr = [NSMutableString string];
    
    [htmlStr appendString:@"<html lang=\"ja\">"];
    [htmlStr appendString:@"<head>"];
    [htmlStr appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />"];
    [htmlStr appendString:@"<link rel=\"stylesheet\" href=\"../../css/adcstyle.css\" type=\"text/css\" />"];
    [htmlStr appendString:@"<link rel=\"stylesheet\" href=\"../../css/karakuri_style.css\" type=\"text/css\" />"];
    [htmlStr appendFormat:@"<title>%@ Functions</title>", groupName];
    [htmlStr appendString:@"</head>"];
    
    [htmlStr appendString:@"<body>"];
    [htmlStr appendString:@"<div class=\"doc_body\">"];

    [htmlStr appendString:@"<p><a href=\"../../index.html\">Back to TOC</a></p>"];

    [htmlStr appendFormat:@"<h1>%@ Functions</h1>", groupName];

    for (DSInformation *aFunctionInfo in functionInfos) {
        [htmlStr appendFormat:@"<a name=\"//apple_ref/cpp/func/%@\"></a>", aFunctionInfo.value];
        [htmlStr appendFormat:@"<h3>%@</h3>", aFunctionInfo.value];
        
        NSArray *abstracts = [aFunctionInfo childInfosWithTag:@"@abstract"];
        if ([abstracts count] > 0) {
            DSInformation *abstractInfo = [abstracts objectAtIndex:0];
            [htmlStr appendFormat:@"<p>%@</p>", abstractInfo.value];
        }
        
        NSArray *decls = [aFunctionInfo childInfosWithTag:@"@declare"];
        if ([decls count] > 0) {
            DSInformation *declInfo = [decls objectAtIndex:0];
            [htmlStr appendFormat:@"<p>%@</p>", declInfo.value];
        }
        
        NSArray *returns = [aFunctionInfo childInfosWithTag:@"@return"];
        if ([returns count] > 0) {
            DSInformation *returnInfo = [returns objectAtIndex:0];
            [htmlStr appendString:@"<h5>Return Value</h5>"];
            [htmlStr appendFormat:@"<p>%@</p>", returnInfo.value];
        }
        
        NSArray *discussions = [aFunctionInfo childInfosWithTag:@"@discussion"];
        for (DSInformation *aDiscussInfo in discussions) {
            [htmlStr appendFormat:@"<p>%@</p>", aDiscussInfo.value];
        }
        
        // TODO: Prepare any kind of switch to set whether we use "Declared in" or not.
/*      NSArray *declareds = [aFunctionInfo childInfosWithTag:@"*declared-in"];
        if ([declareds count] > 0) {
            DSInformation *declaredInfo = [declareds objectAtIndex:0];
            [htmlStr appendString:@"<h5>Declared In</h5>"];
            NSString *declaringFilePath = declaredInfo.value;
            [htmlStr appendFormat:@"<p>%@</p>", [declaringFilePath lastPathComponent]];
        } */
    }
    
    [htmlStr appendString:@"</div>"];
    [htmlStr appendString:@"</body>"];
    
    [htmlStr appendString:@"</html>"];
    
    NSData *htmlData = [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
    [htmlData writeToFile:path atomically:NO];

    return YES;
}

- (void)writeGroupDocForName:(NSString *)groupName path:(NSString *)groupDirPath properties:(NSDictionary *)properties
{
    DSInformation *groupInfo = [[DSInfoRepository sharedRepository] groupInfoForName:groupName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // Write out class information
    NSArray *classInfos = [groupInfo childInfosWithTag:@"@class"];
    if ([classInfos count] > 0) {
        NSString *classesDirPath = [groupDirPath stringByAppendingPathComponent:@"Classes"];
        [fileManager createDirectoryAtPath:classesDirPath attributes:nil];
        for (DSInformation *aClassInfo in classInfos) {
            [self writeClassInfo:aClassInfo atPath:classesDirPath];
        }
    }
    
    // Write out struct information
    NSArray *structInfos = [groupInfo childInfosWithTag:@"@struct"];
    if ([structInfos count] > 0) {
        NSString *dataTypeDirPath = [groupDirPath stringByAppendingPathComponent:@"DataTypes"];
        if (![fileManager fileExistsAtPath:dataTypeDirPath]) {
            [fileManager createDirectoryAtPath:dataTypeDirPath attributes:nil];
        }
        for (DSInformation *aStructInfo in structInfos) {
            [self writeClassInfo:aStructInfo atPath:dataTypeDirPath];
        }
    }

    // Write out function information
    NSArray *functionInfos = [groupInfo childInfosWithTag:@"@function"];
    if ([functionInfos count] > 0) {
        NSString *functionsDirPath = [groupDirPath stringByAppendingPathComponent:@"Functions"];
        [fileManager createDirectoryAtPath:functionsDirPath attributes:nil];
        [self writeFunctionDoc:(NSArray *)functionInfos atPath:[functionsDirPath stringByAppendingPathComponent:@"index.html"] groupName:groupName properties:properties];
     }
}

- (void)writeInfoPlistAtContentsPath:(NSString *)contentsPath properties:(NSDictionary *)properties
{
    NSString *filePath = [contentsPath stringByAppendingPathComponent:@"Info.plist"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"en" forKey:@"CFBundleDevelopmentRegion"];
    [dict setObject:@"3.1" forKey:@"DocSetMinimumXcodeVersion"];
    [dict setObject:[properties objectForKey:@"Bundle Identifier"] forKey:@"CFBundleIdentifier"];
    [dict setObject:[properties objectForKey:@"DocSet Name"] forKey:@"CFBundleName"];
    [dict setObject:[properties objectForKey:@"Version Number"] forKey:@"CFBundleVersion"];
    [dict setObject:[properties objectForKey:@"Version Number"] forKey:@"CFBundleShortVersion"];
    [dict setObject:[properties objectForKey:@"DocSet Name"] forKey:@"DocSetFeedName"];
    [dict setObject:[properties objectForKey:@"Publisher Identifier"] forKey:@"DocSetPublisherIdentifier"];
    [dict setObject:[properties objectForKey:@"Publisher Name"] forKey:@"DocSetPublisherName"];
    [dict setObject:[properties objectForKey:@"Copyright"] forKey:@"NSHumanReadableCopyright"];
    
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListXMLFormat_v1_0 errorDescription:NULL];
    [plistData writeToFile:filePath atomically:NO];
}

- (void)writeNodesXMLAtResourcesPath:(NSString *)resourcesDirPath
{
    NSString *filePath = [resourcesDirPath stringByAppendingPathComponent:@"Nodes.xml"];
    
    NSMutableString *xmlStr = [NSMutableString string];

    [xmlStr appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
    [xmlStr appendString:@"<DocSetNodes version=\"1.0\">"];
    [xmlStr appendString:@"<TOC>"];
    [xmlStr appendString:@"<Node type=\"file\">"];
    [xmlStr appendString:@"<Name>Root</Name>"];
    [xmlStr appendString:@"<Path>referencelibrary/index.html</Path>"];
    [xmlStr appendString:@"</Node>"];
    [xmlStr appendString:@"</TOC>"];
    [xmlStr appendString:@"</DocSetNodes>"];
    
    NSData *xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];    
    [xmlData writeToFile:filePath atomically:NO];
}

- (void)writeTokensXMLAtResourcesPath:(NSString *)resourcesDirPath
{
    NSString *filePath = [resourcesDirPath stringByAppendingPathComponent:@"Tokens.xml"];
    
    NSMutableString *xmlStr = [NSMutableString string];

    [xmlStr appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
    [xmlStr appendString:@"<Tokens version=\"1.0\">"];
        
    NSArray *groupNames = [[DSInfoRepository sharedRepository] groupNames];
    for (NSString *aGroupName in groupNames) {
        DSInformation *groupInfo = [[DSInfoRepository sharedRepository] groupInfoForName:aGroupName];
        NSArray *classInfos = [groupInfo childInfosWithTag:@"@class"];
        for (DSInformation *aClassInfo in classInfos) {
            [xmlStr appendString:@"<Token>\n"];
            [xmlStr appendFormat:@"  <TokenIdentifier>//apple_ref/cpp/cl/%@</TokenIdentifier>\n", aClassInfo.value];
            [xmlStr appendFormat:@"  <Path>referencelibrary/%@/Classes/%@/index.html</Path>\n", aGroupName, aClassInfo.value];
            [xmlStr appendFormat:@"  <Anchor>//apple_ref/cpp/cl/%@</Anchor>\n", aClassInfo.value];
            [xmlStr appendString:@"</Token>\n\n"];
            
            NSArray *methodInfos = [aClassInfo childInfosWithTag:@"@method"];
            for (DSInformation *aMethodInfo in methodInfos) {
                NSString *decl = nil;
                NSArray *decls = [aMethodInfo childInfosWithTag:@"@declare"];
                if ([decls count] > 0) {
                    DSInformation *declInfo = [decls objectAtIndex:0];
                    decl = declInfo.value;
                }

                NSString *type = @"instm";
                if (decl && [decl hasPrefix:@"static"]) {
                    type = @"clm";
                }

                [xmlStr appendString:@"<Token>\n"];
                [xmlStr appendFormat:@"<TokenIdentifier>//apple_ref/cpp/%@/%@/%@</TokenIdentifier>\n", type, aClassInfo.value, aMethodInfo.value];
                [xmlStr appendFormat:@"<Path>referencelibrary/%@/Classes/%@/index.html</Path>\n", aGroupName, aClassInfo.value];
                [xmlStr appendFormat:@"<Anchor>//apple_ref/cpp/%@/%@/%@</Anchor>\n", type, aClassInfo.value, aMethodInfo.value];
                [xmlStr appendString:@"</Token>\n"];
            }
            [xmlStr appendString:@"\n"];
        }
        
        NSArray *functionInfos = [groupInfo childInfosWithTag:@"@function"];
        for (DSInformation *aFunctionInfo in functionInfos) {
            [xmlStr appendString:@"<Token>\n"];
            [xmlStr appendFormat:@"  <TokenIdentifier>//apple_ref/cpp/func/%@</TokenIdentifier>\n", aFunctionInfo.value];
            [xmlStr appendFormat:@"  <Path>referencelibrary/%@/Functions/index.html</Path>\n", aGroupName];
            [xmlStr appendFormat:@"  <Anchor>//apple_ref/cpp/func/%@</Anchor>\n", aFunctionInfo.value];
            [xmlStr appendString:@"</Token>\n\n"];
        }

        NSArray *structInfos = [groupInfo childInfosWithTag:@"@struct"];
        for (DSInformation *aStructInfo in structInfos) {
            [xmlStr appendString:@"<Token>\n"];
            [xmlStr appendFormat:@"  <TokenIdentifier>//apple_ref/cpp/tag/%@</TokenIdentifier>\n", aStructInfo.value];
            [xmlStr appendFormat:@"  <Path>referencelibrary/%@/DataTypes/%@/index.html</Path>\n", aGroupName, aStructInfo.value];
            [xmlStr appendFormat:@"  <Anchor>//apple_ref/cpp/tag/%@</Anchor>\n", aStructInfo.value];
            [xmlStr appendString:@"</Token>\n\n"];
        }

        NSArray *enumInfos = [groupInfo childInfosWithTag:@"@enum"];
        for (DSInformation *aEnumInfo in enumInfos) {
            [xmlStr appendString:@"<Token>\n"];
            [xmlStr appendFormat:@"  <TokenIdentifier>//apple_ref/cpp/tag/%@</TokenIdentifier>\n", aEnumInfo.value];
            [xmlStr appendFormat:@"  <Path>referencelibrary/%@/DataTypes/index.html</Path>\n", aGroupName];
            [xmlStr appendFormat:@"  <Anchor>//apple_ref/cpp/tag/%@</Anchor>\n", aEnumInfo.value];
            [xmlStr appendString:@"</Token>\n\n"];
        }
    }
    
    [xmlStr appendString:@"</Tokens>"];

    NSData *xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];    
    [xmlData writeToFile:filePath atomically:NO];
}

- (void)makeIndexForDocSetAtPath:(NSString *)docSetPath
{
    NSTask *task = [NSTask new];
    
    [task setLaunchPath:@"/Developer/usr/bin/docsetutil"];
    [task setArguments:[NSArray arrayWithObjects:@"index", docSetPath, nil]];
    
    [task launch];
    [task waitUntilExit];
    
    [task release];
}

- (BOOL)writeDocumentAtPath:(NSString *)path properties:(NSDictionary *)properties
{
    NSString *docSetPath = [[path stringByAppendingPathComponent:[properties objectForKey:@"Bundle Identifier"]] stringByAppendingPathExtension:@"docset"];
    NSString *contentsDirPath = [docSetPath stringByAppendingPathComponent:@"Contents"];
    NSString *resourcesDirPath = [contentsDirPath stringByAppendingPathComponent:@"Resources"];
    NSString *docsPath = [resourcesDirPath stringByAppendingPathComponent:@"referencelibrary"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:docSetPath]) {
        [fileManager removeFileAtPath:docSetPath handler:nil];
    }
    [fileManager createDirectoryAtPath:docSetPath attributes:nil];
    [fileManager createDirectoryAtPath:contentsDirPath attributes:nil];
    [fileManager createDirectoryAtPath:resourcesDirPath attributes:nil];
    [fileManager createDirectoryAtPath:docsPath attributes:nil];
    
    [self writeInfoPlistAtContentsPath:contentsDirPath properties:properties];
    [self writeNodesXMLAtResourcesPath:resourcesDirPath];
    [self writeTokensXMLAtResourcesPath:resourcesDirPath];
    
    NSString *cssPath = [docsPath stringByAppendingPathComponent:@"css"];
    [fileManager createDirectoryAtPath:cssPath attributes:nil];
    NSString *adcstyleCSSPath = [[NSBundle mainBundle] pathForResource:@"adcstyle" ofType:@"css"];
    if (adcstyleCSSPath) {
        [fileManager copyPath:adcstyleCSSPath toPath:[cssPath stringByAppendingPathComponent:@"adcstyle.css"] handler:nil];
    }

    NSString *karakuriStyleCSSPath = [[NSBundle mainBundle] pathForResource:@"karakuri_style" ofType:@"css"];
    if (karakuriStyleCSSPath) {
        [fileManager copyPath:karakuriStyleCSSPath toPath:[cssPath stringByAppendingPathComponent:@"karakuri_style.css"] handler:nil];
    }

    // Write groups
    NSArray *groupNames = [[DSInfoRepository sharedRepository] groupNames];
    for (NSString *aGroupName in groupNames) {
        NSString *groupDirPath = [docsPath stringByAppendingPathComponent:aGroupName];
        [fileManager createDirectoryAtPath:groupDirPath attributes:nil];
        [self writeGroupDocForName:aGroupName path:groupDirPath properties:properties];
    }
    
    NSString *tocFilePath = [docsPath stringByAppendingPathComponent:@"index.html"];
    if (![self writeTOCFileAtPath:tocFilePath properties:properties]) {
        return NO;
    }
    
    [self makeIndexForDocSetAtPath:docSetPath];

    return YES;
}

@end



