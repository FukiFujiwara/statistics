# 説明

パッケージを読み込ます。   
    
tidyverseはggplot2やdplyrが入ったパッケージ群です。
ggpmiscは散布図のプロットの際に回帰式を書くのに用います。
multcompは多重比較を行う際に使用します。

```
library(tidyverse)
library(ggpmisc)
library(multcomp)
```
<br>

データを読み込みます。    
引数colClassesでは各列のデータ型を指定しています。
```
data <- read.csv("sample_data.csv", header = TRUE, colClasses=c("factor","factor","numeric","numeric"))
```
<br>

以下のように各処理９つのデータ（３×３ブロック）を含むデータフレームとなっています。      
数値としては、生鮮重（Fresh_weight）と硝酸イオン濃度（NO3）の２つを含んでいます。
```
head(data)
```

```
# head(data)
#   treatment block Fresh_weight   NO3
# 1         0     1        13.29 116
# 2         0     2        15.40  80
# 3         0     3        14.44 197
# 4         0     1         8.68 188
# 5         0     2        13.25 177
# 6         0     3         6.11 184
```
<br>

dplyrのgroup_by()やsummarise()を使って同一プロットのデータを平均し、プロットの値とします。
```
df <- data %>% 
  group_by(block,treatment) %>% 
  summarise(Fresh_weight = mean(fresh_weight), NO3 = mean(no3))
```
<br>

以下のように各処理３つのデータを含むデータフレームができます。

```
head(df)
```

```
#   treatment block Fresh_weight   NO3
#   <fct>     <fct>        <dbl> <dbl>
# 1 0         1             10.6  153.
# 2 0         2             15.8  121 
# 3 0         3             11.7  186.
# 4 10        1             14.6  322.
# 5 10        2             25.5  302.
# 6 10        3             24.1  301 
```

## 分散分析

分散分析はaov()を用いて行います。     
まずは、ブロックは考慮せず生鮮重を目的変数、処理を説明変数として分散分析を行います。
```
a <- aov(Fresh_weight ~ treatment, df)
summary(a)
```
<br>


結果は、施肥の効果が有意に検出されました。
```
#             Df Sum Sq Mean Sq F value Pr(>F)  
# treatment    3  371.8  123.95   5.449 0.0246 *
# Residuals    8  182.0   22.75                 
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```
<br>


次に、ブロック効果を固定効果として追加して分散分析を行います。

```
a <- aov(Fresh_weight ~ treatment + block, df)
summary(a)
```
<br>


結果は、施肥とブロックの効果がそれぞれ有意に検出されました。      
ブロック効果を考慮したことで、残差の平均平方が減少し、処理のF値（要因の平均平方/残差の平均平方）が増加しています。      
処理の効果がよりはっきりと検出されたことになります。

```
#             Df Sum Sq Mean Sq F value  Pr(>F)   
# treatment    3  371.8  123.95  11.683 0.00644 **
# block        2  118.3   59.16   5.576 0.04280 * 
# Residuals    6   63.7   10.61                   
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```
<br>


ブロック効果を以下のように変量効果として指定をしても、固定効果として計算した場合と結果は変わりません。

```
a <- aov(Fresh_weight ~ treatment + Error(block), df)
summary(a)

# Error: block
#           Df Sum Sq Mean Sq F value Pr(>F)
# Residuals  2  118.3   59.16               
# 
# Error: Within
#           Df Sum Sq Mean Sq F value  Pr(>F)   
# treatment  3  371.8  123.95   11.68 0.00644 **
# Residuals  6   63.7   10.61                   
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```
<br>

同様の分散分析は、lm()とanova()を用いて以下のように計算もできます。
```
a <- lm(Fresh_weight ~ treatment + block, df)
anova(a)

# Analysis of Variance Table
# 
# Response: Fresh_weight
#           Df Sum Sq Mean Sq F value   Pr(>F)   
# treatment  3 371.84 123.948 11.6832 0.006445 **
# block      2 118.32  59.158  5.5761 0.042804 * 
# Residuals  6  63.65  10.609                    
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

## 多重比較

Tukey-Kramer法を用いて多重比較を行います。     
標準の関数TukeyHSD()で実行できます。

```
a <- aov(Fresh_weight ~ treatment, df)
TukeyHSD(a)
```
<br>

結果は、N0kgとN20kgの間でのみ有意差が検出されました。
```
#   Tukey multiple comparisons of means
#     95% family-wise confidence level
# 
# Fit: aov(formula = Fresh_weight ~ treatment, data = df)
# 
# $`df$treatment`
#             diff        lwr        upr     p adj
# 10-0    8.705556  -3.764791 21.1759023 0.1932889
# 20-0   13.908889   1.438542 26.3792356 0.0298518
# 30-0    1.744444 -10.725902 14.2147912 0.9681791
# 20-10   5.203333  -7.267013 17.6736800 0.5677035
# 30-10  -6.961111 -19.431458  5.5092356 0.3448667
# 30-20 -12.164444 -24.634791  0.3059023 0.0558501
```
<br>

同様の検定を、multcompパッケージのglht()を用いても実行できます。
```
tukey_res <- glht(a, linfct=mcp(treatment="Tukey"))
summary(tukey_res)
```

```
# 	 Simultaneous Tests for General Linear Hypotheses
# 
# Multiple Comparisons of Means: Tukey Contrasts
# 
# 
# Fit: aov(formula = Fresh_weight ~ treatment, data = df)
# 
# Linear Hypotheses:
#              Estimate Std. Error t value Pr(>|t|)   
# 10 - 0 == 0     8.706      3.894   2.236   0.1932 
# 20 - 0 == 0    13.909      3.894   3.572   0.0299 *
# 30 - 0 == 0     1.744      3.894   0.448   0.9682  
# 20 - 10 == 0    5.203      3.894   1.336   0.5676  
# 30 - 10 == 0   -6.961      3.894  -1.788   0.3449  
# 30 - 20 == 0  -12.164      3.894  -3.124   0.0556 .
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# (Adjusted p values reported -- single-step method)
```
<br>

検定結果から有意差を示すアルファベットを取り出します。       
cld()という関数を用いると、結果から自動で取り出すことができます。

```
mltv <- cld(tukey_res, decreasing=F)
annos <- mltv[["mcletters"]][["Letters"]]
```
手打ちでも可能です。
```
annos <- c("a","ab","b","ab")
```

<br>

最後にグラフを書きます。        
stat_summary()でアルファベットを記入します。
```
g <- ggplot(df, aes(x = treatment, y = Fresh_weight))+
  stat_boxplot(geom = "errorbar", width = 0.3)+
  geom_boxplot()+
  stat_summary(geom = 'text', label =annos,  vjust = -5)+
  labs(x = "施肥量 (kg/10a)", y = "生鮮重 (g/plant)")+
  scale_y_continuous(expand = c(0,0),limits = c(0,50))+
  theme_classic()+
  theme(text = element_text(size=18, family = "HiraKakuPro-W3"),
        axis.title.y = element_text(margin = margin(0,20,0,0)),
        axis.title.x = element_text(margin = margin(20,0,0,0))
        )
g
```
<img src=https://user-images.githubusercontent.com/73625448/138549289-7c06f0a6-bf01-44f6-a304-135ad82fefea.png width=70%>

## 相関分析

相関分析はcor.test()関数で実行できます。

```
cor.test(df$NO3, df$Fresh_weight)
```

<br>

ここでは、生鮮重と硝酸イオン濃度の間に有意な正の相関が検出されました。     
相関係数(R)は0.70、p値は0.01です。

```
# 	Pearson's product-moment correlation
# 
# data:  df$NO3 and df$Fresh_weight
# t = 3.1315, df = 10, p-value = 0.01066
# alternative hypothesis: true correlation is not equal to 0
# 95 percent confidence interval:
#  0.2176099 0.9100454
# sample estimates:
#       cor 
# 0.7036367 
```

<br>

散布図を描いて、単回帰直線と回帰式などを記入します。      
geom_smooth()で回帰直線を記入できます。      
また、ggpmiscパッケージのstat_poly_eq()で回帰式やR^2、p値などを記入することができます。

```
g <- ggplot(df, aes(x = NO3, y = Fresh_weight))+
  geom_point()+
  geom_smooth(method = "lm", linetype = "dashed", se = FALSE, col="orange")+
  stat_poly_eq(formula = y ~ x,
               aes(label = paste(stat(eq.label),
                                 stat(rr.label),
                                 stat(p.value.label),
                                 sep = "~~~")),
               parse = TRUE)+
  scale_y_continuous(expand = c(0,0),limits = c(0,45))+
  scale_x_continuous(expand = c(0,0),limits = c(0,600))+
  labs(x = "NO3-N concentration (mg/100g)", y = "Fresh weight (g/plant)")+
  theme_classic()+
  theme(text = element_text(size=18))

g
```

<img src=https://user-images.githubusercontent.com/73625448/138548939-f9773ccb-9523-4eab-9525-c739ee29e01f.png width=70%>

