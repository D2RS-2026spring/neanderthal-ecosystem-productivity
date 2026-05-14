# ============================================================
# 02_reproduce_table1.R
# 目的：复现论文 Table 1
# 内容：比较四个生物地理区在 Stadial / Interstadial 阶段的 NPP
# ============================================================

# 1. 清空环境
rm(list = ls())

# 2. 加载 R 包
library(readxl)
library(tidyverse)

# 3. 设置文件路径
npp_file <- "data/raw/Dataset-NPP.xlsx"

# 4. 检查文件是否存在
if (!file.exists(npp_file)) {
  stop("找不到 Dataset-NPP.xlsx。请确认文件放在 data/raw/Dataset-NPP.xlsx")
}

# 5. 查看 Excel 里面有哪些 sheet
sheets <- excel_sheets(npp_file)
print(sheets)

# 6. 读取 NPP_Regions 这个 sheet
npp_raw <- read_excel(npp_file, sheet = "NPP_Regions")

# 7. 查看前几行，确认数据读入成功
print(head(npp_raw))
print(names(npp_raw))

# 8. 整理数据
npp_long <- npp_raw %>%
  filter(!is.na(Phase)) %>%
  select(
    Age,
    Phase,
    starts_with("NPP_")
  ) %>%
  pivot_longer(
    cols = starts_with("NPP_"),
    names_to = "Region",
    values_to = "NPP"
  ) %>%
  mutate(
    Region = str_remove(Region, "^NPP_"),

    Region = recode(
      Region,
      "Submediterranean" = "Supramediterranean"
    ),

    Period = case_when(
      str_detect(Phase, "^GS") ~ "Stadial",
      str_detect(Phase, "^GI") ~ "Interstadial",
      TRUE ~ NA_character_
    ),

    Region = factor(
      Region,
      levels = c(
        "Eurosiberian",
        "Supramediterranean",
        "Mesomediterranean",
        "Thermomediterranean"
      )
    ),

    Period = factor(
      Period,
      levels = c("Stadial", "Interstadial")
    )
  ) %>%
  filter(!is.na(Period), !is.na(NPP))

# 9. 检查整理后的数据
print(head(npp_long))
print(table(npp_long$Region, npp_long$Period))

# 10. 定义变异系数函数
cv <- function(x) {
  100 * sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)
}

# 11. 计算每个地区、每个时期的统计量
table1_summary <- npp_long %>%
  group_by(Region, Period) %>%
  summarise(
    Mean = mean(NPP, na.rm = TRUE),
    sd = sd(NPP, na.rm = TRUE),
    Coefficient_of_variation = cv(NPP),
    .groups = "drop"
  )

# 12. 对每个地区做 Wilcoxon rank-sum test
# 为了和论文 Table 1 的 W 值一致，这里把 Interstadial 放在第一组
wilcox_results <- npp_long %>%
  group_by(Region) %>%
  summarise(
    W = as.numeric(
      wilcox.test(
        x = NPP[Period == "Interstadial"],
        y = NPP[Period == "Stadial"]
      )$statistic
    ),
    P = wilcox.test(
      x = NPP[Period == "Interstadial"],
      y = NPP[Period == "Stadial"]
    )$p.value,
    .groups = "drop"
  )
 


# 13. 合并统计结果
table1_final <- table1_summary %>%
  left_join(wilcox_results, by = "Region") %>%
  arrange(Region, Period) %>%
  mutate(
    W = if_else(Period == "Stadial", W, NA_real_),
    P = if_else(Period == "Stadial", P, NA_real_),

    Mean = round(Mean, 3),
    sd = round(sd, 3),
    Coefficient_of_variation = round(Coefficient_of_variation, 2),
    W = round(W, 0),
    P = signif(P, 3)
  )

# 14. 打印最终表格
print(table1_final)

# 15. 保存表格
write_csv(
  table1_final,
  "output/tables/table1_reproduction.csv"
)

# 16. 画辅助箱线图
table1_plot <- ggplot(
  npp_long,
  aes(x = Region, y = NPP, fill = Period)
) +
  geom_boxplot(
    position = position_dodge(width = 0.8),
    width = 0.65,
    outlier.size = 1.5
  ) +
  labs(
    title = "NPP by biogeographical region and climatic period",
    subtitle = "Reproduction based on Dataset-NPP.xlsx",
    x = "Biogeographical region",
    y = expression("NPP (kg km"^-2*" yr"^-1*")"),
    fill = "Period"
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 20, hjust = 1),
    legend.position = "top"
  )

print(table1_plot)

# 17. 保存图片
ggsave(
  filename = "output/figures/table1_npp_boxplot.png",
  plot = table1_plot,
  width = 9,
  height = 5,
  dpi = 300
)

# 18. 完成提示
cat("\n完成：Table 1 已保存到 output/tables/table1_reproduction.csv\n")
cat("完成：辅助图已保存到 output/figures/table1_npp_boxplot.png\n")
