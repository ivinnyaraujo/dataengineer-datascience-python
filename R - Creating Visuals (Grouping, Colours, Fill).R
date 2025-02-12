# Creating Visuals in R

#### Grouping, Colours and Fill ####

# Load required packages
library(kableExtra) # formatting and styling tables
library(ggplot2) # create graphics
library(stringr)
library(janitor) # use snake_case in attribute name
library(tibble)
library(dplyr) # data manipulation
library(tidyr) # reshaping data, particularly for converting between wide and long formats.

# Create a data frame with the given data
voting_pool <- data.frame(
  Region = c("Auckland", "Wellington", "Canterbury", "Waikato", "Otago", "Bay of Plenty"),
  VotingPreference = c("Labour", "National", "Labour", "National", "Labour", "National"),
  MedianIncome = c(60000, 65000, 58000, 62000, 57000, 63000) # NA for missing value
)

# Print the data frame
print(voting_pool)
str(population_data)

# Generate table with kableExtra
kbl_table <- kbl(voting_pool, caption = "Voting Poll Feb 2025", format.args = list(big.mark = ",")) %>%
  kable_styling(bootstrap_options = c("striped", "hover"), position = "center")

# Print the table
print(kbl_table)


# Create a bar chart using ggplot2
voting_pool_chart <- ggplot(voting_pool, aes(x = Region, y = MedianIncome, fill = VotingPreference)) +
  geom_bar(stat = "identity") +  # Create bar chart with bars filled by VotingPreference
  scale_fill_manual(values = c(`National` = "blue", `Labour` = "red"))  # Set colors for the bars; overrode the default colours using `scale_fill_manual()`

# Display the bar chart
print(voting_pool_chart)  # Print the plot after it's created


######## Create grouped bars to cluster using `position_dodge()`

# Create a tribble dataset
ethnicity_data <- tribble(
  ~region,       ~maori_ethnicity, ~non_maori_ethnicity,
  "Auckland",    30000,             30000,
  "Wellington",  32000,             33000,
  "Canterbury",  29000,             29000,
  "Otago",       28000,             29000
)

# Pivot the data longer
ethnicity_data_long <- ethnicity_data %>%
  pivot_longer(cols = contains("ethnicity"), names_to = "ethnicity", values_to = "median_income")

# Generate table with kableExtra
ethnicity_table <- kbl(ethnicity_data_long, caption = "Median Income by Ethnicity in Regions", format.args = list(big.mark = ",")) %>%
  kable_styling(bootstrap_options = c("striped", "hover"), position = "center")

# Print the table
print(ethnicity_table)

# Create a bar chart using ggplot2
ethnicity_chart <- ggplot(ethnicity_data_long, aes(x = region, y = median_income, fill = ethnicity, group = ethnicity)) +
  
  # Use geom_bar to create a bar chart with 'stat = "identity"' to plot the actual values of 'median_income'
  # Position bars side by side for different 'ethnicity' using 'position_dodge()'
  geom_bar(stat = "identity", position = position_dodge()) +
  
  # Add a title to the chart and labels for x and y axes
  labs(title = "Median Income by Ethnicity in Different Regions", x = "Region", y = "Median Income") +
  
  # Manually set colors for 'maori_ethnicity' and 'non_maori_ethnicity'
  scale_fill_manual(values = c("maori_ethnicity" = "green", "non_maori_ethnicity" = "orange"))  # Customize colors

# Display the bar chart
print(ethnicity_chart)

#### Group Variables Graph ############

# Reshape the dataset from wide to long format, then create a bar chart
ethnicity_data_long <- ethnicity_data %>%
  pivot_longer(cols = contains("ethnicity"), names_to = "ethnicity", values_to = "median_income")

# Create the bar chart using ggplot2
ethnicity_chart <- ggplot(ethnicity_data_long, aes(x = region, y = median_income, fill = ethnicity)) +
  geom_bar(stat = "identity", position = position_dodge()) +  # Create bars with positions dodged
  facet_wrap(~ethnicity) +  # Facet the plot by 'ethnicity'
  labs(title = "Median Income by Ethnicity in Different Regions", x = "Region", y = "Median Income") +  # Add labels
  scale_fill_manual(values = c("maori_ethnicity" = "green", "non_maori_ethnicity" = "orange"))  # Customize bar colors

# Display the bar chart
print(ethnicity_chart)

### Styling the ethnicity_chart with better labels

ethnicity_data %>%
  pivot_longer(cols = contains("ethnicity"), names_to = "ethnicity", values_to = "median_income") %>%
  mutate(ethnicity = recode(ethnicity, 
                            "maori_ethnicity" = "Māori", 
                            "non_maori_ethnicity" = "Non-Māori")) %>%  # Recode ethnicity labels
  ggplot(aes(x = region, y = median_income, fill = ethnicity, group = ethnicity)) +
  geom_bar(stat = "identity", position = position_dodge()) +  # Create bars with dodged positions
  labs(
    x = "Regional Council",
    y = "Median Income ($)",
    fill = "Ethnicity",  # Label for the fill legend
    title = "Median income by Māori ethnicity and regional council for 2023"
  ) +  # Add a custom title and labels
  scale_fill_manual(values = c("Māori" = "green", "Non-Māori" = "orange"))  # Customize color manually
  theme(
    plot.title = element_text(hjust = 0.5),  # Centre the plot title
    plot.margin = margin(1, 1, 2, 1)  # Add margin to prevent title clipping
  )

