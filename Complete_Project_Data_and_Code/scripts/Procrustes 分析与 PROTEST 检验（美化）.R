library(vegan)
library(ggplot2)
library(reshape2)
library(dplyr)

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

exudate_mat <- read.csv(file.path(data_derived_dir, "task1_clean_exudate.csv"), row.names = 1)
phylum_mat  <- read.csv(file.path(data_derived_dir, "task1_clean_phylum.csv"), row.names = 1)

exudate_mat <- exudate_mat[intersect(rownames(exudate_mat), rownames(phylum_mat)), ]
phylum_mat  <- phylum_mat[rownames(exudate_mat), ]

exu_dist <- vegdist(exudate_mat, method = "euclidean")
phy_dist <- vegdist(phylum_mat, method = "euclidean")

proc_result <- procrustes(exu_dist, phy_dist, symmetric = TRUE)
pro_scores <- as.data.frame(proc_result$Yrot)
pro_scores$X1 <- proc_result$X[,1]
pro_scores$X2 <- proc_result$X[,2]
pro_scores$Sample <- rownames(proc_result$Yrot)

# 美化绘图（ggplot2 风格 Procrustes 箭头图）
p <- ggplot(pro_scores, aes(x = X1, y = X2)) +
  geom_point(aes(x = X1, y = X2), color = "steelblue", size = 3) +
  geom_point(aes(x = V1, y = V2), color = "firebrick", size = 3) +
  geom_segment(aes(x = X1, y = X2, xend = V1, yend = V2),
               arrow = arrow(length = unit(0.15, "cm")), color = "gray50") +
  geom_text(aes(x = V1, y = V2, label = Sample), hjust = -0.2, size = 3) +
  labs(title = "Procrustes Alignment between Exudates and Microbiota",
       x = "Dimension 1", y = "Dimension 2") +
  theme_minimal()
p
# PROTEST 显著性检验
protest_result <- protest(exu_dist, phy_dist, permutations = 999)
cat("PROTEST significance: p-value =", protest_result$signif, "
")

library(vegan)

exudate_mat <- read.csv(file.path(data_derived_dir, "task1_clean_exudate.csv"), row.names = 1)
phylum_mat  <- read.csv(file.path(data_derived_dir, "task1_clean_phylum.csv"), row.names = 1)

exudate_mat <- exudate_mat[intersect(rownames(exudate_mat), rownames(phylum_mat)), ]
phylum_mat  <- phylum_mat[rownames(exudate_mat), ]

exu_dist <- vegdist(exudate_mat, method = "euclidean")
phy_dist <- vegdist(phylum_mat, method = "euclidean")

proc_result <- procrustes(exu_dist, phy_dist, symmetric = TRUE)
plot(proc_result, main = "Procrustes Analysis: Exudate vs Phylum")
text(proc_result, col = "blue", cex = 0.7)

protest_result <- protest(exu_dist, phy_dist, permutations = 999)
cat("PROTEST significance: p-value =", protest_result$signif, "
") 
