//
//  SourceEditorCommand.m
//  AlignPlugin
//
//  Created by 苏凡 on 2017/2/9.
//  Copyright © 2017年 sf. All rights reserved.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand{
    NSMutableArray *_annoArray;
}

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.

    XCSourceTextRange *range = invocation.buffer.selections.firstObject;
    NSInteger startLine = range.start.line;
    NSInteger endLine = range.end.line;
    NSString *totalstr = @"";
    _annoArray = [NSMutableArray array];
    for (NSInteger i = startLine; i <= endLine; i++) {
        NSString *curLine = invocation.buffer.lines[i];
        NSRange range = [curLine rangeOfString:@"//" options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            NSRange httpRange = [curLine rangeOfString:@"://" options:NSBackwardsSearch];
            if (httpRange.location != NSNotFound && httpRange.location == range.location-1) {
                
            }else{
                NSRange range2 = [curLine rangeOfString:@"////" options:NSBackwardsSearch];
                if (range2.location != NSNotFound) {
                    curLine = [curLine stringByReplacingOccurrencesOfString:@"////" withString:@"//"];
                    range = [curLine rangeOfString:@"//" options:NSBackwardsSearch];
                }
                
                NSRange range3 = [curLine rangeOfString:@"///" options:NSBackwardsSearch];
                if (range3.location != NSNotFound) {
                    curLine = [curLine stringByReplacingOccurrencesOfString:@"///" withString:@"//"];
                    range = [curLine rangeOfString:@"//" options:NSBackwardsSearch];
                }
                
                
                curLine = [curLine substringToIndex:range.location];
                [_annoArray addObject:@(i)];
                curLine = [curLine stringByAppendingString:@"\n"];
            }
            
        }
        totalstr = [totalstr stringByAppendingString:curLine];
    }
    NSLog(@"string :: %@",totalstr);
    NSData *resData = [[NSData alloc] initWithData:[totalstr dataUsingEncoding:NSUTF8StringEncoding]];
    id  jsonObj = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"jsonOBj : %@",jsonObj);
    NSDictionary *dic = jsonObj == nil ? nil : [self getDictionaryWithjsonObj:jsonObj];
    if (dic == nil) {
        NSError *error = [NSError errorWithDomain:@"json解析为nil" code:100 userInfo:nil];
        completionHandler(error);
        return;
    }
    __block NSString *str = @"";
    __block NSString *str2 = @"+ (NSDictionary *)JSONKeyPathsByPropertyKey {\n    return @{ ";
    __block NSInteger maxLocation = 0;
    NSMutableArray *str2Arr = [NSMutableArray arrayWithCapacity:dic.allKeys.count];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *type = @"";
        if ([obj isKindOfClass:[NSString class]]) {
            type = @"NSString";
        }else if ([obj isKindOfClass:[NSDictionary class]]){
            type = @"NSDictionary";
        }else if ([obj isKindOfClass:[NSArray class]]){
            type = @"NSArray";
        }else if ([obj isKindOfClass:[NSNumber class]]){
            type = @"NSNumber";
        }else{
            type = @"id";
        }
        NSString *annotate = [self getAnnotateByKey:key lines:invocation.buffer.lines]?:@"   ";
        str = [str stringByAppendingString:[NSString stringWithFormat:@"\n/** %@ */",annotate]];
        str = [str stringByAppendingString:[NSString stringWithFormat:@"\n@property (nonatomic, strong) %@ *%@;",type,key]];
        
        NSString *dicStr = [NSString stringWithFormat:@"@\"%@\" : @\"%@\",\n              ",key,key];
        [str2Arr addObject:dicStr];
        NSRange range = [dicStr rangeOfString:@":"];
        maxLocation = maxLocation < range.location ? range.location : maxLocation;
        
    }];
    
    if (maxLocation) {
        [str2Arr enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [obj rangeOfString:@":"];
            NSMutableString *mstr = [obj mutableCopy];
            for (NSInteger i = range.location; i < maxLocation; i++) {
                [mstr insertString:@" " atIndex:range.location];
            }
            str2 = [str2 stringByAppendingString:mstr];
        }];
    }
    
    str2 = [str2 stringByAppendingString:@"};\n}"];
    [invocation.buffer.lines insertObject:str2 atIndex:endLine+1];
    [invocation.buffer.lines insertObject:str atIndex:endLine+1];
    completionHandler(nil);
}

- (NSDictionary *)getDictionaryWithjsonObj:(id)jsonObj{
    if ([jsonObj isKindOfClass:[NSDictionary class]]) {
        return jsonObj;
    }else if ([jsonObj isKindOfClass:[NSArray class]] && [(NSArray *)jsonObj count]){
        id firstObj = [(NSArray *)jsonObj firstObject];
        return [self getDictionaryWithjsonObj:firstObj];
    }else{
        return nil;
    }
}


- (NSString *)getAnnotateByKey:(NSString *)key lines:(NSArray<NSString *> *)lines{
    __block NSString *anno = nil;
    [_annoArray enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [lines[line.integerValue] rangeOfString:key];
        if (range.location != NSNotFound) {
            range = [lines[line.integerValue] rangeOfString:@"//" options:NSBackwardsSearch];
            if (range.location != NSNotFound) {
                anno = [lines[line.integerValue] substringFromIndex:(range.location+range.length)];
                if ([anno hasSuffix:@"\n"]) {
                    anno = [anno substringToIndex:anno.length-1];
                }
                if (anno.length > 0) {
                    if ([anno hasPrefix:@" "]) {
                        anno = [anno stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
                    }else if ([anno hasPrefix:@"	"]){
                        anno = [anno stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"	"]];
                    }
                }
                NSLog(@"key :: %@  \n  anno  ::  %@",key,anno);
            }
            [_annoArray removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    return anno;
}

@end
