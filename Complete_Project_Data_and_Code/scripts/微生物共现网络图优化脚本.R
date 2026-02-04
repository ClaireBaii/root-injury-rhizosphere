# -------------------- 1. 加载包 --------------------
library(igraph)
library(Hmisc)
library(tidyverse)
library(ggraph)
library(scales)
library(RColorBrewer)

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
data_input_dir <- file.path("data", "input")

# -------------------- 2. 读取并过滤数据 --------------------
data_matrix <- read.csv(file.path(data_input_dir, "断根 phylum.csv"), row.names = 1)
data_filtered <- data_matrix[rowSums(data_matrix > 0) > 0.2 * ncol(data_matrix), ]

# -------------------- 3. 计算 Spearman 相关性 --------------------
cor_result <- rcorr(t(data_filtered), type = "spearman")
r_values <- cor_result$r
p_values <- cor_result$P

# -------------------- 4. 提取显著正相关边 --------------------
sig_edges <- which(upper.tri(r_values) & r_values > 0.6 & p_values < 0.05, arr.ind = TRUE)
edges_df <- data.frame(
  from = rownames(r_values)[sig_edges[, 1]],
  to = rownames(r_values)[sig_edges[, 2]],
  weight = r_values[sig_edges]
)

# -------------------- 5. 构建正相关子图 --------------------
net <- graph_from_data_frame(edges_df, directed = FALSE)
net <- simplify(net)

# -------------------- 6. 检测模块并计算中心性 --------------------
V(net)$module <- as.factor(cluster_louvain(net)$membership)
V(net)$btw <- betweenness(net)
V(net)$size <- rescale(log1p(V(net)$btw), to = c(3, 8))

# -------------------- 7. 设置颜色与布局 --------------------
module_colors <- brewer.pal(max(3, length(unique(V(net)$module))), "Set2")
names(module_colors) <- levels(V(net)$module)
edge_palette <- colorRampPalette(c("#F0F0F0", "#D73027"))(100)

set.seed(123)
net <- delete_edges(net, E(net)[weight < 0.7])  # 移除弱相关边
net <- delete_vertices(net, degree(net) == 0)  # 删除孤立点
layout <- layout_with_fr(net, weights = E(net)$weight, niter = 5000, start.temp = 0.1)

# -------------------- 8. 可视化优化图 --------------------
graph_title <- "Modular Co-occurrence Network of Root Microbiome"
mod_score <- round(modularity(cluster_louvain(net)), 3)

p_microbe <- ggraph(net, layout = layout) +
  geom_edge_link(aes(color = weight, width = weight), alpha = 0.6, lineend = "round") +
  geom_node_point(aes(color = module, size = size), shape = 19, show.legend = TRUE) +
  geom_node_text(
    aes(label = ifelse(
      name %in% tapply(V(net)$name, V(net)$module, function(x) x[which.max(degree(net)[x])]),
      name, ""
    )),
    repel = TRUE, size = 3.5, fontface = "bold"
  ) +
  scale_color_manual(values = module_colors, name = "Module") +
  scale_edge_color_gradientn(colors = colorRampPalette(c("#FFCCCC", "#D73027"))(100), name = "Correlation Strength") +
  scale_edge_width(range = c(0.3, 1.5), guide = "none") +
  scale_size_identity() +
  theme_void() +
  theme(
    text = element_text(family = "Arial"),
    legend.box = "horizontal",
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 10),
    legend.text = element_text(size = 9),
    plot.title = element_text(hjust = 0.5, face = "bold", size = 12),
    plot.subtitle = element_text(hjust = 0.5, size = 10)
  ) +
  labs(title = graph_title, subtitle = paste("Louvain Modularity Q =", mod_score))

p_microbe
