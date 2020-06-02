library(tidyverse)
library(readxl)
library(ggplot2)
library(scales)
library(grid)
library(ggthemes)
library(lemon)
library(RColorBrewer)


################################################################################
### Functions

capitalize <- function(s) {
    paste(toupper(substring(s, 1, 1)), substring(s, 2), sep = "")
}

theme_custom <- function() {
    (theme_foundation(base_size=12) +
         theme(plot.title = element_text(face = "bold",  hjust = 0.5),
               plot.subtitle = element_text(hjust = 0.5),
               text = element_text(),
               panel.background = element_rect(color = NA),
               plot.background = element_rect(color = NA),
               panel.border = element_rect(color = NA),
               axis.title = element_text(face = "bold", size = rel(1)),
               axis.title.y = element_text(angle = 90, vjust = 2),
               axis.title.x = element_text(vjust = -0.2),
               axis.text = element_text(),
               axis.line = element_line(color="black"),
               axis.ticks = element_line(),
               panel.grid.major = element_line(color="#f0f0f0"),
               panel.grid.minor = element_blank(),
               legend.key = element_rect(color = NA),
               legend.title = element_text(face="italic"),
               legend.position = "bottom",
               strip.background = element_rect(color="#f0f0f0",fill="#f0f0f0"),
               strip.text = element_text(face="bold"))
     )
}

# Params
country_subset <- c( 'United States', 'China', 'Brazil')


################################################################################
### Import Data

setwd(dirname(rstudioapi::getSourceEditorContext()$path))
folder <- '../results/'

# Load partial equilibrium data for each scenario
data_pe_ld <- read_csv(paste(folder, 'csv/results_BCUS_pe_ld.csv',
                             sep = ''))
data_pe_ud <- read_csv(paste(folder, 'csv/results_BCUS_pe_ud.csv',
                             sep = ''))
data_pe_ls <- read_csv(paste(folder, 'csv/results_BCUS_pe_ls.csv',
                             sep = ''))
data_pe_us <- read_csv(paste(folder, 'csv/results_BCUS_pe_us.csv',
                             sep = ''))
data_pe_cd <- read_csv(paste(folder, 'csv/results_BCUS_pe_cd.csv',
                             sep = ''))
data_pe_cs <- read_csv(paste(folder, 'csv/results_BCUS_pe_cs.csv',
                             sep = ''))
data_pe_baseline <- read_csv(paste(folder, 'csv/results_BCUS_pe_baseline.csv',
                             sep = ''))

# Merge pe data
data_pe <- rbind(data_pe_ld %>% mutate(Scenario = 'Demand Elasticity -20%'),
      data_pe_ud %>% mutate(Scenario = 'Demand Elasticity +20%'),
      data_pe_ls %>% mutate(Scenario = 'Supply Elasticity -20%'),
      data_pe_us %>% mutate(Scenario = 'Supply Elasticity +20%'),
      data_pe_cd %>% mutate(Scenario = 'With Cross Demand Elasticities'),
      data_pe_cs %>% mutate(Scenario = 'With Cross Supply Elasticities'),
      data_pe_baseline %>% mutate(Scenario = 'Baseline'))
data_pe$Type <- 'Partial Equilibrium'
data_pe <- data_pe %>% mutate(isBaseline = as.numeric('Baseline' == Scenario))

# Load crop model data
data_cm <- rbind(
    read_excel('../crop_data/xlsx_data/B_C_US_shocks_c_s.xlsx', sheet = 1)
    %>% mutate(Crop = 'Corn'),
    read_excel('../crop_data/xlsx_data/B_C_US_shocks_c_s.xlsx', sheet = 2)
    %>% mutate(Crop = 'Soybean'))

# Clean up cm data
data_cm[2] <- NULL
data_cm <- gather(data_cm, colnames(data_cm)[2:16], key = 'Year',
                  value = 'Percent_Quantity_Change')
colnames(data_cm)[1] <- 'Country'
data_cm['Type'] <- 'Crop Model'
data_cm <- data_cm %>% mutate(Year = as.numeric(Year))

# Clean data frame
data <- filter(data_pe, Country %in% country_subset,
               Crop %in% c('corn', 'soybean'))
data <- data %>% mutate(Crop = capitalize(Crop))


################################################################################
### Graphs

## Graph Params

# Plot save settings
plot_width  <- 8
plot_height <- 5

# Colors
scenario_colors <- brewer.pal(length(unique(data$Scenario)), "Set1")
names(scenario_colors) <- levels(factor(unique(data$Scenario)))
scenario_colors[1] <- '#000000'

# Plot theme
plot_settings <- list(geom_line(),
                      geom_point(stroke = 0.9),
                      scale_colour_manual(name = "grp",
                                          values = scenario_colors),
                      scale_alpha(range = c(0.6, 0.9)),
                      scale_size(range = c(0.5, 1)),
                      scale_y_continuous(labels =
                                             scales::percent_format(accuracy = 1L)),
                      scale_x_continuous(breaks = seq(0,30,by=1)),
                      theme_custom(),
                      theme(legend.text = element_text(size = 8),
                            legend.box = 'vertical',
                            legend.key.width = unit(1.1,"cm"),
                            legend.spacing.y = unit(0.1, "cm")),
                      facet_grid(Country ~ .),
                      guides(alpha = FALSE, size = FALSE,
                             color = guide_legend(title.position="top",
                                                  title.hjust = 0.5,
                                                  title = 'Scenario',
                                                  override.aes =
                                                      list(size = 1.5))),
                      annotate("segment", x=-Inf, xend=Inf, y=-Inf, yend=-Inf),
                      annotate("segment", x=-Inf, xend=-Inf, y=-Inf, yend=Inf)
)


## Price and Surplus Graphs

# Crop aggregate
data_agg <- data %>%
    group_by(Country, Year, Type, Scenario) %>%
    summarize_at(vars(-Crop), sum)

# Recompute percent change in surplus
data_agg$Percent_Change_in_Consumer_Surplus <-
    data_agg$Change_in_Consumer_Surplus / data_agg$Consumer_Surplus_Original
data_agg$Percent_Change_in_Producer_Surplus <-
    data_agg$Change_in_Producer_Surplus / data_agg$Producer_Surplus_Original

# Producer Surplus All Crops
ggplot(data = filter(data_agg),
       aes(x = Year, y = Percent_Change_in_Producer_Surplus,
           group = interaction(Country, Scenario),
           color = Scenario, alpha = isBaseline, size = isBaseline))  +
    plot_settings +
    labs(title = paste('All Crops', 'Partial Equilibrium', sep = ' - '),
         subtitle = '% Change in Producer Surplus over Time',
         y = '% Difference in Producer Surplus from Baseline')

ggsave(paste0(folder, 'graphs/R/', 'AllCrops_Producer_surplus_change.png'),
       width = plot_width*1.1, height = plot_height*1.1)

# Producer Surplus by Crop
ggplot(data = filter(data),
       aes(x = Year, y = Percent_Change_in_Producer_Surplus,
           color = Scenario, alpha = isBaseline, size = isBaseline)) +
    plot_settings +
    labs(title = paste('Partial Equilibrium', sep = ' - '),
         subtitle = '% Change in Producer Surplus over Time',
         y = '% Difference in Producer Surplus from Baseline') +
    facet_grid(Country ~ Crop)

ggsave(paste0(folder, 'graphs/R/', 'ByCrop_Producer_surplus_change.png'),
       width = plot_width*1.1, height = plot_height*1.1)

# Consumer Surplus All Crops
ggplot(data = filter(data_agg),
       aes(x = Year, y = Percent_Change_in_Consumer_Surplus,
           group = interaction(Country, Scenario),
           color = Scenario, alpha = isBaseline, size = isBaseline))  +
    plot_settings +
    labs(title = paste('All Crops', 'Partial Equilibrium', sep = ' - '),
         subtitle = '% Change in Consumer Surplus over Time',
         y = '% Difference in Consumer Surplus from Baseline')

ggsave(paste0(folder, 'graphs/R/', 'AllCrops_Consumer_surplus_change.png'),
       width = plot_width*1.1, height = plot_height*1.1)

# Consumer Surplus by Crop
ggplot(data = filter(data),
       aes(x = Year, y = Percent_Change_in_Consumer_Surplus,
           color = Scenario, alpha = isBaseline, size = isBaseline)) +
    plot_settings +
    labs(title = paste('Partial Equilibrium', sep = ' - '),
         subtitle = '% Change in Consumer Surplus over Time',
         y = '% Difference in Consumer Surplus from Baseline') +
    facet_grid(Country ~ Crop)

ggsave(paste0(folder, 'graphs/R/', 'ByCrop_Consumer_surplus_change.png'),
       width = plot_width*1.1, height = plot_height*1.1)

# Price Change by Crop
ggplot(data = filter(data),
       aes(x = Year, y = Percent_Price_Change,
           color = Scenario, alpha = isBaseline, size = isBaseline)) +
    plot_settings +
    labs(title = paste('Partial Equilibrium', sep = ' - '),
         subtitle = '% Change in Price over Time',
         y = '% Difference in Price from Baseline') +
    facet_grid(Country ~ Crop)

ggsave(paste0(folder, 'graphs/R/', 'ByCrop_Price_change.png'),
       width = plot_width*1.1, height = plot_height*1.1)


## Quantity Graph

# Merge pe and cm data
data_cm$Scenario <- 'Baseline'
data_cm$isBaseline <- 0
data_merge <- rbind(
    data[,c('Type', 'Country', 'Crop', 'Year', 'isBaseline',
            'Percent_Quantity_Change', 'Scenario')],
    data_cm)
data_merge <- filter(data_merge, Country %in% country_subset,
                        Crop %in% c('Corn', 'Soybean'))

# Quantity Change by Crop
ggplot(data = filter(data_merge),
       aes(x = Year, y = Percent_Quantity_Change,
           color = Scenario, alpha = isBaseline, size = isBaseline,
           linetype = Type)) +
    scale_linetype_manual(values = c(2,1)) +
    plot_settings +
    labs(title = paste('All Models', sep = ' - '),
         subtitle = '% Change in Quantity over Time',
         y = '% Difference in Quantity from Baseline') +
    facet_grid(Country ~ Crop) +
    guides(linetype = guide_legend(title.position="top", title.hjust = 0.5,
                                title = 'Model',
                                override.aes = list(size = 1, width = 10)))

ggsave(paste0(folder, 'graphs/R/', 'ByCrop_Quantity_change.png'),
       width = plot_width*1.1, height = plot_height*1.1)


## Calorie Change Graph

# Convert quantities in units of calories (1 MT = 1,000,000,000,000)
data$Calories_Original = 0

data[data$Crop == 'Corn', 'Calories_Original'] <-
    data[data$Crop == 'Corn', 'Quantity_Original']*(98/100)*(10e12)
data[data$Crop == 'Soybean', 'Calories_Original'] <-
    data[data$Crop == 'Soybean', 'Quantity_Original']*(147/100)*(10e12)

# Add "Calories Original" to data_cm
data_cm_cal <- left_join(data_cm,
                         data[c('Country', 'Crop', 'Calories_Original')],
                         by = c('Country', 'Crop'))

# Merge pe and cm data
data_cm$Scenario <- 'Baseline'
data_cm$isBaseline <- 0
data_merge_cal <- rbind(
    data[,c('Type', 'Country', 'Crop', 'Year', 'isBaseline',
            'Calories_Original', 'Percent_Quantity_Change', 'Scenario')],
    data_cm_cal) %>%
    filter(Country %in% country_subset,
           Crop %in% c('Corn', 'Soybean'))

data_merge_cal$Calories_Produced <- (
    data_merge_cal$Calories_Original *
        (1+data_merge_cal$Percent_Quantity_Change))

# Aggregate crops
data_merge_cal_agg <- data_merge_cal %>%
    group_by(Country, Year, Type, Scenario) %>%
    summarize_at(vars(-Crop), sum)

# Compute percent change in calories
data_merge_cal_agg$Percent_Calorie_Change <- (
    data_merge_cal_agg$Calories_Produced
    /data_merge_cal_agg$Calories_Original) - 1

# Calorie Change by Country
ggplot(data = filter(data_merge_cal_agg),
       aes(x = Year, y = Percent_Calorie_Change,
           color = Scenario, alpha = isBaseline, size = isBaseline,
           linetype = Type)) +
    scale_linetype_manual(values = c(2,1)) +
    plot_settings +
    labs(title = paste('All Models', sep = ' - '),
         subtitle = '% Change in Calories over Time',
         y = '% Difference in Calories from Baseline') +
    facet_grid(Country ~ .) +
    guides(linetype = guide_legend(title.position="top", title.hjust = 0.5,
                                   title = 'Model',
                                   override.aes = list(size = 1, width = 10)))

ggsave(paste0(folder, 'graphs/R/', 'ByCountry_Calorie_change.png'),
       width = plot_width*1.1, height = plot_height*1.1)

# Aggregate countries and crops
data_merge_cal_agg_country <- data_merge_cal %>%
    group_by(Year, Type, Scenario) %>%
    summarize_at(vars(-c(Crop,Country)), sum)

# Compute percent change in calories
data_merge_cal_agg_country$Percent_Calorie_Change <- (
    data_merge_cal_agg_country$Calories_Produced
    /data_merge_cal_agg_country$Calories_Original) - 1

# Calorie Change All Countries
ggplot(data = filter(data_merge_cal_agg_country),
       aes(x = Year, y = Percent_Calorie_Change,
           color = Scenario, alpha = isBaseline, size = isBaseline,
           linetype = Type)) +
    scale_linetype_manual(values = c(2,1)) +
    plot_settings +
    labs(title = paste('All Models', sep = ' - '),
         subtitle = '% Change in Calories over Time',
         y = '% Difference in Calories from Baseline') +
    facet_grid() +
    guides(linetype = guide_legend(title.position="top", title.hjust = 0.5,
                                   title = 'Model',
                                   override.aes = list(size = 1, width = 10)))

ggsave(paste0(folder, 'graphs/R/', 'All_Calorie_change.png'),
       width = plot_width*1.1, height = plot_height*1)
