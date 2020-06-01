library(tidyverse)
library(readxl)
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
         theme(plot.title = element_text(face = "bold", size = rel(0),
                                         color = 'white', hjust = 0.5),
               plot.subtitle = element_text(size = rel(0), color = 'white',
                                            hjust = 0.5),
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
               legend.position = "bottom",
               strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
               strip.text = element_text(face="bold"))
     )
}

# Params

country_subset <- c( 'United States', 'China', 'Brazil')
plot_width  <- 8
plot_height <- 5

### Import Data

setwd(dirname(rstudioapi::getSourceEditorContext()$path))
folder <- '../results/'

data_mm <- read_csv(paste(folder, 'csv/results_05302020_mm.csv', sep = ''))
data_pe <- read_csv(paste(folder, 'csv/results_05302020_pe.csv', sep = ''))
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

# Merge data
data_mm$Type <- 'Multimarket'
data_pe$Type <- 'Partial Equilibrium'
data_raw <- rbind(data_mm, data_pe)

# Clean data frame
data <- filter(data_raw, Country %in% country_subset,
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
                      type_selected, '_price_change.png'),
               width = plot_width, height = plot_height)

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
                      type_selected, '_quantity_change.png'),
               width = plot_width, height = plot_height)

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
           y = '% Difference in Producer Surplus from Baseline') +
        theme_custom()

    ggsave(paste0(folder, 'graphs/R/', 'All', '_',
                  type_selected, '_producer_surplus_change.png'),
           width = plot_width, height = plot_height)

    # Consumer Surplus  Change
    ggplot(data = filter(data_agg, Type == type_selected),
           aes(x = Year, y = Percent_Change_in_Consumer_Surplus)) +
        geom_line(aes(color = Country), size = 1.25) +
        scale_y_continuous(labels=scales::percent) +
        scale_x_continuous(breaks = seq(0,30,by=1)) +
        labs(title = paste('All Crops', type_selected, sep = ' - '),
             subtitle = '% Change in Consumer Surplus over Time',
             y = '% Difference in Consumer Surplus from Baseline') +
        theme_custom()

    ggsave(paste0(folder, 'graphs/R/', 'All', '_',
                  type_selected, '_consumer_surplus_change.png'),
           width = plot_width, height = plot_height)

}

## Find total change in calories for all countries

# Convert quantities in units of calories (1 MT = 1,000,000,000,000)
data$Calories_Original = 0

data[data$Crop == 'Corn', 'Calories_Original'] <-
    data[data$Crop == 'Corn', 'Quantity_Original']*(98/100)*(10e12)
data[data$Crop == 'Soybean', 'Calories_Original'] <-
    data[data$Crop == 'Soybean', 'Quantity_Original']*(147/100)*(10e12)

data$Calories_Produced <- (data$Calories_Original *
                               (1+data$Percent_Quantity_Change))

# Aggregate by country year type
data_agg <- data %>%
    group_by(Country, Year, Type) %>%
    summarize_at(vars(-Crop), sum)

# Compute percent change in calories
data_agg$Percent_Calorie_Change <- (data_agg$Calories_Produced
                                    /data_agg$Calories_Original) - 1

# For each type
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
                  type_selected, '_country_calorie_change.png'),
           width = plot_width, height = plot_height)


}

# For both types
ggplot(data = filter(data_agg),
       aes(x = Year, y = Percent_Calorie_Change,
           group = interaction(Country, Type))) +
    geom_line(aes(color = Country), size = 1) +
    geom_point(aes(shape = Type, color = Country), size = 2) +
    scale_y_continuous(labels=percent) +
    scale_x_continuous(breaks = seq(0,30,by=1)) +
    labs(title = paste('All Crops', type_selected, sep = ' - '),
         subtitle = '% Change in Calories over Time',
         y = '% Difference in Calories from Baseline') +
    theme_custom() +
    guides(color = guide_legend(title.position="top", title.hjust = 0.5),
           shape = guide_legend(title.position="top", title.hjust = 0.5))

ggsave(paste0(folder, 'graphs/R/', 'All', '_',
              'PEMM', '_country_calorie_change.png'),
       width = plot_width, height = plot_height)


# Aggregate across all countries and crops
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

ggsave(paste0(folder, 'graphs/R/', 'All_total_calorie_change.png'),
       width = 8, height = 4)

## Quantity changes with all shock types

# Get quantity in each period
data['Quantity'] <- data['Quantity_Original']*
    (1+data['Percent_Quantity_Change'])

# Aggregate across all countries
data_agg <- data %>%
    group_by(Year, Type, Crop) %>%
    summarize_at(vars(-Country), sum)

# Compute percent change in calories
data_agg$Percent_Quantity_Change <- (data_agg$Quantity
                                     /data_agg$Quantity_Original) - 1

# # Change in crop production for all countries, each crop, showing both types
# for (crop_selected in unique(data$Crop)) {
#
#     # Price Change
#     ggplot(data = filter(data_agg, Crop == crop_selected),
#            aes(x = Year, y = Percent_Quantity_Change)) +
#         geom_line(aes(color = Type), size = 1.25) +
#         scale_y_continuous(labels=percent) +
#         scale_x_continuous(breaks = seq(1,30,by=1)) +
#         scale_color_discrete(guide = guide_legend()) +
#         labs(title = paste(crop_selected, 'All Countries', sep = ' - '),
#              subtitle = 'Change in Price over Time',
#              y = '% Difference in Quantity from Baseline') +
#         theme_custom()
#
#
#     ggsave(paste0(folder, 'graphs/R/', crop_selected, '_',
#                   'all_countries_', 'quantity_change.png'),
#            width = plot_width, height = plot_height)
# }

# Merge data from all three models
data_alltypes <- rbind(
    data[,c('Type', 'Country', 'Crop', 'Year', 'Percent_Quantity_Change')],
    data_cm)
data_alltypes <- filter(data_alltypes, Country %in% country_subset,
                        Crop %in% c('Corn', 'Soybean'))

# Change in crop production for all countries, each crop, showing all types
for (crop_selected in unique(data$Crop)) {

    # Price Change
    ggplot(data = filter(data_alltypes, Crop == crop_selected),
           aes(x = Year, y = Percent_Quantity_Change,
               group = interaction(Country, Type))) +
        geom_line(aes(color = Country), size = 1) +
        geom_point(aes(shape = Type, color = Country), size = 2) +
        scale_y_continuous(labels = percent) +
        scale_x_continuous(breaks = seq(1,30,by=1)) +
        #scale_linetype_manual(values = c(rep('solid'), rep('longdash'), rep('dotted')))
        labs(title = paste(crop_selected, type_selected, sep = ' - '),
             subtitle = 'Change in Quantity over Time',
             y = '% Difference in Quantity from Baseline') +
        theme_custom() +
        guides(color = guide_legend(title.position="top", title.hjust = 0.5),
               shape = guide_legend(title.position="top", title.hjust = 0.5))


    ggsave(paste0(folder, 'graphs/R/', crop_selected, '_all_countries_',
                  'quantity_change.png'),
           width = plot_width, height = plot_height)

}
