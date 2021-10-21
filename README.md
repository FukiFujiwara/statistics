# statistics

```
data <- read.csv("sample_data.csv", header = TRUE)
```

```
library(tidyverse)
```

```
df <- data %>% 
  group_by(block,treatment) %>% 
  summarise(Fresh_weight = mean(fresh_weight), NO3 = mean(no3))
```

