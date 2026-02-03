### 📊 图1：全谱分泌物 Z-score 热图（pheatmap）
# 文件：zscore_heatmap_data.csv
# R 版本：4.4.3
# 包依赖：pheatmap
### 📊 图1优化版：Top50 分泌物的 Z-score 热图（无 %>%）

library(pheatmap)
setwd("E:/我的/蔡金秀论文/榆树根系/断根组数据")
# 读取数据
zscore_all <- read.csv("zscore_heatmap_data.csv", row.names = 1)

# 选取标准差最大的前 50 个变量
var_rank <- apply(zscore_all, 2, sd)
top50_names <- names(sort(var_rank, decreasing = TRUE))[1:50]
top50_vars <- zscore_all[, top50_names]

# 配色方案
my_palette <- colorRampPalette(c("navy", "white", "firebrick3"))(100)

# 绘制热图
pheatmap(t(top50_vars),
         color = my_palette,
         scale = "row",
         cluster_rows = TRUE,
         cluster_cols = TRUE,
         fontsize_row = 9,  # ✅ 调整这里
         fontsize_col = 10,
         border_color = NA,
         treeheight_row = 30,
         treeheight_col = 30,
         main = "Top 50 Variable Root Exudates (Z-score)")
