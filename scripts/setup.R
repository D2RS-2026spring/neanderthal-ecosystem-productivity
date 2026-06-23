# setup.R — 共享函数定义（供 QMD 调用）
# 此文件不应包含 rm(list=ls())

library(readxl)
library(tidyverse)
library(dplyr)
library(tidyr)
library(ggplot2)
library(openxlsx)
library(gridExtra)
library(robustbase)
library(rstatix)

# 变异系数
co.var <- function(x) 100 * (sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE))

# NPP 转换为 log10(g/m^2/y)
log_transform_NPP <- function(x) {
  log10(as.numeric(x) * 1000)
}

# 从 NPP 估算食草动物生物量的回归模型
Dataset <- read.xlsx("data/raw/HB_ValidationDataset.xlsx", rowNames = FALSE,
                     colNames = TRUE, sheet = "NPP_HB")
model <- lmrob(logHB ~ logNPP, data = Dataset)

# 预测函数
Bpc.mean <- function(NPP) {
  Value <- data.frame(logNPP = NPP)
  10^(predict(model, newdata = Value, interval = "confidence")[, "fit"])
}
Bpc.max <- function(NPP) {
  Value <- data.frame(logNPP = NPP)
  10^(predict(model, newdata = Value, interval = "confidence")[, "upr"])
}
Bpc.min <- function(NPP) {
  Value <- data.frame(logNPP = NPP)
  10^(predict(model, newdata = Value, interval = "confidence")[, "lwr"])
}

# 估算种群密度
Estimate_Population_Density <- function(x) {
  NPP <- log_transform_NPP(sprintf("%.4f", Summary_NPP$NPP[, 1][Summary_NPP$Phase == x]))
  Mean.Biomass <- Bpc.mean(NPP)
  Min.Biomass <- Bpc.min(NPP)
  Max.Biomass <- Bpc.max(NPP)
  Fauna_BodyMass.df <- as.data.frame(Fauna_BodyMass)
  Dens.mean <- (Mean.Biomass / sum(Fauna_BodyMass.df^0.25)) * Fauna_BodyMass.df^-0.75
  Dens.min <- (Min.Biomass / sum(Fauna_BodyMass.df^0.25)) * Fauna_BodyMass.df^-0.75
  Dens.max <- (Max.Biomass / sum(Fauna_BodyMass.df^0.25)) * Fauna_BodyMass.df^-0.75
  Herbivore_Density <- as.data.frame(t(rbind(Dens.mean[, 1], Dens.min[, 1], Dens.max[, 1])))
  names(Herbivore_Density) <- c("Mean", "Min", "Max")
  Herbivore_Density$Species <- Species_List
  Herbivore_Density$BM <- Fauna_BodyMass
  Herbivore_Density$SC <- SizeCategory
  Herbivore_Density$Phase <- x
  Herbivore_Density
}

# 按体型估算生物量
Estimate_Biomass_Per_Size_Category <- function(x) {
  df <- as.data.frame(x)
  result <- data.frame(
    Biomass_SmallSize_Herbivores_Mean = sum(subset(df, SC == "S")$BM * subset(df, SC == "S")$Mean),
    Biomass_SmallSize_Herbivores_Min = sum(subset(df, SC == "S")$BM * subset(df, SC == "S")$Min),
    Biomass_SmallSize_Herbivores_Max = sum(subset(df, SC == "S")$BM * subset(df, SC == "S")$Max),
    Biomass_MediumSize_Herbivores_Mean = sum(subset(df, SC == "M")$BM * subset(df, SC == "M")$Mean),
    Biomass_MediumSize_Herbivores_Min = sum(subset(df, SC == "M")$BM * subset(df, SC == "M")$Min),
    Biomass_MediumSize_Herbivores_Max = sum(subset(df, SC == "M")$BM * subset(df, SC == "M")$Max),
    Biomass_MediumLarge_Herbivores_Mean = sum(subset(df, SC == "ML")$BM * subset(df, SC == "ML")$Mean),
    Biomass_MediumLarge_Herbivores_Min = sum(subset(df, SC == "ML")$BM * subset(df, SC == "ML")$Min),
    Biomass_MediumLarge_Herbivores_Max = sum(subset(df, SC == "ML")$BM * subset(df, SC == "ML")$Max),
    Biomass_Large_Herbivores_Mean = sum(subset(df, SC == "L")$BM * subset(df, SC == "L")$Mean),
    Biomass_Large_Herbivores_Min = sum(subset(df, SC == "L")$BM * subset(df, SC == "L")$Min),
    Biomass_Large_Herbivores_Max = sum(subset(df, SC == "L")$BM * subset(df, SC == "L")$Max)
  )
  result$Phase <- Phase_Stadial_Interstadial
  result
}

# 辅助函数：处理单个区域
process_region <- function(npp_sheet, fauna_sheet, fauna_periods) {
  NPP_data <- read.xlsx("data/raw/Dataset-NPP.xlsx", rowNames = FALSE,
                        colNames = TRUE, sheet = npp_sheet)
  # 按单个Phase聚合（GI-13, GS-13等），用于 Estimate_Population_Density 查找
  Summary_NPP <- aggregate(NPP ~ Phase, data = NPP_data,
                           function(x) c(mean = mean(x), sd = sd(x)))
  Summary_NPP <<- Summary_NPP

  Fauna <- read.xlsx("data/raw/Herbivore.Species.xlsx", rowNames = FALSE,
                     colNames = TRUE, sheet = fauna_sheet)

  dens_list <- list()
  biomass_list <- list()

  for (p in fauna_periods) {
    period_name <- p$period
    Fauna_BodyMass <<- na.omit(Fauna[[p$bm_col]])
    Species_List <<- na.omit(Fauna[[p$species_col]])
    SizeCategory <<- na.omit(Fauna[[p$sc_col]])
    Phase_Stadial_Interstadial <<- period_name

    Density <- Estimate_Population_Density(period_name)
    Biomass <- Estimate_Biomass_Per_Size_Category(Density)
    Biomass$SI <- ifelse(grepl("^GI", period_name), "Interstadial", "Stadial")
    dens_list[[period_name]] <- Density
    biomass_list[[period_name]] <- Biomass
  }

  Dens <- do.call(rbind, dens_list)
  Biomass <- do.call(rbind, biomass_list)

  list(dens = Dens, biomass = Biomass, npp = NPP_data, summary_npp = Summary_NPP)
}
