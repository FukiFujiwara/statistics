# statistics

データを読み込みます    
引数colClassesでは各列のデータ型を指定しています。
```
data <- read.csv("sample_data.csv", header = TRUE, colClasses=c("factor","factor","numeric","numeric"))
```

データは以下のような構造になっています
```
# head(data)
#   block treatment fresh_weight no3
# 1     1         0        19.39 216
# 2     1         0        22.76 207
# 3     1         0        21.74 276
# 4     2         0        21.80 245
# 5     2         0        24.49 226
# 6     2         0        10.39 308
```
    
パッケージを読み込ます   
    
tidyverseはggplot2やdplyrが入ったパッケージ群です。
```
library(tidyverse)
library(ggpmisc)
library(multcomp)
```

dplyrを使って同一プロットのデータを平均し、プロットの値とします。
```
df <- data %>% 
  group_by(block,treatment) %>% 
  summarise(Fresh_weight = mean(fresh_weight), NO3 = mean(no3))
```

## 分散分析

ブロック効果を固定効果として追加します。

```
a <- aov(Fresh_weight ~ treatment + block, df)
summary(a)
```
結果は、施肥の効果が有意に検出されました。

```
#             Df Sum Sq Mean Sq F value  Pr(>F)   
# treatment    3 276.96   92.32  12.256 0.00571 **
# block        2   5.18    2.59   0.344 0.72232   
# Residuals    6  45.20    7.53                   
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```
ブロック効果を変量効果として指定しても同様です。

```
a <- aov(Fresh_weight ~ treatment +Error(block), df)
summary(a)

# Error: block
#           Df Sum Sq Mean Sq F value Pr(>F)
# Residuals  2  5.176   2.588               
# 
# Error: Within
#           Df Sum Sq Mean Sq F value  Pr(>F)   
# treatment  3  277.0   92.32   12.26 0.00571 **
# Residuals  6   45.2    7.53                   
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

lm()を用いて以下のように計算もできます。

```
model <- lm(brix ~ block + treatment, data = data)
anova(model)

# Analysis of Variance Table
# 
# Response: Fresh_weight
#           Df  Sum Sq Mean Sq F value   Pr(>F)   
# treatment  3 276.959  92.320 12.2560 0.005713 **
# block      2   5.176   2.588  0.3436 0.722315   
# Residuals  6  45.196   7.533                    
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

## 多重比較

```
res <- lm(Fresh_weight ~  treatment, d=df)
tukey_res <- glht(res, linfct=mcp(treatment="Tukey"))
summary(tukey_res)
```

```

``
mltv = cld(tukey_res, decreasing=F)
annos = mltv[["mcletters"]][["Letters"]]
```

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

## 相関分析

```
cor.test(df$NO3, df$Fresh_weight)
```

```
# 	Pearson's product-moment correlation
# 
# data:  df$NO3 and df$Fresh_weight
# t = 2.945, df = 10, p-value = 0.01466
# alternative hypothesis: true correlation is not equal to 0
# 95 percent confidence interval:
#  0.1767546 0.9024513
# sample estimates:
#       cor 
# 0.6815227 
```

```
g <- ggplot(df, aes(x = NO3, y = Fresh_weight))+
  geom_point()+
  geom_smooth(method = "lm", linetype = "dashed", se = FALSE, col="orange")+
  scale_y_continuous(expand = c(0,0),limits = c(0,45))+
  scale_x_continuous(expand = c(0,0),limits = c(0,600))+
  labs(x = "NO3-N concentration (mg/100g)", y = "Fresh weight (g/plant)")+
  theme_classic()+
  theme(text = element_text(size=18))+
  stat_poly_eq(formula = y ~ x,
               aes(label = paste(stat(eq.label),
                                 stat(rr.label),
                                 stat(p.value.label),
                                 sep = "~~~")),
               parse = TRUE)

g
```
