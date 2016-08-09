# LXBaseDrawTextView
使用CoreGraphics框架画文本内容在view上实现富文本功能，包括：超链接（点击链接或是文字）、表情。

用CoreGraphics框架画文本的用户体验较UITextView的好。但是效率会比UITextView差，还有支持图片的功能设置大小时不是很好处理。

下面看一下画出来的富文本效果图：<br>
![screen.png](https://github.com/SoftProgramLX/LXBaseDrawTextView/blob/master/LXBaseDrawTextView/screen.png)
<br>
----
###集成代码如下：
```
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *text = @"[健身]我下载demo啊test[大哭]lms在https://github.com/SoftProgramLX?tab=repositories测试[微笑]选打11111我的github";
    
    LXRichTextView *view = [[LXRichTextView alloc] init];
    view.text = text;
    view.isUrl = YES;//设置为NO则不匹配链接。
    view.backgroundColor = [UIColor greenColor];
    view.font = [UIFont systemFontOfSize:18];
    view.delegage = self;
    view.urlDic = @{@"我的github": @"https://github.com/SoftProgramLX?tab=repositories", @"下载demo": @"https://github.com/SoftProgramLX/LXDrawTextView"};
    [self.view addSubview:view];
    
    view.frame = CGRectMake(20, 40, 300, [LXHelpClass calculateLabelighWithText:text withMaxSize:CGSizeMake(300, MAXFLOAT) withFont:18 withSpaceRH:0]);
}

- (void)richTextView:(LXRichTextView *)view touchBeginRun:(LXRichTextBaseRun *)run
{
    NSLog(@"%@", run.originalText);
}
```
* view.urlDic属性的作用：设置文本中出现的这些文本当作超链接处理，将文本作为字典的key，相应的地址作为value。<br>
* richTextView: touchBeginRun：这是点击了链接的触发方法，链接的地址是run.originalText。<br>

---
###核心代码如下：<br>
```
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
```
<br>
源码请点击[github地址](https://github.com/SoftProgramLX/LXBaseDrawTextView)下载。
---
QQ:2239344645    [我的github](https://github.com/SoftProgramLX?tab=repositories)<br>
