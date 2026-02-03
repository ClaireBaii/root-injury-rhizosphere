### 📈 图2：分泌物 max log2FC 排序条形图
# 文件：compound_centrality_summary.csv
# R 版本：4.4.3
# 包依赖：ggplot2

library(ggplot2)

# 读取数据
setwd("E:/我的/蔡金秀论文/榆树根系/断根组数据")
summary_df <- read.csv("compound_centrality_summary_RECALC.csv", row.names = 1)

# 确保 Max_log2FC 可用
summary_df <- summary_df[!is.na(summary_df$Max_log2FC), ]

# 排序并选取前 50
top_fc <- summary_df[order(-summary_df$Max_log2FC), ][1:50, ]
top_fc$Compound <- factor(rownames(top_fc), levels = rev(rownames(top_fc)))  # 反转方便坐标轴美化

# 绘图
ggplot(top_fc, aes(x = Compound, y = Max_log2FC)) +
  geom_bar(stat = "identity", fill = "#D55E00", width = 0.7) +
  coord_flip() +
  labs(title = "Top 50 Compounds by Max log2FC",
       x = NULL,
       y = "Max log2 Fold Change") +
  theme_minimal(base_size = 13) +
  theme(axis.text.y = element_text(size = 9),
        axis.text.x = element_text(size = 10),
        plot.title = element_text(hjust = 0.5))
