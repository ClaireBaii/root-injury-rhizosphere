# Complete_Project_Data_and_Code 目录结构说明

本目录已做结构化整理：**未删除任何文件/代码，也未修改原文件内容**，仅将原本平铺在 `Complete_Project_Data_and_Code/` 下的内容按“脚本 / 数据 / 结果 / 文档”分层归档，方便检索与维护。

## 目录约定

- `scripts/`：R 分析脚本（原 `.R` 文件）
- `data/input/`：输入数据与人工整理的表格（如 Feature/Sample/Taxonomy、分泌物/断根相关表等）
- `data/derived/`：分析过程中产生的中间/输出表（如 `task*`、`*matrix*`、`*pvalue*`、`*significance*`、`*trend*` 等）
- `results/figures/`：图像与图表（`.pdf/.png/.tiff`），包含 `results/figures/显著相关散点图/`
- `results/objects/`：R 运行对象/模型（如 `.rds`、`.RData`）
- `results/logs/`：日志（`.log`）
- `results/archives/`：压缩包（`.zip`）
- `docs/`：说明文档（如 `.docx`）

## 运行提示（如需复现脚本）

脚本已将数据路径改为**相对本目录的相对路径**（例如 `data/derived/task1_clean_exudate.csv`），并在脚本开头自动定位并切换到项目根目录后再读取数据；因此通常无需手动 `setwd()`，直接运行 `scripts/` 下脚本即可复现。
