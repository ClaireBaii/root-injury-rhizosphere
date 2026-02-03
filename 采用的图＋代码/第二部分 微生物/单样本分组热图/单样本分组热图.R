# 安装包（如果未安装）
install.packages(c("pheatmap", "viridis"))

# 加载包
library(pheatmap)
library(viridis)  # 可选，用于颜色方案
# 读取数据（确保CSV文件第一列为微生物名）
setwd("E:/我的/蔡金秀论文/榆树根系/断根组数据")
data_matrix <- read.csv("断根 phylum.csv", row.names = 1, header = TRUE)

# 检查数据维度是否符合预期（假设5组，每组1样本）
expected_groups <- c("Control", "Processing1", "Processing2", "Processing3", "Processing4")
if (ncol(data_matrix) != length(expected_groups)) {
  stop(paste("数据列数(", ncol(data_matrix), ")与分组数(", length(expected_groups), ")不匹配"))
}

# -------------------- 2. 数据预处理 --------------------
# 删除全零或恒定行（防止标准化错误）
data_filtered <- data_matrix[apply(data_matrix, 1, function(x) sd(x) > 0), ]

# -------------------- 3. 标准化处理 --------------------
# 行方向Z-score标准化（自动跳过无效行）
data_scaled <- t(scale(t(data_filtered)))

# 严格检查标准化结果
if (any(is.na(data_scaled)) || any(is.infinite(data_scaled))){
    stop("标准化失败:存在NA/Inf值，请检查输入数据")
}

#4.分组信息设置
 #定义分组(假设列名顺序与分组一致)
group_info <- data.frame(
  Group = expected_groups,
  row.names =colnames(data_matrix)
)
# 定义分组颜色(名称需完全匹配)
group_colors <- list(
  Group =c(
    Control ="#1B9E77",
    Processing1 ="#D95F02",
    Processing2="#7570B3",
    Processing3="#E7298A",
    Processing4="#66A61E"
  )
)
#5.绘制热图与聚类树
pheatmap(
  mat= data_scaled,
# 聚类参数
  cluster_rows = TRUE, # 对微生物(行)聚类
  cluster_cols = FALSE, #没组一个样本，列无法聚类
  clustering_distance_rows = "euclidean",
  clustering_method="ward.D2",
  # 分组注释
  annotation_col = group_info,
  annotation_colors =group_colors,
  # 图形参数
  color = viridis(100),
  show_colnames = TRUE,   #显示样本名称
  show_rownames = TRUE,   #显示微生物名称
  main="单样本分组热图(Phylum Level)",
  # 调试参数
  silent = FALSE  #显示聚类过程信息
)
