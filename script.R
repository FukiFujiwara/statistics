# パッケージ

#install.packages("tidyverse")
#install.packages("multcomp")
#install.packages("ggpmisc")
library(tidyverse)
library(multcomp)
library(ggpmisc)


#######################################################################
## データ生成

set.seed(100)

x <-rep(c(rep(-6,3),rep(2,3),rep(8,3),rep(-4,3)),3)
b <- rnorm(3,0,12)
b <- c(rep(b[1],12),rep(b[2],12),rep(b[3],12))
v1 <- matrix(c(20 + x + b + rnorm(36, 0, 6)), nrow=12)

x <-rep(c(rep(-100,3),rep(30,3),rep(100,3),rep(-30,3)),3)
b <- rnorm(3,0,20)
b <- c(rep(b[1],12),rep(b[2],12),rep(b[3],12))
v2 <- matrix(c(250 + x + b + rnorm(36, 0, 30)), nrow=12)


b <- factor(c(rep("0",3),rep("10",3),rep("20",3),rep("30",3)))

raw_data1 <- data.frame(b,v1)
raw_data2 <- data.frame(b,v2)

colnames(raw_data1) <- c("treatment","1","2","3")
colnames(raw_data2) <- c("treatment","1","2","3")

df1 <- raw_data1 %>%
  pivot_longer(col = -treatment, names_to = "block", values_to = "fresh_weight")
df2 <- raw_data2 %>%
  pivot_longer(col = -treatment, names_to = "block", values_to = "no3")


df <- cbind(df1,df2[,3])

df$block <- as.factor(df$block)

df$fresh_weight <- round(df$fresh_weight, 2)
df$no3 <- round(df$no3, 0)


write.csv(df,"sample_data.csv",row.names = FALSE)

#######################################################################

# データ読み込み

data <- read.csv("sample_data.csv", header = TRUE, colClasses=c("factor","factor","numeric","numeric"))

head(data)

df <- data %>%
  group_by(treatment,block) %>%
  summarise(Fresh_weight = mean(fresh_weight), NO3 = mean(no3))


# 分散分析

a <- aov(Fresh_weight ~ treatment, df)
summary(a)

a <- aov(Fresh_weight ~ treatment + block, df)
summary(a)

a <- aov(Fresh_weight ~ treatment + Error(block), df)
summary(a)

l <- lm(Fresh_weight ~ treatment + block, df)
anova(l)


# 多重比較

TukeyHSD(aov(df$Fresh_weight ~ df$treatment))


res <- lm(Fresh_weight ~  treatment, d=df)
tukey_res <- glht(res, linfct=mcp(treatment="Tukey"))
summary(tukey_res)


mltv <- cld(tukey_res, decreasing=F)
annos <- mltv[["mcletters"]][["Letters"]]

annos <- c("a","ab","b","ab")

g <- ggplot(df, aes(x = treatment, y = Fresh_weight))+
  stat_boxplot(geom = "errorbar", width = 0.3)+
  geom_boxplot()+
  stat_summary(geom = 'text', label =annos,  vjust = -6, size=5)+
  labs(x = "施肥量 (kg/10a)", y = "生鮮重 (g/plant)")+
  scale_y_continuous(expand = c(0,0),limits = c(0,42))+
  theme_classic()+
  theme(text = element_text(size=18, family = "HiraKakuPro-W3"),
        axis.title.y = element_text(margin = margin(0,20,0,0)),
        axis.title.x = element_text(margin = margin(20,0,0,0))
        )
  

g


# 相関分析

cor.test(df$NO3, df$Fresh_weight)

g <- ggplot(df, aes(x = NO3, y = Fresh_weight))+
  geom_point()+
  geom_smooth(method = "lm", linetype = "dashed", se = FALSE)+
  scale_y_continuous(expand = c(0,0),limits = c(0,42))+
  scale_x_continuous(expand = c(0,0),limits = c(0,500))+
  labs(x = "硝酸イオン濃度 (mg/100g)", y = "生鮮重 (g/plant)")+
  theme_classic()+
  theme(text = element_text(size=18, family = "HiraKakuPro-W3"),
        axis.title.y = element_text(margin = margin(0,20,0,0)),
        axis.title.x = element_text(margin = margin(20,0,0,0))
  )+
  stat_poly_eq(formula = y ~ x,
               aes(label = paste(stat(eq.label),
                                 stat(rr.label),
                                 stat(p.value.label),
                                 sep = "~~~")),
               parse = TRUE, size=5)

g

