
<img width="2364" height="1264" alt="6bef66e7b3409081f3d61a1e62224fcf" src="https://github.com/user-attachments/assets/24d45544-51f0-430f-bb4d-ae43a918ef6e" />

<img width="2205" height="1297" alt="f0dd82942038d68ee9b50ec60d236659" src="https://github.com/user-attachments/assets/4ffe486a-d014-43de-9cbc-cda84e76004c" />

# 伊比利亚半岛尼安德特人消失研究复现报告
## 小组基本信息
- 杨舒妍 2025303110036
- 陈美林 2025303110140
- 王嘉仪 2025303120039
- 郜锦华 2025303120052
- 秦思怡 2025303110047

## 项目内容
### 论文基础信息
- 发表期刊：2022年《Nature Ecology & Evolution》
- 论文标题：*Ecosystem productivity affected the spatiotemporal disappearance of Neanderthals in Iberia*
- 发表时间：2022年11月29日
- 数据DOI：10.1038/s41559-022-01861-5
- 原始数据链接：https://doi.org/10.5281/zenodo.6832689
- 分析代码链接：https://doi.org/10.5281/zenodo.6832689
- 复现主题：生态系统生产力影响了伊比利亚半岛尼安德特人的时空消失
- 仓库链接：https://github.com/D2RS-2026spring/neanderthal-ecosystem-productivity

### 论文概述
#### 研究背景
旧石器时代中晚期过渡阶段（5–3万年前），伊比利亚半岛尼安德特人被现代人取代。MIS 3期气候冷暖波动被认为是关键影响因素，但气候如何通过生态系统影响尼安德特人消失的时空规律尚不明确。

#### 研究方法
1. 采用贝叶斯、最优线性估计、累积概率分布重建文化层年代
2. 利用动态植被模型（LPJ-GUESS）估算净初级生产力（NPP）
3. 结合宏生态模型与现代观测数据，计算食草动物承载量
4. 对比欧洲西伯利亚区、地中海区等4个生物地理区的差异

#### 研究内容
量化MIS 3期冷暖期对植物与食草动物生物量的影响，检验生态系统生产力是否决定尼安德特人消失与现代人到来的时空模式。

#### 核心结论
1. 北部欧洲西伯利亚区：尼安德特人消失与NPP、食草动物生物量骤降同步，现代人到来与资源回升吻合
2. 南部地中海区：冷暖期生产力波动小、中型食草动物生物量更稳定，尼安德特人存续更久
3. 生态生产力波动是伊比利亚尼安德特人南北差异消失的关键原因，南部成为气候避难所


### 原始数据及代码可复现性
#### 1. 克隆仓库
- HTTP：`https://github.com/D2RS-2026spring/neanderthal-ecosystem-productivity.git`
- SSH：`git@github.com:D2RS-2026spring/neanderthal-ecosystem-productivity.git`

#### 2. 配置环境
##### 2.1 R环境
- 版本要求：R 4.5.2
- 安装依赖包
```r
install.packages(c(
  "readxl",
  "tidyverse",
  "dplyr",
  "tidyr",
  "ggplot2",
  "openxlsx",
  "gridExtra",
  "robustbase",
  "rstatix",
  "ggdendro",
  "circlize",
  "dendextend"
))
```
- 配置国内镜像源

#### 3. 运行代码
需运行3个核心脚本，运行前将代码中`setwd`路径及图表输出路径替换为本地路径：
1. `02_reproduce_table1.R`
2. `03_fig3_author_code.R`
3. `04_fig5_author_code.R`
- 操作方式：R-文件-运行R脚本文件-选择对应R文件

#### 4. 输出图表
成功运行代码后，可复现论文核心图表：**图3、图5、表1**

### 复现结果
#### 1. 图3（食草动物承载力箱线图）
- 原图：<img width="693" height="671" alt="image" src="https://github.com/user-attachments/assets/40cdf661-d451-4658-9336-c297294eb440" />


- 复现图：<img width="690" height="363" alt="image" src="https://github.com/user-attachments/assets/8ae2a2f5-f437-4572-8ae4-058c49a4fe4a" />



#### 2. 图5（食草动物承载力堆积柱状图）
- 原图：<img width="693" height="913" alt="image" src="https://github.com/user-attachments/assets/7603bdb8-456f-48f6-a267-d0762e44b6f9" />


- 复现图：<img width="692" height="386" alt="image" src="https://github.com/user-attachments/assets/8063db73-41bc-4ef5-9f33-1ac0dfd57867" />


#### 3. 表1（MIS 3晚期冷暖期各生物地理区NPP数据）
- 原图：<img width="693" height="251" alt="image" src="https://github.com/user-attachments/assets/5b34c5d1-5d5a-4752-9bb1-b827e048df60" />


- 复现表：<img width="692" height="282" alt="image" src="https://github.com/user-attachments/assets/8dbd003f-0338-4eca-89e1-94ac6bc11056" />


#### 4. NPP箱线图
<img width="691" height="339" alt="image" src="https://github.com/user-attachments/assets/e41cff91-3b54-47c9-8ef5-b12f0baa3ac3" />


