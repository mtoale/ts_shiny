library(tidyr)
library(dplyr)

df <- read.csv("data/sales.csv")

table(df$Scode, useNA = "always")
table(df$Pcode, useNA = "always")
table(df$Price, useNA = "always")

table(df$X, useNA = "always")
table(df$X94, useNA = "always")

# Drop blank columns
df <- select(df, -X, -X94)

# Separate columns for wk isn't great for forecasting
# convert data to have a "wk" column and one column of sales
tall_df <- pivot_longer(df, cols = starts_with("Wk"), names_to = "week")
table(tall_df$week)

# Price column has trailing whitespace and dollar sign
# Example: "$24.00 "
# need to remove $ and convert to numeric
tall_df$Price <- gsub("$", "", tall_df$Price, fixed = TRUE)
tall_df$Price <- as.numeric(tall_df$Price)

# Week column has "Wk" prefix, removing
tall_df$week <- gsub("Wk", "", tall_df$week, fixed = TRUE)
tall_df$week <- as.numeric(tall_df$week)

# converting all names to lower for consistency
names(tall_df) <- tolower(names(tall_df))

# rename "value" column to "units"
names(tall_df)[5] <- "units"

# Fake that weeks start at year 1 week 1 and count up from there
# Start counting at 1
tall_df$week <- tall_df$week + 1
tall_df$year <- 2019
# add 1 to year when week is over 52
tall_df$year[tall_df$week > 52] <- tall_df$year[tall_df$week > 52] + 1

# start year 2 weeks at 1
tall_df$week[tall_df$week > 52] <- tall_df$week[tall_df$week > 52] - 52

# Add year and 'W' prefix to be converted to time
tall_df$yearweek <- paste0(tall_df$year, " W", tall_df$week)
tall_df$yearweek <- yearweek(tall_df$yearweek)

# Convert yearweek to date to not have the slow yearweek function again
tall_df$date <- as.Date(tall_df$yearweek)



# select columns of interest
keep_cols <- c(
  "date", "scode", "pcode", "price", "units"
)
tall_df <- tall_df[, keep_cols]
agg_units_df <- aggregate(units ~ date + scode + pcode, tall_df, sum)
agg_price_df <- aggregate(price ~ date + scode + pcode, tall_df, mean)
sales_df <- merge(agg_units_df, agg_price_df, by = c('date', 'scode', 'pcode'))
sales_df <- as_tsibble(sales_df, key = c("scode", "pcode"), index = "date")

write.csv(sales_df, "data/clean_sales.csv", row.names = FALSE)
