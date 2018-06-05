library(tidyverse)
library(ggplot2)
library(scales)

folder <- '~/GitHub/Climate-Ag-Simulation/results/'

data_mm <- read_csv(paste(folder, 'csv/results_multimarket.csv', sep = ''))
data_pe <- read_csv(paste(folder, 'csv/results_partialeq.csv', sep = ''))

data_mm <- filter(data_mm, Country %in% 
                    c('India', 'United States', 'China', 'Brazil'))
data_pe <- filter(data_pe, Country %in% 
                    c('India', 'United States', 'China', 'Brazil'))

### Corn

crop_selected <- 'corn'

## Price Change

# Multimarket
ggplot(data = filter(data_mm, Crop == crop_selected), 
       aes(x = Year, y = Percent_Price_Change)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-0.5,1,by = .25)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Corn - Multimarket', subtitle = '% Change in Price over Time',
       y = '% Change in Price')


ggsave(paste0(folder, 'graphs/R/', crop_selected, '_price_change.png'))

# Partial Eq
ggplot(data = filter(data_pe, Crop == crop_selected), 
       aes(x = Year, y = Percent_Price_Change)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-0.5,1,by = .25)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Corn - Partial Eq', subtitle = '% Change in Price over Time',
       y = '% Change in Price')  

ggsave(paste0(folder, 'graphs/R/', crop_selected, '_price_change.png'))

## Quantity Change

# Multimarket
ggplot(data = filter(data_mm, Crop == crop_selected), 
       aes(x = Year, y = Percent_Quantity_Change)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-0.5,1,by = .02)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Corn - Multimarket', subtitle = '% Change in Quantity over Time',
       y = '% Change in Quantity')

ggsave(paste0(folder, 'graphs/R/', crop_selected, '_quantity_change.png'))

# Partial Eq
ggplot(data = filter(data_pe, Crop == crop_selected), 
       aes(x = Year, y = Percent_Quantity_Change)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-0.5,1,by = .02)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Corn - Partial Eq', subtitle = '% Change in Quantity over Time',
       y = '% Change in Quantity')

ggsave(paste0(folder, 'graphs/R/', crop_selected, '_quantity_change.png'))

## Producer Surplus  Change

# Multimarket
ggplot(data = filter(data_mm, Crop == crop_selected), 
       aes(x = Year, y = Percent_Change_in_Producer_Surplus)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-1,1,by = .25)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Corn - Multimarket', 
       subtitle = '% Change in Producer Surplus over Time',
       y = '% Change in Surplus')

ggsave(paste0(folder, 'graphs/R/', crop_selected, '_prod_surplus_change.png'))

# Partial Eq
ggplot(data = filter(data_pe, Crop == crop_selected), 
       aes(x = Year, y = Percent_Change_in_Producer_Surplus)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-0.5,1,by = .1)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Corn - Partial Eq', 
       subtitle = '% Change in Producer Surplus over Time',
       y = '% Change in Surplus')

ggsave(paste0(folder, 'graphs/R/', crop_selected, '_prod_surplus_change.png'))

## Consumer Surplus  Change

# Multimarket
ggplot(data = filter(data_mm, Crop == crop_selected), 
       aes(x = Year, y = Percent_Change_in_Consumer_Surplus)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-1,1,by = .25)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Corn - Multimarket', 
       subtitle = '% Change in Consumer Surplus over Time',
       y = '% Change in Surplus')

ggsave(paste0(folder, 'graphs/R/', crop_selected, '_cons_surplus_change.png'))

# Partial Eq
ggplot(data = filter(data_pe, Crop == crop_selected), 
       aes(x = Year, y = Percent_Change_in_Consumer_Surplus)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-1,1,by = .25)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Corn - Partial Eq', 
       subtitle = '% Change in Consumer Surplus over Time',
       y = '% Change in Surplus')

ggsave(paste0(folder, 'graphs/R/', crop_selected, '_cons_surplus_change.png'))


### Soybean

crop_selected <- 'soybean'

## Price Change

# Multimarket
ggplot(data = filter(data_mm, Crop == crop_selected), 
       aes(x = Year, y = Percent_Price_Change)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-1,1,by = .25)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Soybean - Multimarket', subtitle = '% Change in Price over Time',
       y = '% Change in Price')


ggsave(paste0(folder, 'graphs/R/', crop_selected, '_price_change.png'))

# Partial Eq
ggplot(data = filter(data_pe, Crop == crop_selected), 
       aes(x = Year, y = Percent_Price_Change)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-1,1,by = .25)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Soybean - Partial Eq', subtitle = '% Change in Price over Time',
       y = '% Change in Price')  

ggsave(paste0(folder, 'graphs/R/', crop_selected, '_price_change.png'))

## Quantity Change

# Multimarket
ggplot(data = filter(data_mm, Crop == crop_selected), 
       aes(x = Year, y = Percent_Quantity_Change)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-1,1,by = .02)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Soybean - Multimarket', subtitle = '% Change in Quantity over Time',
       y = '% Change in Quantity')

ggsave(paste0(folder, 'graphs/R/', crop_selected, '_quantity_change.png'))

# Partial Eq
ggplot(data = filter(data_pe, Crop == crop_selected), 
       aes(x = Year, y = Percent_Quantity_Change)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-1,1,by = .02)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Soybean - Partial Eq', subtitle = '% Change in Quantity over Time',
       y = '% Change in Quantity')

ggsave(paste0(folder, 'graphs/R/', crop_selected, '_quantity_change.png'))

## Producer Surplus  Change

# Multimarket
ggplot(data = filter(data_mm, Crop == crop_selected), 
       aes(x = Year, y = Percent_Change_in_Producer_Surplus)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-1,1,by = .25)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Soybean - Multimarket', 
       subtitle = '% Change in Producer Surplus over Time',
       y = '% Change in Surplus')

ggsave(paste0(folder, 'graphs/R/', crop_selected, '_prod_surplus_change.png'))

# Partial Eq
ggplot(data = filter(data_pe, Crop == crop_selected), 
       aes(x = Year, y = Percent_Change_in_Producer_Surplus)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-1,1,by = .1)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Soybean - Partial Eq', 
       subtitle = '% Change in Producer Surplus over Time',
       y = '% Change in Surplus')

ggsave(paste0(folder, 'graphs/R/', crop_selected, '_prod_surplus_change.png'))

## Consumer Surplus  Change

# Multimarket
ggplot(data = filter(data_mm, Crop == crop_selected), 
       aes(x = Year, y = Percent_Change_in_Consumer_Surplus)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-1,1,by = .25)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Soybean - Multimarket', 
       subtitle = '% Change in Consumer Surplus over Time',
       y = '% Change in Surplus')

ggsave(paste0(folder, 'graphs/R/', crop_selected, '_cons_surplus_change.png'))

# Partial Eq
ggplot(data = filter(data_pe, Crop == crop_selected), 
       aes(x = Year, y = Percent_Change_in_Consumer_Surplus)) + 
  geom_line(aes(color = Country), size = 1.25) + 
  scale_y_continuous(labels=percent, breaks = seq(-1,1,by = .05)) +
  scale_x_continuous(breaks = seq(0,10,by=1)) +
  labs(title = 'Soybean - Partial Eq', 
       subtitle = '% Change in Consumer Surplus over Time',
       y = '% Change in Surplus')

ggsave(paste0(folder, 'graphs/R/', crop_selected, '_cons_surplus_change.png'))
