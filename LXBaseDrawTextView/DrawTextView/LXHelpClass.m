//
//  LXHelpClass.m
//  TestVal
//
//  Created by 李旭 on 16/3/21.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXHelpClass.h"
#import "SynthesizeSingleton.h"

#define GetLabelNormalHeight(height,font,spaceH) (height + (height - [UIFont systemFontOfSize:font].pointSize)*(spaceH>0 ? spaceH : 0.05))

@implementation LXHelpClass

SYNTHESIZE_SINGLETON_FOR_CLASS(LXHelpClass)

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFaceData];
    }
    return self;
}

- (void)setFaceData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"expression2" ofType:@"plist"];
    NSMutableArray *faces = [NSMutableArray arrayWithContentsOfFile:path];
    _keyArrAll = [[NSMutableArray alloc] init];
    _valueArrAll = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in faces) {
        [_keyArrAll addObject:[dic allKeys][0]];
        [_valueArrAll addObject:[dic allValues][0]];
    }
}
+ (NSArray *)getFace
{
    NSString *plistFilePath = [[NSBundle mainBundle] pathForResource:@"expression2" ofType:@"plist"];
    NSArray *arr = [NSArray arrayWithContentsOfFile:plistFilePath];
    return arr;
}

/**
 *@param textStr 富文本的string属性的值
 *@param maxSize 控件所需最大空间，一般高是最大值，如：CGSizeMake(stockNameLabelW, MAXFLOAT)
 *@param font 字体大小
 *@param spaceRH label行距占行高的比例，若无设置行距则值为0.05
 */
+ (CGFloat)calculateLabelighWithText:(NSString *)textStr withMaxSize:(CGSize)maxSize withFont:(CGFloat)font withSpaceRH:(CGFloat)spaceRH
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:font], NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGRect rect = [textStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    return GetLabelNormalHeight(rect.size.height, font, spaceRH);
}

@end


