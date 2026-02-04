下面给出**修回中所有“代码相关”的工作清单**（按审稿意见驱动，覆盖你需要补的分析、稳健性检验、图表再生成、复现与公开）。我用“任务→对应意见ID→具体要做什么→产物/脚本形态→最小命令骨架”来写，方便你直接拆给自己或合作者。

---

## 0) 代码公开与可复现框架（硬性项）

**对应**：C080、C075、C051、C073（以及全体“方法可复现”）

### 0.1 建立公开仓库与DOI

* 要做什么

  * GitHub 建仓（或整理现有仓库），绑定 Zenodo，发一个 release 生成 DOI
  * 加 `CITATION.cff`、`LICENSE`、`README`、`CHANGELOG`（可选）
* 产物

  * GitHub repo + Zenodo DOI
  * `CITATION.cff`、`README.md`
* 骨架

  * `git tag v1.0.1 && git push --tags`（或 GitHub release）

### 0.2 环境冻结（R + QIIME2）

* 要做什么

  * R：用 `renv` 固化包版本；输出 `sessionInfo()`
  * QIIME2：明确到小版本（如 2024.2），导出环境说明（conda env yml 或 qiime2 “about”输出）
* 产物

  * `renv.lock`、`sessionInfo.txt`
  * `qiime2_version.txt`、`qiime2_env.yml`（或安装说明）
* 骨架

  * R：`renv::init(); renv::snapshot(); writeLines(capture.output(sessionInfo()), "sessionInfo.txt")`

### 0.3 一键复现入口

* 要做什么

  * 给一个从“输入数据→输出所有主图/补图/关键表”的入口（推荐 `targets` / `drake` / `Makefile` / `Snakemake` 任选一种）
  * 固定随机种子、统一输出目录结构
* 产物

  * `run_all.sh` 或 `Makefile` 或 `targets.R`
  * `outputs/figures/`、`outputs/tables/`、`outputs/supp/`
* 骨架

  * `bash run_all.sh`（内部串联 R + QIIME2 命令）

---

## 1) 微生物组分析代码（含稀释稳健性与核心结果复算）

**对应**：C049、C054、C055、C056、C045、C071

### 1.1 “n=3 trees + three-point composite”统计单位校验脚本

* 要做什么

  * 从元数据表（mapping file）检查：每个 treatment 是否恰好 3 个独立 tree_id
  * 确保 subsample 不被当独立样本进入统计
* 产物

  * `qc_check_replicates.R` + `outputs/qc/n_check.txt`

### 1.2 α多样性（Chao1）数值复算与文本一致性核查

* 要做什么

  * 重新计算 Control vs Treat1 的差值与百分比，自动输出到表
  * 同步生成用于 Figure 3A 的数据表（避免“图文不一致”再次发生）
* 产物

  * `alpha_diversity_recalc.R` + `outputs/tables/alpha_summary.csv`

### 1.3 β多样性：non-rarefied vs rarefied 稳健性对照

* 要做什么

  * 生成两套流程：

    * 不稀释：直接用相对丰度/适当变换后的距离
    * 稀释：rarefy 到统一深度（如 ≥10,000 reads/sample 或你数据允许的最大统一深度）
  * 两套都跑：PCoA + PERMANOVA（treatment），输出对照表
* 产物

  * `beta_diversity_robustness.R`
  * `outputs/supp/Supp_Rarefaction_Robustness.pdf`
  * `outputs/tables/permanova_compare.csv`
* 最小要点

  * PERMANOVA 用同一距离（Bray–Curtis）
  * 报告稀释深度选择依据（样本最小reads）

### 1.4 “各处理到Control平均Bray–Curtis距离”量化（非线性模式）

* 要做什么

  * 从距离矩阵提取每处理组样本与Control样本的 pairwise 距离
  * 汇总均值±误差，并可加置换/非参检验
* 产物

  * `bray_to_control.R` + `outputs/tables/bray_to_control.csv` + `outputs/figures/bray_to_control.pdf`

### 1.5 “~27 phyla”清单导出（差异判定规则一致）

* 要做什么

  * 固定差异分析规则（阈值、统计方法、校正方式）
  * 导出 phylum 列表与代表项，正文用代表，完整表放补充
* 产物

  * `phyla_enrichment_list.R` + `outputs/supp/Supp_Phyla_List.xlsx`

---

## 2) 代谢组处理代码（批次效应、缺失/零值插补、PCA loadings）

**对应**：C048、C052、C079、C016、C018

### 2.1 批次效应检测与校正（before/after 对照）

* 要做什么

  * 检测：PCA/UMAP按 batch 上色；PERMANOVA/方差解释（batch 因子）
  * 校正：ComBat（或你实际使用方法）
  * 输出：校正前后关键结构对比图 + 简短统计结论
* 产物

  * `metabolomics_batch_effect.R`
  * `outputs/supp/Supp_BatchEffect.pdf`

### 2.2 缺失值/零值处理：half-min 与 kNN 的明确实现 + 影响评估

* 要做什么

  * 明确实现：

    * `half_min_impute()`：half-min 的计算口径（基于每特征最小非零？还是全局最小？）
    * `knn_impute()`：kNN 的 k、距离、标准化方式
  * 对关键输出做敏感性：插补前/后（或 half-min vs kNN）对网络hub/关键关联对是否一致
* 产物

  * `imputation_methods.R`（含函数）
  * `imputation_sensitivity.R`
  * `outputs/supp/Supp_Imputation_Impact.pdf`

### 2.3 PCA loadings 输出

* 要做什么

  * 为 PCA 提供 loadings：top loadings 表 +（可选）loading plot
* 产物

  * `pca_loadings_export.R`
  * `outputs/supp/Supp_PCA_Loadings.pdf` 或 `outputs/tables/pca_loadings.csv`

---

## 3) 网络分析代码（阈值敏感性、正负相关检验、拓扑参数、hub citrate）

**对应**：C050、C058、C057、C044、C062、C068

### 3.1 网络阈值敏感性：|ρ|≥0.70 vs ≥0.50

* 要做什么

  * 同一相关算法/预处理，仅变阈值，构两套网络
  * 输出对照：节点数、边数、模块度Q、平均度、hub稳定性（citrate是否仍是hub）
* 产物

  * `network_build.R`（参数化阈值）
  * `network_sensitivity.R`
  * `outputs/supp/Supp_Network_Sensitivity.pdf`

### 3.2 正负相关 2:1 的显著性检验

* 要做什么

  * 统计正边/负边计数
  * 设定随机期望（最简单：0.5/0.5；更严谨：置换保持边数/分布）
  * 做 chi-square 或置换检验
* 产物

  * `pos_neg_ratio_test.R`
  * `outputs/tables/posneg_test.txt`

### 3.3 网络图（Figure 5）图注需要的参数自动输出

* 要做什么

  * Louvain 模块划分的参数/方法说明
  * 自动导出拓扑指标（平均度、模块度Q等）供图注/补充材料引用
* 产物

  * `network_topology_metrics.R` + `outputs/tables/network_metrics.csv`

### 3.4 hub citrate “双证据”脚本包

* 要做什么

  * 计算 citrate 的中心性指标（degree/betweenness等）
  * 同步导出 citrate 在各处理的变化幅度（强度差/折叠变化）
  * 在 chord 数据表中明确“关键对”（如 Citrate–Proteobacteria）的筛选标准与结果
* 产物

  * `citrate_hub_evidence.R`
  * `outputs/supp/Citrate_Evidence_Pack.pdf`
  * `outputs/tables/key_pairs_chord.csv`

---

## 4) 阈值回归与多组学耦合（分段回归CI、Procrustes、sPLS-DA）

**对应**：C059、C060、C061、C055（部分）、C033

### 4.1 分段回归（breakpoint）+ 置信区间

* 要做什么

  * 用 `segmented`（Muggeo路线）或等价方法
  * 输出 breakpoint 点估计 + CI + 拟合诊断
* 产物

  * `breakpoint_regression.R`
  * `outputs/supp/Supp_Breakpoint_CI.pdf`
  * `outputs/tables/breakpoint_ci.csv`

### 4.2 Procrustes（m²=0.47）复现与可解释材料输出

* 要做什么

  * 固化输入矩阵、距离度量、置换次数、随机种子
  * 输出 m²、p 值，并保存用于补充材料的图
* 产物

  * `procrustes_analysis.R`
  * `outputs/supp/Supp_Procrustes.pdf`

### 4.3 sPLS-DA：components与交叉验证透明化

* 要做什么

  * 固定：components 数选择流程、CV方案、变量数选择依据（15/12）
  * 导出：CV曲线、最终参数、入选变量列表
* 产物

  * `splsda_cv.R`
  * `outputs/supp/Supp_sPLSDA_CV.pdf`
  * `outputs/tables/splsda_selected_features.csv`

---

## 5) 图表再生成代码（统一字体、分辨率、面板字母、避免拉伸）

**对应**：C017、C018、C020、C021、C022、C023、C074、C084、C086

### 5.1 统一作图主题与导出函数

* 要做什么

  * 在 R 里写一个 `theme_pub()` 与 `save_pub()`：统一字体/字号/线宽/导出尺寸
  * 强制导出为矢量（pdf）+ 600dpi png（如期刊要求）
* 产物

  * `plot_theme.R`（含统一主题和保存函数）

### 5.2 面板字母自动化（A/B/C…）

* 要做什么

  * 用 `patchwork`/`cowplot`/`ggpubr` 统一面板标签，确保大小写一致
* 产物

  * `compose_panels.R`（所有组合图集中生成，避免手工改）

### 5.3 每张图对应一个脚本（保证可复现）

* 要做什么

  * `fig2.R`、`fig3.R`、`fig5.R`、`fig6.R`、`fig7.R`、`fig9.R`
  * 每个脚本输出：主图文件 + 图注需要的关键统计数字（写入 `outputs/tables/figX_stats.csv`）
* 产物

  * `scripts/figures/figX_*.R` + `outputs/figures/FigX.pdf/png`

---

## 6) 补充材料自动生成（把“证据包”一次性产出）

**对应**：C048、C049、C050、C052、C059、C061、C075、C074

* 要做什么

  * 用 RMarkdown/Quarto 生成 `Supplementary.pdf`：

    * Batch effect before/after
    * rarefaction robustness
    * network sensitivity
    * imputation impact
    * breakpoint CI
    * sPLS-DA CV
    * 关键表（phylum list、loadings、距离、网络指标）
* 产物

  * `supplementary.qmd`（或 `.Rmd`）
  * `outputs/supp/Supplementary.pdf`
* 最小命令骨架

  * `quarto render supplementary.qmd` 或 `rmarkdown::render("supplementary.Rmd")`

---

## 7) 数据可用性与“可复现最小包”脚本

**对应**：C075、C080

### 7.1 数据下载与校验脚本（让审稿人能跑）

* 要做什么

  * `download_data.sh`：从 SRA / Zenodo / MetaboLights 拉取数据或处理后表
  * 校验：checksum（md5/sha256）保证一致
* 产物

  * `scripts/download_data.sh` + `checksums.txt`

### 7.2 一键跑全流程脚本

* 要做什么

  * 串联：数据下载 → 预处理 → 关键分析 → 生成所有图表与补充材料
* 产物

  * `run_all.sh`（内部调用 R 脚本/Quarto）

---

# 你现在可以直接执行的“最小交付清单”（按优先级）

1. `run_all.sh` + `README`（复现入口）
2. `renv.lock` + `sessionInfo.txt` + `qiime2_version.txt`（版本）
3. `Supp_Rarefaction_Robustness.pdf`（C049）
4. `Supp_Network_Sensitivity.pdf`（C050）
5. `Supp_Imputation_Impact.pdf`（C052/C079）
6. `Supp_Breakpoint_CI.pdf`（C059）
7. `Supp_BatchEffect.pdf`（C048）
8. `Citrate_Evidence_Pack.pdf` + `key_pairs_chord.csv`（C044/C062）
9. 全部主图脚本化再生成（C084/C021等图形硬伤）
