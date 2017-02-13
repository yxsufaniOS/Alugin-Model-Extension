//
//  AlignCommand.m
//  JsonExchange
//
//  Created by 苏凡 on 2017/2/9.
//  Copyright © 2017年 sf. All rights reserved.
//

#import "AlignCommand.h"

@implementation AlignCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    
    
    XCSourceTextRange *range = invocation.buffer.selections.firstObject;
    NSInteger startLine = range.start.line;
    NSInteger endLine = range.end.line;
    if (startLine >= endLine) {
        completionHandler(nil);
        return;
    }
    
    NSArray *array = @[@":",@"=",@" "];
    [array enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self typesetWithInvocation:invocation key:obj]) {
            *stop = YES;
        }
    }];
    
    completionHandler(nil);
}


- (BOOL)typesetWithInvocation:(XCSourceEditorCommandInvocation *)invocation key:(NSString *)key{
    XCSourceTextRange *range      = invocation.buffer.selections.firstObject;
    NSInteger startLine           = range.start.line;
    NSInteger endLine             = range.end.line;
    NSInteger maxLocation     = 0;
    NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
    for (NSInteger i = startLine; i <= endLine; i++) {
        NSStringCompareOptions options = NSCaseInsensitiveSearch;
        NSString *str = invocation.buffer.lines[i];
        if ([key isEqualToString:@" "]) {
            //判断属性
            NSRange range = [str rangeOfString:@";"];
            if (range.location == NSNotFound) continue;
            str = [str substringToIndex:range.location];
            range = [str rangeOfString:@" *"];
            if (range.location != NSNotFound) {
                key = @" *";
            }
            options = NSBackwardsSearch;
        }
        NSRange range = [str rangeOfString:key options:options];
        if (range.location != NSNotFound) {
            [mdic setObject:@(range.location) forKey:@(i).description];
            maxLocation = maxLocation < range.location ? range.location : maxLocation;
        }
        if ([key isEqualToString:@" *"]) {
            key = @" ";
        }
    }
    
    if (maxLocation) {
        [mdic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSNumber *  _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.integerValue != maxLocation) {
                NSMutableString *str = [invocation.buffer.lines[[(NSString *)key integerValue]] mutableCopy];
                for (NSInteger i = obj.integerValue; i < maxLocation; i++) {
                    [str insertString:@" " atIndex:obj.integerValue];
                } 
                invocation.buffer.lines[[(NSString *)key integerValue]] = str;
            }
        }];
        return YES;
    }else{
        return NO;
    }
}

@end
