//
//  PropertyMethodCommand.m
//  AlignPluginDemo
//
//  Created by 苏凡 on 2017/2/28.
//  Copyright © 2017年 sf. All rights reserved.
//

#import "PropertyMethodCommand.h"

@implementation PropertyMethodCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    
    
    XCSourceTextRange *range = invocation.buffer.selections.firstObject;
    NSInteger startLine = range.start.line;
    NSInteger endLine = range.end.line;
    NSString *total = @"";
    for (NSInteger i = startLine; i<=endLine; i++) {
        NSString *str = [self getMethodStringWithCode:invocation.buffer.lines[i]];
        if (str) {
            total = [total stringByAppendingString:@"\n"];
            total = [total stringByAppendingString:str];
        }
    }
    
    [invocation.buffer.lines insertObject:total atIndex:endLine+1];
    
    
    completionHandler(nil);
}

- (NSString *)getMethodStringWithCode:(NSString *)code{
    NSRange range = [code rangeOfString:@")"];
    NSRange range2 = [code rangeOfString:@";"];
    if (range.location != NSNotFound && range2.location != NSNotFound) {
        code = [code substringWithRange:NSMakeRange(range.location+1, range2.location-range.location-1)];
        range = [code rangeOfString:@"*"];
        if (range.location != NSNotFound) {
            NSString *name = [code substringFromIndex:range.location+1];
            NSString *type = [code substringToIndex:range.location-1];
            name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
            type = [type stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            NSString *str = [NSString stringWithFormat:@"- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] init];\n    }\n    return _%@;\n}",type,name,name,name,type,name];
            return str;
        }else{
            
        }
        
    }
    return nil;
    
    
}

@end
