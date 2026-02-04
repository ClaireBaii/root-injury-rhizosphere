### 📊 图1：全谱分泌物 Z-score 热图（pheatmap）
# 文件：zscore_heatmap_data.csv
# R 版本：4.4.3
# 包依赖：pheatmap
### 📊 图1优化版：Top50 分泌物的 Z-score 热图（无 %>%）

library(pheatmap)

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

# 读取数据
zscore_all <- read.csv(file.path(data_derived_dir, "zscore_heatmap_data.csv"), row.names = 1)

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
