library(mixOmics)
library(ggplot2)

# ---- Paths (relative to project root) ----
get_script_dir <- function() {
  script_path <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
  if (!is.null(script_path) && nzchar(script_path)) return(dirname(normalizePath(script_path)))
  cmd_args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", cmd_args, value = TRUE)
  if (length(file_arg) == 1) return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  getwd()
}

find_project_root <- function(start_dir) {
  candidates <- c(start_dir, file.path(start_dir, ".."), file.path(start_dir, "..", ".."))
  for (cand in candidates) {
    if (file.exists(file.path(cand, "data")) && file.exists(file.path(cand, "scripts"))) {
      return(normalizePath(cand))
    }
  }
  normalizePath(start_dir)
}

project_root <- find_project_root(get_script_dir())
setwd(project_root)
data_derived_dir <- file.path("data", "derived")

# 数据读取
phylum_mat  <- read.csv(file.path(data_derived_dir, "task1_clean_phylum.csv"), row.names = 1, check.names = FALSE)
exudate_mat <- read.csv(file.path(data_derived_dir, "task1_clean_exudate.csv"), row.names = 1, check.names = FALSE)

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
