//
//  SourceEditorCommand.m
//  AlignPlugin
//
//  Created by 苏凡 on 2017/2/9.
//  Copyright © 2017年 sf. All rights reserved.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.

    XCSourceTextRange *range = invocation.buffer.selections.firstObject;
    NSInteger startLine = range.start.line;
    NSInteger endLine = range.end.line;
    NSString *totalstr = @"";
    for (NSInteger i = startLine; i <= endLine; i++) {
        totalstr = [totalstr stringByAppendingString:invocation.buffer.lines[i]];
    }
    
    NSData *resData = [[NSData alloc] initWithData:[totalstr dataUsingEncoding:NSUTF8StringEncoding]];
    id  jsonObj = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"jsonOBj : %@",jsonObj);
    NSDictionary *dic = jsonObj == nil ? nil : [self getDictionaryWithjsonObj:jsonObj];
    if (dic == nil) return;
    
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
        
        str = [str stringByAppendingString:@"\n/**   */"];
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
    
    str2 = [str2 stringByAppendingString:@"}\n}"];
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

@end
