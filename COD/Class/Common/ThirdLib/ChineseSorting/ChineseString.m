//
//  ChineseString.m
//  https://github.com/c6357/YUChineseSorting
//
//  Created by BruceYu on 15/4/19.
//  Copyright (c) 2015年 BruceYu. All rights reserved.
//

#import "ChineseString.h"

@implementation ChineseString
@synthesize string;
@synthesize pinYin;

#pragma mark - 返回tableview右方 indexArray
+(NSMutableArray*)IndexArray:(NSArray*)stringArr
{
    NSMutableArray *tempArray = [self ReturnSortChineseArrar:stringArr];
    NSMutableArray *A_Result = [NSMutableArray array];
    NSString *tempString;
    
    for (NSString* object in tempArray)
    {
        NSString *pinyin = @"";
        NSString *pinyinStr = ((ChineseString*)object).pinYin;
        if (pinyinStr.length > 0) {
            pinyin = [((ChineseString*)object).pinYin substringToIndex:1];
//            if ([pinyin isEqualToString:@"M"]) {
//                NSLog(@"123");
//            }
        }
        //不同
        if(![tempString isEqualToString:pinyin])
        {
            // NSLog(@"IndexArray----->%@",pinyin);
            [A_Result addObject:pinyin];
            tempString = pinyin;
        }
    }
    NSString *fristStr = [A_Result firstObject];
    if ([fristStr containsString:@"#"]) {
        [A_Result removeObjectAtIndex:0];
        [A_Result addObject:@"#"];
    }
    return A_Result;
}

#pragma mark - 返回联系人
+(NSMutableArray*)LetterSortArray:(NSArray*)stringArr
{
    NSMutableArray *tempArray = [self ReturnSortChineseArrar:stringArr];
    NSMutableArray *LetterResult = [NSMutableArray array];
    NSMutableArray *item = [NSMutableArray array];
    NSString *tempString;
    //拼音分组
    for (NSString* object in tempArray) {
        
        NSString *pinyin = @"";
        NSString *pinyinStr = ((ChineseString*)object).pinYin;
        if (pinyinStr.length > 0) {
            pinyin = [((ChineseString*)object).pinYin substringToIndex:1];
        }
        NSString *string = ((ChineseString*)object).string;
        //不同
        if(![tempString isEqualToString:pinyin])
        {
            //分组
            item = [NSMutableArray array];
            [item  addObject:string];
            [LetterResult addObject:item];
            //遍历
            tempString = pinyin;
        }else//相同
        {
            [item  addObject:string];
        }
    }
    return LetterResult;
}

+(NSMutableArray*)modelSortArray:(NSArray*)contactArr
{
    NSMutableArray *tempArray = [self SortArrayWithKeyPath:@"pinYin" ByArr:contactArr];
    NSMutableArray *LetterResult = [NSMutableArray array];
    NSMutableArray *item = [NSMutableArray array];
    NSString *tempString;
    BOOL isHaveSymbol = NO;
    //拼音分组
    for (int i = 0; i < tempArray.count; i ++) {
        NSObject* object = tempArray[i];
        NSString *pinyin = @"";
        NSString *pinyinStr = ((ChineseString*)object).pinYin;
        
        if (pinyinStr.length > 0) {
            pinyin = [((ChineseString*)object).pinYin substringToIndex:1];
            if (i == 0) {
                if ([pinyin containsString:@"#"]) {
                    isHaveSymbol = YES;
                }
            }
        }
        
        //不同
        if(![tempString isEqualToString:pinyin])
        {
            //分组
            item = [NSMutableArray array];
            [item  addObject:object];
            [LetterResult addObject:item];
            //遍历
            tempString = pinyin;
        }else//相同
        {
            [item addObject:object];
        }
    }
    
    if (isHaveSymbol == YES) {
        NSArray *fristArr = LetterResult[0];
        [LetterResult removeObjectAtIndex:0];
        [LetterResult addObject:fristArr];
    }
    return LetterResult;
}


+ (NSMutableArray *)SortArrayWithKeyPath:(NSString *)key ByArr:(NSArray *)modelArr{
    //按照拼音首字母对这些model进行排序
    NSMutableArray *sortResultArr = [NSMutableArray array];
    
    for (int i = 0; i < modelArr.count; i ++) {
        [sortResultArr addObject:modelArr[i]];
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:YES]];
    [sortResultArr sortUsingDescriptors:sortDescriptors];
    return sortResultArr;
}


///////////////////
//
//返回排序好的字符拼音
//
///////////////////
+(NSMutableArray*)ReturnSortChineseArrar:(NSArray*)stringArr
{
    //获取字符串中文字的拼音首字母并与字符串共同存放
    NSMutableArray *chineseStringsArray=[NSMutableArray array];
    for(int i=0;i<[stringArr count];i++)
    {
        ChineseString *chineseString = [[ChineseString alloc] init];
        chineseString.string = [NSString stringWithString:[stringArr objectAtIndex:i]];
        if(chineseString.string == nil){
            chineseString.string = @"";
        }
        //去除两端空格和回车
        chineseString.string  = [chineseString.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        //此方法存在一些问题 有些字符过滤不了
        //NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\""];
        //chineseString.string = [chineseString.string stringByTrimmingCharactersInSet:set];
        
        
        //这里我自己写了一个递归过滤指定字符串   RemoveSpecialCharacter
        chineseString.string = [ChineseString RemoveSpecialCharacter:chineseString.string];
        // NSLog(@"string====%@",chineseString.string);
        
        
        //判断首字符是否为字母
        NSString *regex = @"[A-Za-z]+";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        
        NSString *initialStr = [chineseString.string length]?[chineseString.string substringToIndex:1]:@"";
        if ([predicate evaluateWithObject:initialStr])
        {
//            NSLog(@"chineseString.string== %@",chineseString.string);
            //首字母大写
            chineseString.pinYin = [chineseString.string capitalizedString] ;
        }else{
            if(![chineseString.string isEqualToString:@""]){
                NSString *pinYinResult = [NSString string];
                for(int j=0;j<chineseString.string.length;j++){
                    NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c",
                                                   
                                                   pinyinFirstLetter([chineseString.string characterAtIndex:j])] uppercaseString];
                    //                    NSLog(@"singlePinyinLetter ==%@",singlePinyinLetter);
                    
                    pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
                }
                chineseString.pinYin = pinYinResult;
            }else{
                chineseString.pinYin = @"#";
            }
        }
        [chineseStringsArray addObject:chineseString];
    }
    //按照拼音首字母对这些Strings进行排序
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
//    for(int i=0;i<[chineseStringsArray count];i++){
//        NSLog(@"chineseStringsArray====%@",((ChineseString*)[chineseStringsArray objectAtIndex:i]).pinYin);
//    }
    return chineseStringsArray;
    
}


#pragma mark - 返回一组字母排序数组
+(NSMutableArray*)SortArray:(NSArray*)stringArr
{
    NSMutableArray *tempArray = [self ReturnSortChineseArrar:stringArr];
    
    //把排序好的内容从ChineseString类中提取出来
    NSMutableArray *result = [NSMutableArray array];
    for(int i=0;i<[stringArr count];i++){
        [result addObject:((ChineseString*)[tempArray objectAtIndex:i]).string];
        NSLog(@"SortArray----->%@",((ChineseString*)[tempArray objectAtIndex:i]).string);
    }
    return result;
}


//过滤指定字符串   里面的指定字符根据自己的需要添加 过滤特殊字符
+(NSString*)RemoveSpecialCharacter: (NSString *)str {
    NSRange urgentRange = [str rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @",.？、 ~￥#&<>《》()[]{}【】^@/￡¤|§¨「」『』￠￢￣~@#&*（）——+|《》$_€"]];
    if (urgentRange.location != NSNotFound)
    {
        return [self RemoveSpecialCharacter:[str stringByReplacingCharactersInRange:urgentRange withString:@""]];
    }
    return str;
}


+ (NSString *)getStringPinyinBy:(NSString *)string{
    if(string == nil){
        string = @"";
    }
    //去除两端空格和回车
    string  = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //这里我自己写了一个递归过滤指定字符串   RemoveSpecialCharacter
    string = [ChineseString RemoveSpecialCharacter:string];
    // NSLog(@"string====%@",chineseString.string);
    
    //判断首字符是否为字母
    NSString *regex = @"[A-Za-z]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    NSString *initialStr = [string length]?[string substringToIndex:1]:@"";
    if ([predicate evaluateWithObject:initialStr])
    {
//        NSLog(@"chineseString.string== %@",string);
        //首字母大写
        return [string capitalizedString];
    }else{
        if(![string isEqualToString:@""]){
            NSString *pinYinResult = [NSString string];
            for(int j=0;j<string.length;j++){
                NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c",
                                                 
                                                 pinyinFirstLetter([string characterAtIndex:j])] uppercaseString];
                
                pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
            }
            return pinYinResult;
        }else{
            return @"#";
        }
    }
}

@end
