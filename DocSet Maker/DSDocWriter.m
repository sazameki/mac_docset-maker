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

    [htmlStr appendString:@"<h2>Instance Variables</h2>\n\n"];

    for (DSInformation *aVarInfo in vars) {
        [htmlStr appendFormat:@"<h3>%@</h3>\n", aVarInfo.value];

        NSString *decl = [aVarInfo declaration];
        if (decl) {
            [htmlStr appendFormat:@"<p class=\"declare\">%@</p>\n", decl];
        }
        
        NSArray *abstracts = [aVarInfo childInfosWithTag:@"@abstract"];
        if ([abstracts count] > 0) {
            DSInformation *abstractInfo = [abstracts objectAtIndex:0];
            [htmlStr appendFormat:@"<p>%@</p>", abstractInfo.value];
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

- (BOOL)writeMethodsOfClassInfo:(DSInformation *)aClassInfo intoString:(NSMutableString *)htmlStr
{
    NSArray *methods = [aClassInfo childInfosWithTag:@"@method"];
    if ([methods count] == 0) {
        return NO;
    }
    
    // Display Tasks
    if ([aClassInfo hasChildWithTag:@"@task"]) {
        [htmlStr appendString:@"<h2>Tasks</h2>\n\n"];
        
        BOOL hasDisplayedTask = NO;
        
        NSArray *childInfos = [aClassInfo allChildInfos];
        for (DSInformation *aChildInfo in childInfos) {
            if ([aChildInfo.tagName isEqualToString:@"@task"]) {
                if (hasDisplayedTask) {
                    [htmlStr appendString:@"</ul>\n"];
                }
                [htmlStr appendFormat:@"<h3>%@</h3>\n\n", aChildInfo.value];
                [htmlStr appendString:@"<ul>\n"];
                hasDisplayedTask = YES;
            } else if (hasDisplayedTask && [aChildInfo.tagName isEqualToString:@"@method"]) {
                NSString *decl = [aChildInfo declaration];
                if ([decl hasPrefix:@"static"]) {
                    [htmlStr appendFormat:@"<li><a href=\"#//apple_ref/cpp/clm/%@/%@\">%@</a></li>\n", aClassInfo.value, [aChildInfo docIdentifier], decl];
                } else {
                    [htmlStr appendFormat:@"<li><a href=\"#//apple_ref/cpp/instm/%@/%@\">%@</a></li>\n", aClassInfo.value, [aChildInfo docIdentifier], decl];
                }
            }
        }
        if (hasDisplayedTask) {
            [htmlStr appendString:@"</ul>\n"];
        }
    }
    
    NSMutableArray *classMethodInfos = [NSMutableArray array];
    NSMutableArray *instanceMethodInfos = [NSMutableArray array];

    for (DSInformation *aMethodInfo in methods) {
        NSString *decl = [aMethodInfo declaration];
        if (decl && [decl hasPrefix:@"static"]) {
            [classMethodInfos addObject:aMethodInfo];
        } else {
            [instanceMethodInfos addObject:aMethodInfo];
        }
    }
    
    if ([classMethodInfos count] > 0) {
        [htmlStr appendString:@"<h2>Class Methods</h2>\n\n"];
        
        for (DSInformation *aMethodInfo in classMethodInfos) {
            [htmlStr appendFormat:@"<a name=\"//apple_ref/cpp/clm/%@/%@\"></a>", aClassInfo.value, [aMethodInfo docIdentifier]];
            [htmlStr appendFormat:@"<h3>%@</h3>", aMethodInfo.value];
            
            NSString *decl = [aMethodInfo declaration];
            if (decl) {
                [htmlStr appendFormat:@"<p class=\"declare\">%@</p>", decl];
            }
            
            NSArray *abstracts = [aMethodInfo childInfosWithTag:@"@abstract"];
            if ([abstracts count] > 0) {
                DSInformation *abstractInfo = [abstracts objectAtIndex:0];
                [htmlStr appendFormat:@"<p>%@</p>", abstractInfo.value];
            }
            
            NSArray *discussions = [aMethodInfo childInfosWithTag:@"@discussion"];
            for (DSInformation *aDiscussInfo in discussions) {
                [htmlStr appendFormat:@"<p>%@</p>", aDiscussInfo.value];
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
        [htmlStr appendString:@"<h2>Instance Methods</h2>\n\n"];
        
        for (DSInformation *aMethodInfo in instanceMethodInfos) {
            [htmlStr appendFormat:@"<a name=\"//apple_ref/cpp/instm/%@/%@\"></a>\n", aClassInfo.value, [aMethodInfo docIdentifier]];
            [htmlStr appendFormat:@"<h3>%@</h3>\n", aMethodInfo.value];
            
            NSString *decl = [aMethodInfo declaration];
            if (decl) {
                [htmlStr appendFormat:@"  <p class=\"declare\">%@</p>\n", decl];
            }
            
            NSArray *abstracts = [aMethodInfo childInfosWithTag:@"@abstract"];
            if ([abstracts count] > 0) {
                DSInformation *abstractInfo = [abstracts objectAtIndex:0];
                [htmlStr appendFormat:@"  <p>%@</p>\n", abstractInfo.value];
            }
            
            NSArray *discussions = [aMethodInfo childInfosWithTag:@"@discussion"];
            for (DSInformation *aDiscussInfo in discussions) {
                [htmlStr appendFormat:@"<p>%@</p>", aDiscussInfo.value];
            }
            
            NSArray *params = [aMethodInfo childInfosWithTag:@"@param"];
            if ([params count] > 0) {
                [htmlStr appendString:@"<h5>Parameters</h5>\n"];
                [htmlStr appendString:@"<dl class=\"termdef\">\n"];
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
                            [htmlStr appendFormat:@"<dt>%@</dt><dd>%@</dd>\n", name, exp];
                        } else {
                            [htmlStr appendFormat:@"<dt>%@</dt><dd></dd>\n", name];
                        }
                    }
                }
                [htmlStr appendString:@"</dl>\n\n"];
            }
            
            NSArray *returns = [aMethodInfo childInfosWithTag:@"@return"];
            if ([returns count] > 0) {
                DSInformation *returnInfo = [returns objectAtIndex:0];
                [htmlStr appendString:@"<h5>Return Value</h5>"];
                [htmlStr appendFormat:@"<p>%@</p>", returnInfo.value];
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

- (BOOL)writeClassInfo:(DSInformation *)aClassInfo atPath:(NSString *)classesPath properties:(NSDictionary *)properties
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
    [self writeMethodsOfClassInfo:aClassInfo intoString:htmlStr];

    [htmlStr appendString:@"<div class=\"doc_footer\">"];
    [htmlStr appendFormat:@"%@", [properties objectForKey:@"Copyright"]];
    [htmlStr appendString:@"</div>"];
    
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

    [htmlStr appendFormat:@"  <h2>%@</h2>\n\n", aGroupName];

    if ([classInfos count] > 0) {
        classInfos = [classInfos sortedArrayUsingFunction:DSCompareInfo context:nil];
        [htmlStr appendString:@"    <div class=\"ref_col3\">\n"];
        [htmlStr appendString:@"    <h3>Classes</h3>\n\n"];
        [htmlStr appendString:@"    <ul>\n"];
        for (DSInformation *aClassInfo in classInfos) {
            [htmlStr appendFormat:@"      <li><a href=\"%@/Classes/%@/index.html#//apple_ref/cpp/cl/%@\">%@</a></li>\n", aGroupName, aClassInfo.value, aClassInfo.value, aClassInfo.value];
        }
        [htmlStr appendString:@"    </ul>\n"];
        [htmlStr appendString:@"    </div>\n\n"];
    }
    
    if ([functionInfos count] > 0) {
        functionInfos = [functionInfos sortedArrayUsingFunction:DSCompareInfo context:nil];
        [htmlStr appendString:@"    <div class=\"ref_col3\">\n"];
        [htmlStr appendString:@"    <h3>Functions</h3>\n\n"];
        [htmlStr appendString:@"    <ul>\n"];
        for (DSInformation *aFunctionInfo in functionInfos) {
            [htmlStr appendFormat:@"      <li><a href=\"%@/Functions/index.html#//apple_ref/cpp/func/%@\">%@</a></li>\n", aGroupName, [aFunctionInfo docIdentifier], aFunctionInfo.value];
        }
        [htmlStr appendString:@"    </ul>\n"];
        [htmlStr appendString:@"    </div>\n\n"];
    }
    
    if ([structInfos count] + [enumInfos count] + [varInfos count] > 0) {
        [htmlStr appendString:@"    <div class=\"ref_col3\">\n"];
        [htmlStr appendString:@"    <h3>Other References</h3>\n\n"];
        if ([structInfos count] > 0) {
            structInfos = [structInfos sortedArrayUsingFunction:DSCompareInfo context:nil];
            [htmlStr appendString:@"    <h4>Structs</h4>\n\n"];
            [htmlStr appendString:@"    <ul>\n"];
            for (DSInformation *aStructInfo in structInfos) {
                [htmlStr appendFormat:@"        <li><a href=\"%@/DataTypes/%@/index.html#//apple_ref/cpp/tag/%@\">%@</a></li>\n", aGroupName, aStructInfo.value, aStructInfo.value, aStructInfo.value];
            }
            [htmlStr appendString:@"    </ul>\n\n"];
        }
        if ([enumInfos count] > 0) {
            enumInfos = [enumInfos sortedArrayUsingFunction:DSCompareInfo context:nil];
            [htmlStr appendString:@"    <h4>Enums</h4>\n\n"];
            [htmlStr appendString:@"    <ul>\n"];
            for (DSInformation *anEnumInfo in enumInfos) {
                [htmlStr appendFormat:@"        <li><a href=\"%@/DataTypes/index.html#//apple_ref/cpp/tag/%@\">%@</a></li>\n", aGroupName, anEnumInfo.value, anEnumInfo.value];
            }
            [htmlStr appendString:@"    </ul>\n\n"];
        }
        if ([varInfos count] > 0) {
            varInfos = [varInfos sortedArrayUsingFunction:DSCompareInfo context:nil];
            [htmlStr appendString:@"    <h4>Variables</h4>\n\n"];
            [htmlStr appendString:@"    <ul>\n"];
            for (DSInformation *aVarInfo in varInfos) {
                [htmlStr appendFormat:@"        <li><a href=\"%@/DataTypes/index.html#//apple_ref/cpp/data/%@\">%@</a></li>\n", aGroupName, aVarInfo.value, aVarInfo.value];
            }
            [htmlStr appendString:@"    </ul>\n"];
        }
        [htmlStr appendString:@"    </div>\n\n"];
    }

    [htmlStr appendString:@"  <div style=\"clear:both;\"></div>\n\n"];
}

- (BOOL)writeTOCFileAtPath:(NSString *)tocFilePath properties:(NSDictionary *)properties
{
    NSMutableString *htmlStr = [NSMutableString string];
    
    [htmlStr appendString:@"<html lang=\"ja\">\n"];
    [htmlStr appendString:@"<head>\n"];
    [htmlStr appendString:@"  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\n"];
    [htmlStr appendString:@"  <link rel=\"stylesheet\" href=\"css/adcstyle.css\" type=\"text/css\" />\n"];
    [htmlStr appendString:@"  <link rel=\"stylesheet\" href=\"css/karakuri_style.css\" type=\"text/css\" />\n"];
    [htmlStr appendFormat:@"  <title>%@ Reference Library</title>\n", [properties objectForKey:@"DocSet Name"]];
    [htmlStr appendString:@"</head>\n\n"];

    [htmlStr appendString:@"<body>\n"];
    [htmlStr appendString:@"<div class=\"toc_body\">\n"];
    [htmlStr appendFormat:@"  <h1>%@ Reference Library</h1>\n\n", [properties objectForKey:@"DocSet Name"]];
    
    NSArray *groupNames = [[DSInfoRepository sharedRepository] groupNames];
    for (NSString *aGroupName in groupNames) {
        [self writeTOCGroupInfo:aGroupName toString:htmlStr];
    }
    
    [htmlStr appendString:@"  <div class=\"doc_footer\">\n"];
    [htmlStr appendFormat:@"    %@\n", [properties objectForKey:@"Copyright"]];
    [htmlStr appendString:@"  </div>\n\n"];
    
    [htmlStr appendString:@"</div>\n"];
    [htmlStr appendString:@"</body>\n"];

    [htmlStr appendString:@"</html>\n\n"];

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

    functionInfos = [functionInfos sortedArrayUsingFunction:DSCompareInfo context:nil];

    for (DSInformation *aFunctionInfo in functionInfos) {
        [htmlStr appendFormat:@"<a name=\"//apple_ref/cpp/func/%@\"></a>", [aFunctionInfo docIdentifier]];
        [htmlStr appendFormat:@"<h3>%@</h3>", aFunctionInfo.value];
        
        NSString *decl = [aFunctionInfo declaration];
        if (decl) {
            [htmlStr appendFormat:@"<p class=\"declare\">%@</p>", decl];
        }
        
        NSArray *abstracts = [aFunctionInfo childInfosWithTag:@"@abstract"];
        if ([abstracts count] > 0) {
            DSInformation *abstractInfo = [abstracts objectAtIndex:0];
            [htmlStr appendFormat:@"<p>%@</p>", abstractInfo.value];
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
    
    [htmlStr appendString:@"<div class=\"doc_footer\">"];
    [htmlStr appendFormat:@"%@", [properties objectForKey:@"Copyright"]];
    [htmlStr appendString:@"</div>"];
    
    [htmlStr appendString:@"</div>"];
    [htmlStr appendString:@"</body>"];
    
    [htmlStr appendString:@"</html>"];
    
    NSData *htmlData = [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
    [htmlData writeToFile:path atomically:NO];

    return YES;
}

- (void)writeOtherInfosInGroupInfo:(DSInformation *)groupInfo inDataTypeDirPath:(NSString *)dataTypeDirPath properties:(NSDictionary *)properties
{
    NSString *otherFilePath = [dataTypeDirPath stringByAppendingPathComponent:@"index.html"];
    
    NSArray *enumInfos = [groupInfo childInfosWithTag:@"@enum"];
    NSArray *varInfos = [groupInfo childInfosWithTag:@"@var"];

    NSMutableString *htmlStr = [NSMutableString string];
    
    [htmlStr appendString:@"<html lang=\"ja\">"];
    [htmlStr appendString:@"<head>"];
    [htmlStr appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />"];
    [htmlStr appendString:@"<link rel=\"stylesheet\" href=\"../../css/adcstyle.css\" type=\"text/css\" />"];
    [htmlStr appendString:@"<link rel=\"stylesheet\" href=\"../../css/karakuri_style.css\" type=\"text/css\" />"];
    [htmlStr appendFormat:@"<title>%@ Other References</title>", groupInfo.value];
    [htmlStr appendString:@"</head>"];
    
    [htmlStr appendString:@"<body>"];
    [htmlStr appendString:@"<div class=\"doc_body\">"];
    
    [htmlStr appendString:@"<p><a href=\"../../index.html\">Back to TOC</a></p>"];
    [htmlStr appendFormat:@"<h1>%@ Other References</h1>", groupInfo.value];
    
    if ([enumInfos count] > 0) {
        [htmlStr appendString:@"<h2>Enumerations</h2>"];
        enumInfos = [enumInfos sortedArrayUsingFunction:DSCompareInfo context:nil];
        for (DSInformation *anEnumInfo in enumInfos) {
            [htmlStr appendFormat:@"<h3>enum %@ {<br />", anEnumInfo.value];
            
            NSMutableArray *enumConstInfos = [NSMutableArray array];
            [enumConstInfos addObjectsFromArray:[anEnumInfo childInfosWithTag:@"@const"]];
            [enumConstInfos addObjectsFromArray:[anEnumInfo childInfosWithTag:@"@constant"]];
            for (DSInformation *aConstInfo in enumConstInfos) {
                NSString *constDesc = aConstInfo.value;
                NSEnumerator *constEnum = [constDesc tokenize:@" "];
                NSString *constName = [constEnum nextObject];
                if (constName) {
                    [htmlStr appendFormat:@"&nbsp;&nbsp;&nbsp;&nbsp;%@,<br />", constName];
                }
            }
            
            [htmlStr appendString:@"}</h3>"];
            
            NSArray *abstracts = [anEnumInfo childInfosWithTag:@"@abstract"];
            if ([abstracts count] > 0) {
                DSInformation *abstractInfo = [abstracts objectAtIndex:0];
                [htmlStr appendFormat:@"<p>%@</p>", abstractInfo.value];
            }            

            NSArray *discussions = [anEnumInfo childInfosWithTag:@"@discussion"];
            for (DSInformation *aDiscussInfo in discussions) {
                [htmlStr appendFormat:@"<p>%@</p>", aDiscussInfo.value];
            }
            
            if ([enumConstInfos count] > 0) {
                [htmlStr appendString:@"<h5>Constants</h5>"];
                [htmlStr appendString:@"<dl class=\"termdef\">"];
                for (DSInformation *aConstInfo in enumConstInfos) {
                    NSString *constDesc = aConstInfo.value;
                    NSEnumerator *constEnum = [constDesc tokenize:@" "];
                    NSString *constName = [constEnum nextObject];
                    NSMutableString *constExp = [NSMutableString string];
                    NSString *aToken;
                    while (aToken = [constEnum nextObject]) {
                        if ([constExp length] > 0) {
                            [constExp appendString:@" "];
                        }
                        [constExp appendString:aToken];
                    }
                    if (constName) {
                        if ([constExp length] > 0) {
                            [htmlStr appendFormat:@"<dt>%@</dt><dd>%@</dd>", constName, constExp];
                        } else {
                            [htmlStr appendFormat:@"<dt>%@</dt><dd></dd>", constName];
                        }
                    }
                }                
                [htmlStr appendString:@"</dl>"];
            }
        }
    }
    
    if ([varInfos count] > 0) {
        [htmlStr appendString:@"<h2>Variables</h2>"];

        varInfos = [varInfos sortedArrayUsingFunction:DSCompareInfo context:nil];

        for (DSInformation *aVarInfo in varInfos) {
            [htmlStr appendFormat:@"<h3>%@</h3>", aVarInfo.value];

            NSString *decl = [aVarInfo declaration];
            if (decl) {
                [htmlStr appendFormat:@"<p class=\"declare\">%@</p>", decl];
            }

            NSArray *abstracts = [aVarInfo childInfosWithTag:@"@abstract"];
            if ([abstracts count] > 0) {
                DSInformation *abstractInfo = [abstracts objectAtIndex:0];
                [htmlStr appendFormat:@"<p>%@</p>", abstractInfo.value];
            }            

            NSArray *discussions = [aVarInfo childInfosWithTag:@"@discussion"];
            for (DSInformation *aDiscussInfo in discussions) {
                [htmlStr appendFormat:@"<p>%@</p>", aDiscussInfo.value];
            }
        }
    }
    
    [htmlStr appendString:@"<div class=\"doc_footer\">"];
    [htmlStr appendFormat:@"%@", [properties objectForKey:@"Copyright"]];
    [htmlStr appendString:@"</div>"];    

    [htmlStr appendString:@"</div>"];
    [htmlStr appendString:@"</body>"];
    
    [htmlStr appendString:@"</html>"];
    
    NSData *htmlData = [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
    [htmlData writeToFile:otherFilePath atomically:NO];
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
            [self writeClassInfo:aClassInfo atPath:classesDirPath properties:properties];
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
            [self writeClassInfo:aStructInfo atPath:dataTypeDirPath properties:properties];
        }
    }
    
    // Write out enum/var information
    NSArray *enumInfos = [groupInfo childInfosWithTag:@"@enum"];
    NSArray *varInfos = [groupInfo childInfosWithTag:@"@var"];
    if ([enumInfos count] + [varInfos count] > 0) {
        NSString *dataTypeDirPath = [groupDirPath stringByAppendingPathComponent:@"DataTypes"];
        if (![fileManager fileExistsAtPath:dataTypeDirPath]) {
            [fileManager createDirectoryAtPath:dataTypeDirPath attributes:nil];
        }
        [self writeOtherInfosInGroupInfo:groupInfo inDataTypeDirPath:dataTypeDirPath properties:properties];
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
    [xmlStr appendString:@"<Tokens version=\"1.0\">\n"];
        
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
                NSString *type = @"instm";
                NSString *decl = [aMethodInfo declaration];
                if (decl && [decl hasPrefix:@"static"]) {
                    type = @"clm";
                }

                [xmlStr appendString:@"<Token>\n"];
                [xmlStr appendFormat:@"<TokenIdentifier>//apple_ref/cpp/%@/%@/%@</TokenIdentifier>\n", type, aClassInfo.value, [aMethodInfo docIdentifier]];
                [xmlStr appendFormat:@"<Path>referencelibrary/%@/Classes/%@/index.html</Path>\n", aGroupName, aClassInfo.value];
                [xmlStr appendFormat:@"<Anchor>//apple_ref/cpp/%@/%@/%@</Anchor>\n", type, aClassInfo.value, [aMethodInfo docIdentifier]];
                [xmlStr appendString:@"</Token>\n"];
            }
            [xmlStr appendString:@"\n"];
        }
        
        NSArray *functionInfos = [groupInfo childInfosWithTag:@"@function"];
        for (DSInformation *aFunctionInfo in functionInfos) {
            [xmlStr appendString:@"<Token>\n"];
            [xmlStr appendFormat:@"  <TokenIdentifier>//apple_ref/cpp/func/%@</TokenIdentifier>\n", [aFunctionInfo docIdentifier]];
            [xmlStr appendFormat:@"  <Path>referencelibrary/%@/Functions/index.html</Path>\n", aGroupName];
            [xmlStr appendFormat:@"  <Anchor>//apple_ref/cpp/func/%@</Anchor>\n", [aFunctionInfo docIdentifier]];
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



