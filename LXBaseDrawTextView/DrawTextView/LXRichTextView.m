

#import "LXRichTextView.h"
#import <CoreText/CoreText.h>
#import "LXRichTextEmojiRun.h"
#import "LXRichTextURLRun.h"

@implementation LXRichTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _text = @"";
        _font = [UIFont systemFontOfSize:12.0];
        _textColor = [UIColor blackColor];
        _lineSpacing = 1.0;
        self.userInteractionEnabled = YES;
        self.urlName = @"";
        self.urlDic = @{};
        //
        self.isUrl = YES;
        _richTextRunsArray = [[NSMutableArray alloc] init];
        _richTextRunRectDic = [[NSMutableDictionary alloc] init];
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
#pragma mark - Draw Rect
- (void)drawRect:(CGRect)rect
{
    //解析文本
    _textAnalyzed = [self analyzeText:_text andIsUrl:self.isUrl];
    
    //要绘制的文本
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:self.textAnalyzed];
    
    NSMutableParagraphStyle * paragraphStyle0 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle0 setLineBreakMode:NSLineBreakByCharWrapping];
    [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle0 range:NSMakeRange(0, attString.length)];
    
//    CTParagraphStyleSetting lineBreakMode;
//    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping; //换行模式
//    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
//    lineBreakMode.value = &lineBreak;
//    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
//    CTParagraphStyleSetting settings[] = {lineBreakMode};
//    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 1);   //第二个参数为settings的长度
//    [attString addAttribute:(NSString *)kCTParagraphStyleAttributeName
//                      value:(id)paragraphStyle
//                      range:NSMakeRange(0, attString.length)];
    
    //设置字体
    CTFontRef aFont = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    [attString addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)aFont range:NSMakeRange(0,attString.length)];
    CFRelease(aFont);
    
    //设置颜色
    [attString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)self.textColor.CGColor range:NSMakeRange(0,attString.length)];
    
    //文本处理
    for (LXRichTextBaseRun *textRun in self.richTextRunsArray)
    {
        [textRun replaceTextWithAttributedString:attString];
    }

    //绘图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping; //换行模式
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    CTParagraphStyleSetting settings[] = {lineBreakMode};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 1);   //第二个参数为settings的长度
    [attString addAttribute:(NSString *)kCTParagraphStyleAttributeName
                      value:(id)paragraphStyle
                      range:NSMakeRange(0, attString.length)];
    
    //修正坐标系
    CGAffineTransform textTran = CGAffineTransformIdentity;
    textTran = CGAffineTransformMakeTranslation(0.0, self.bounds.size.height);
    textTran = CGAffineTransformScale(textTran, 1.0, -1.0);
    CGContextConcatCTM(context, textTran);

    //绘制
    int lineCount = 0;
    CFRange lineRange = CFRangeMake(0,0);
    CTTypesetterRef typeSetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attString);
    float drawLineX = 0;
    float drawLineY = self.bounds.origin.y + self.bounds.size.height - self.font.ascender;
    BOOL drawFlag = YES;
    [self.richTextRunRectDic removeAllObjects];
    
    while(drawFlag)
    {
        CFIndex testLineLength = CTTypesetterSuggestLineBreak(typeSetter,lineRange.location,self.bounds.size.width);
check:  lineRange = CFRangeMake(lineRange.location,testLineLength);
        CTLineRef line = CTTypesetterCreateLine(typeSetter,lineRange);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        
        //边界检查
        CTRunRef lastRun = CFArrayGetValueAtIndex(runs, CFArrayGetCount(runs) - 1);
        CGFloat lastRunAscent;
        CGFloat laseRunDescent;
        CGFloat lastRunWidth  = CTRunGetTypographicBounds(lastRun, CFRangeMake(0,0), &lastRunAscent, &laseRunDescent, NULL);
        CGFloat lastRunPointX = drawLineX + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(lastRun).location, NULL);
        
        if ((lastRunWidth + lastRunPointX) > self.bounds.size.width)
        {
            if (testLineLength > 0) {
                testLineLength--;
                CFRelease(line);
                goto check;
            }
            
            drawFlag = NO;
        }
        
        //绘制普通行元素
        drawLineX = CTLineGetPenOffsetForFlush(line,0,self.bounds.size.width);
        CGContextSetTextPosition(context,drawLineX,drawLineY);
        CTLineDraw(line,context);
        
        //绘制替换过的特殊文本单元
        for (int i = 0; i < CFArrayGetCount(runs); i++)
        {
            CTRunRef run = CFArrayGetValueAtIndex(runs, i);
            NSDictionary* attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
            LXRichTextBaseRun *textRun = [attributes objectForKey:@"TQRichTextAttribute"];
            if (textRun)
            {
                CGFloat runAscent,runDescent;
                CGFloat runWidth  = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                CGFloat runHeight = runAscent + (-runDescent);
                CGFloat runPointX = drawLineX + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                CGFloat runPointY = drawLineY - (-runDescent);

                CGRect runRect = CGRectMake(runPointX, runPointY, runWidth, runHeight);
                
                BOOL isDraw = [textRun drawRunWithRect:runRect];
                
                if (textRun.isResponseTouch)
                {
                    if (isDraw)
                    {
                        [self.richTextRunRectDic setObject:textRun forKey:[NSValue valueWithCGRect:runRect]];
                    }
                    else
                    {
                        runRect = CTRunGetImageBounds(run, context, CFRangeMake(0, 0));
                        runRect.origin.x = runPointX;
                        [self.richTextRunRectDic setObject:textRun forKey:[NSValue valueWithCGRect:runRect]];
                    }
                }
            }
        }

        CFRelease(line);
        
        if(lineRange.location + lineRange.length >= attString.length)
        {
            drawFlag = NO;
        }

        lineCount++;
        drawLineY -= self.font.ascender + (- self.font.descender) + self.lineSpacing;
        lineRange.location += lineRange.length;
    }
    
    CFRelease(typeSetter);
}

#pragma mark - Analyze Text
//-- 解析文本内容
- (NSString *)analyzeText:(NSString *)string andIsUrl:(BOOL)isUrl
{
    [self.richTextRunsArray removeAllObjects];
    [self.richTextRunRectDic removeAllObjects];
    
    NSString *result = @"";
    
    NSMutableArray *array = self.richTextRunsArray;
    
//    result = [LXRichTextEmojiRun analyzeText:string runsArray:&array];
//    result = [LXRichTextURLRun analyzeText:result runsArray:&array];
    
    if (isUrl) {
        result = [LXRichTextEmojiRun analyzeText:string runsArray:&array];
        NSDictionary *dic;
        if (self.urlName.length > 0) {
            dic = @{@"url": self.urlName, @"type": @"1"};
        } else if (self.urlDic.allKeys > 0) {
            dic = @{@"url": self.urlDic, @"type": @"2"};
        } else {
            dic = @{@"url": @"", @"type": @"0"};
        }
        result = [LXRichTextURLRun analyzeText:result runsArray:&array andUrlName:dic];
    } else {
        result = [LXRichTextEmojiRun analyzeText:string runsArray:&array];
    }
    
    [self.richTextRunsArray makeObjectsPerformSelector:@selector(setOriginalFont:) withObject:self.font];

    return result;
}

- (void)tap:(id)sender
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    CGPoint location = [tap locationInView:self];
    
//    CGPoint location = [(UITouch *)[touches anyObject] locationInView:self];
    CGPoint runLocation = CGPointMake(location.x, self.frame.size.height - location.y);
    
    if (self.delegage && [self.delegage respondsToSelector:@selector(richTextView: touchBeginRun:)])
    {
        [self.richTextRunRectDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             __weak LXRichTextView *weakSelf = self;
             CGRect rect = [((NSValue *)key) CGRectValue];
             LXRichTextBaseRun *run = obj;
             if(CGRectContainsPoint(rect, runLocation))
             {
                 [weakSelf.delegage richTextView:weakSelf touchBeginRun:run];
             }
         }];
    }
}

#pragma mark - Set
- (void)setText:(NSString *)text
{
    _text = text;
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
    [self setNeedsDisplay];
    _font = font;
}

- (void)setTextColor:(UIColor *)textColor
{
    [self setNeedsDisplay];
    _textColor = textColor;
}

- (void)setLineSpacing:(float)lineSpacing
{
    [self setNeedsDisplay];
    _lineSpacing = lineSpacing;
}

@end















