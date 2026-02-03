### 🌐 图3：分泌物共变网络图（Spearman + Betweenness 中心性）
# 文件：adjacency_matrix_filtered.csv
# R 版本：4.4.3
# 包依赖：igraph, ggraph, tidygraph
library(igraph)
library(ggraph)
library(RColorBrewer)
setwd("E:/我的/蔡金秀论文/榆树根系/断根组数据")
exu <- read.csv("exudate_corrected_matrix.csv", row.names = 1)
exu_t <- t(exu)

# 构建 Spearman 相关矩阵
cor_mat <- cor(exu_t, method = "spearman", use = "pairwise.complete.obs")
cor_mat[abs(cor_mat) < 0.7] <- 0
cor_mat[lower.tri(cor_mat)] <- 0
cor_mat[cor_mat < 0] <- -0.0001  # 替换负值为极小负数，避免 layout 报错

diag(cor_mat) <- 0

# 创建网络结构
net <- graph_from_adjacency_matrix(cor_mat, mode = "undirected", weighted = TRUE)
E(net)$cor_sign <- ifelse(E(net)$weight > 0, "positive", "negative")
E(net)$abs_weight <- abs(E(net)$weight)
V(net)$btw <- betweenness(net, weights = 1 / E(net)$abs_weight)

# 添加 Louvain 模块标签（用于上色）
V(net)$module <- as.factor(cluster_louvain(net)$membership)

# 设置仅显示高中心性标签（前30%）
thresh <- quantile(V(net)$btw, 0.7)
V(net)$label_show <- V(net)$btw > thresh
# 输出节点属性表
node_info <- data.frame(
  Compound = V(net)$name,
  Betweenness = V(net)$btw,
  Module = V(net)$module,
  Label_Shown = V(net)$label_show
)
write.csv(node_info, "node_attributes_table.csv", row.names = FALSE)

# 绘图
set.seed(42)
ggraph(net, layout = "stress") +
  geom_edge_link(aes(edge_alpha = abs_weight, color = cor_sign), show.legend = TRUE) +
  geom_node_point(aes(size = btw, fill = module), shape = 21, color = "black") +
  geom_node_text(aes(label = ifelse(label_show, name, "")), repel = TRUE, size = 3) +
  scale_fill_brewer(palette = "Set3", name = "Module") +
  scale_edge_color_manual(values = c("positive" = "#1f78b4", "negative" = "#e41a1c"), name = "Correlation") +
  scale_edge_alpha(range = c(0.3, 1), name = "|ρ|") +
  scale_size_continuous(range = c(2, 10)) +
  theme_void() +
  labs(title = "Co-variance Network of Root Exudates Based on Spearman Correlation (|ρ| ≥ 0.7)")
