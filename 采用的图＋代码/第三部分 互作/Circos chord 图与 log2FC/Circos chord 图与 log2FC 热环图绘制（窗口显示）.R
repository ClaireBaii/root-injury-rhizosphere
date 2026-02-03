library(circlize)
library(viridis)
library(dplyr)
edge_list <- read.csv("task2_significant_pairs.csv")
edge_list$rho <- as.numeric(edge_list$rho)
phylum_mat  <- read.csv("task1_clean_phylum.csv", row.names = 1, check.names = FALSE)
exudate_mat <- read.csv("task1_clean_exudate.csv", row.names = 1, check.names = FALSE)

all_nodes <- unique(c(edge_list$from, edge_list$to))
phylum_nodes  <- intersect(all_nodes, colnames(phylum_mat))
exudate_nodes <- intersect(all_nodes, colnames(exudate_mat))
sector_order  <- c(exudate_nodes, phylum_nodes)

link_colors <- ifelse(
  edge_list$rho > 0.8, "#B2182B",
  ifelse(edge_list$rho > 0.6, "#FD8D3C",
         ifelse(edge_list$rho < -0.8, "#2166AC", "#6BAED6")))
link_lwd <- ifelse(abs(edge_list$rho) > 0.8, 1.5, 0.6)

grid.col <- c(
  setNames(c("#440154", "#21908C", "#FDE725", "#3B528B"),
           c("Organic_acid", "Phenol_Flavonoid", "Sugar_Amino", "Alkaloid")),
  setNames(rep("grey80", length(phylum_nodes)), phylum_nodes)
)

circos.clear()
circos.par(gap.after = {
  n_exu <- length(exudate_nodes)
  n_phy <- length(phylum_nodes)
  after_exu <- if (n_exu > 1) rep(1.5, n_exu - 1) else numeric(0)
  after_phy <- if (n_phy > 1) rep(0.6, n_phy - 1) else numeric(0)
  c(after_exu, 6, after_phy, 6)
})

chordDiagram(
  x = edge_list[, c("from", "to", "rho")],
  order = sector_order,
  grid.col = grid.col,
  col = link_colors,
  link.lwd = link_lwd,
  transparency = 0.1,
  annotationTrack = "grid",
  preAllocateTracks = list(track.height = 0.1),
  reduce = 0
)

# 计算 log2FC（Processing / Control）
group_labels <- ifelse(grepl("Control", rownames(exudate_mat), ignore.case = TRUE), "Control", "Processing")
group_labels <- factor(group_labels)
mean_proc <- colMeans(exudate_mat[group_labels == "Processing", ])
mean_ctrl <- colMeans(exudate_mat[group_labels == "Control", ])
log2fc_vec <- log2((mean_proc + 1e-5) / (mean_ctrl + 1e-5))

# 补全 log2fc 缺失值
fc_track <- rep(NA, length(sector_order))
names(fc_track) <- sector_order
fc_track[names(log2fc_vec)] <- log2fc_vec[names(log2fc_vec)]

library(circlize)
fc_colors <- colorRamp2(c(-2, 0, 2), c("blue", "white", "red"))

circos.track(ylim = c(0, 1),
             panel.fun = function(x, y) {
               sector.name <- CELL_META$sector.index
               value <- fc_track[sector.name]
               if (!is.na(value)) {
                 col <- fc_colors(value)
                 circos.rect(CELL_META$xlim[1], 0,
                             CELL_META$xlim[2], 1,
                             col = col, border = NA)
               }
             }, track.height = 0.05, bg.border = NA)

circos.trackPlotRegion(track.index = 1, panel.fun = function(x, y) {
  name <- get.cell.meta.data("sector.index")
  circos.text(CELL_META$xcenter, CELL_META$ylim[1] + mm_y(2), name,
              facing = "clockwise", niceFacing = TRUE, cex = 0.6)
}, bg.border = NA)

legend("topleft",
       legend = c("Positive correlation (ρ > 0.6)",
                  "Negative correlation (ρ < -0.6)"),
       col = c("#FD8D3C", "#6BAED6"),
       lty = 1, lwd = 2,
       text.col = "black", cex = 0.8, bty = "n")
