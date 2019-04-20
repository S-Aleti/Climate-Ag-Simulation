library(tidyverse)
library(ggplot2)
library(scales)
library(grid)
library(ggthemes)

### Functions

capitalize <- function(s) {
    paste(toupper(substring(s, 1, 1)), substring(s, 2), sep = "")
}

theme_custom <- function() {
    (theme_foundation(base_size=12) +
         theme(plot.title = element_text(face = "bold",
                                         size = rel(1.2), hjust = 0.5),
               plot.subtitle = element_text(size = rel(1.2), hjust = 0.5),
               text = element_text(),
               panel.background = element_rect(colour = NA),
               plot.background = element_rect(colour = NA),
               panel.border = element_rect(colour = NA),
               axis.title = element_text(face = "bold",size = rel(1)),
               axis.title.y = element_text(angle=90,vjust =2),
               axis.title.x = element_text(vjust = -0.2),
               axis.text = element_text(),
               axis.line = element_line(colour="black"),
               axis.ticks = element_line(),
               panel.grid.major = element_line(colour="#f0f0f0"),
               panel.grid.minor = element_blank(),
               legend.key = element_rect(colour = NA),
               legend.title = element_text(face="italic"),
               strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
               strip.text = element_text(face="bold"))
     )
}

### Import Data

setwd(dirname(rstudioapi::getSourceEditorContext()$path))
folder <- '../results/'

data_mm <- read_csv(paste(folder, 'csv/results_CLM5_mm.csv', sep = ''))
data_pe <- read_csv(paste(folder, 'csv/results_CLM5_pe.csv', sep = ''))

# Merge data
data_mm$Type <- 'Multimarket'
data_pe$Type <- 'Partial Equilibrium'
data_raw <- rbind(data_mm, data_pe)

# Clean data frame
data <- filter(data_raw, Country %in%
                  c('India', 'United States', 'China', 'Brazil'),
               Crop %in% c('corn', 'soybean'))
data <- data %>%
        mutate(Crop = capitalize(Crop))

### Graphs

for (crop_selected in unique(data$Crop)) {
    for (type_selected in unique(data$Type)) {

        # Price Change
        ggplot(data = filter(data, Crop == crop_selected,
                             Type == type_selected),
               aes(x = Year, y = Percent_Price_Change)) +
            geom_line(aes(color = Country), size = 1.25) +
            scale_y_continuous(labels=percent) +
            scale_x_continuous(breaks = seq(1,30,by=1)) +
            labs(title = paste(crop_selected, type_selected, sep = ' - '),
               subtitle = 'Change in Price over Time',
               y = '% Difference in Price from Baseline') +
            theme_custom()


        ggsave(paste0(folder, 'graphs/R/', crop_selected, '_',
                      type_selected, 'price_change.png'))

        # Quantity Change
        ggplot(data = filter(data, Crop == crop_selected, Type == type_selected),
               aes(x = Year, y = Percent_Quantity_Change)) +
            geom_line(aes(color = Country), size = 1.25) +
            scale_y_continuous(labels=percent, breaks = seq(-0.5,1,by = .05)) +
            scale_x_continuous(breaks = seq(1,30,by=1)) +
            labs(title = paste(crop_selected, type_selected, sep = ' - '),
                 subtitle = '% Change in Quantity over Time',
                 y = '% Change in Quantity from Baseline') +
            theme_custom()

        ggsave(paste0(folder, 'graphs/R/', crop_selected, '_',
                      type_selected, '_quantity_change.png'))

    }
}

## Aggregate Graphs

# Aggregate
data_agg <- data %>%
    group_by(Country, Year, Type) %>%
    summarize_at(vars(-Crop), sum)

# Recompute percent change in surplus
data_agg$Percent_Change_in_Consumer_Surplus <-
    data_agg$Change_in_Consumer_Surplus / data_agg$Consumer_Surplus_Original
data_agg$Percent_Change_in_Producer_Surplus <-
    data_agg$Change_in_Producer_Surplus / data_agg$Producer_Surplus_Original

for (type_selected in unique(data_agg$Type)) {

    # Producer Surplus  Change
    ggplot(data = filter(data_agg, Type == type_selected),
           aes(x = Year, y = Percent_Change_in_Producer_Surplus)) +
        geom_line(aes(color = Country), size = 1.25) +
        scale_y_continuous(labels=percent) +
        scale_x_continuous(breaks = seq(0,30,by=1)) +
        labs(title = paste('All Crops', type_selected, sep = ' - '),
           subtitle = '% Change in Producer Surplus over Time',
           y = '% Difference in Surplus from Baseline') +
        theme_custom()

    ggsave(paste0(folder, 'graphs/R/', 'All', '_',
                  type_selected, '_prod_surplus_change.png'))

    # Consumer Surplus  Change
    ggplot(data = filter(data_agg, Type == type_selected),
           aes(x = Year, y = Percent_Change_in_Consumer_Surplus)) +
        geom_line(aes(color = Country), size = 1.25) +
        scale_y_continuous(labels=scales::percent) +
        scale_x_continuous(breaks = seq(0,30,by=1)) +
        labs(title = paste('All Crops', type_selected, sep = ' - '),
             subtitle = '% Change in Consumer Surplus over Time',
             y = '% Difference in Surplus from Baseline') +
        theme_custom()

    ggsave(paste0(folder, 'graphs/R/', 'All', '_',
                  type_selected, '_prod_Consumer_change.png'))

}

## Find total change in calories for all countries
data <- data_raw

# Convert quantities in units of calories (1 MT = 1,000,000,000,000)
data$Calories_Original = 0

data[data$Crop == 'corn', 'Calories_Original'] <-
    data[data$Crop == 'corn', 'Quantity_Original']*(98/100)*(10e12)
data[data$Crop == 'soybean', 'Calories_Original'] <-
    data[data$Crop == 'soybean', 'Quantity_Original']*(147/100)*(10e12)

data$Calories_Produced <- (data$Calories_Original *
                               (1+data$Percent_Quantity_Change))

# Aggregate for our four countries
data_agg <- data %>%
    group_by(Country, Year, Type) %>%
    summarize_at(vars(-Crop), sum) %>%
    filter(Country %in% c('India', 'United States', 'China', 'Brazil'))

# Compute percent change in calories
data_agg$Percent_Calorie_Change <- (data_agg$Calories_Produced
                                    /data_agg$Calories_Original) - 1


for (type_selected in unique(data_agg$Type)) {

    # Change in calories
    ggplot(data = filter(data_agg, Type == type_selected),
           aes(x = Year, y = Percent_Calorie_Change)) +
        geom_line(aes(color = Country), size = 1.25) +
        scale_y_continuous(labels=percent) +
        scale_x_continuous(breaks = seq(0,30,by=1)) +
        labs(title = paste('All Crops', type_selected, sep = ' - '),
             subtitle = '% Change in Calories over Time',
             y = '% Difference in Calories from Baseline') +
        theme_custom()

    ggsave(paste0(folder, 'graphs/R/', 'All', '_',
                  type_selected, '_country_calorie_change.png'))


}

# Aggregate
data_agg <- data %>%
    group_by(Year, Type) %>%
    summarize_at(vars(-Crop, -Country), sum)

# Compute percent change in calories
data_agg$Percent_Calorie_Change <- (data_agg$Calories_Produced
                                    /data_agg$Calories_Original) - 1


# Change in calories for all countries, showing both types
ggplot(data = filter(data_agg),
       aes(x = Year, y = Percent_Calorie_Change, color = Type)) +
    geom_line(size = 1.25) +
    scale_y_continuous(labels=percent) +
    scale_x_continuous(breaks = seq(0,30,by=1)) +
    labs(title = paste('All Crops', type_selected, sep = ' - '),
         subtitle = '% Change in Calories over Time',
         y = '% Difference in Calories from Baseline') +
    theme_custom()

ggsave(paste0(folder, 'graphs/R/', 'All_total_calorie_change.png'))



