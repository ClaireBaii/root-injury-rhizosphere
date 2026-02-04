library(mixOmics)
library(ggplot2)

# 数据读取
phylum_mat  <- read.csv("task1_clean_phylum.csv", row.names = 1, check.names = FALSE)
exudate_mat <- read.csv("task1_clean_exudate.csv", row.names = 1, check.names = FALSE)

# 对齐样本顺序
common_samples <- intersect(rownames(phylum_mat), rownames(exudate_mat))
X <- cbind(phylum_mat[common_samples, ], exudate_mat[common_samples, ])

# 设置分组标签（自动识别 Control 与 Processing）
Y <- factor(ifelse(grepl("Control", rownames(X), ignore.case = TRUE), "Control", "Processing"))

# 构建 sPLS-DA 模型
set.seed(123)
spls_model <- splsda(X, Y, ncomp = 2, keepX = c(5, 5))

# 样本投影图（前两组分）
p1 <- plotIndiv(spls_model, comp = 1:2, group = Y,
                ind.names = TRUE, ellipse = TRUE, legend = TRUE,
                title = "sPLS-DA: Sample Projection")
print(p1)

# 主成分 1 加载图
p2 <- plotLoadings(spls_model, comp = 1, method = "mean", contrib = "max",
                   title = "sPLS-DA: Component 1 Loadings")
print(p2)

# 主成分 2 加载图
p3 <- plotLoadings(spls_model, comp = 2, method = "mean", contrib = "max",
                   title = "sPLS-DA: Component 2 Loadings")
print(p3)

# 提取前两组分的关键变量
vars1 <- selectVar(spls_model, comp = 1)$name
vars2 <- selectVar(spls_model, comp = 2)$name
top_features <- unique(c(vars1, vars2))
View(data.frame(Top_Features = top_features))