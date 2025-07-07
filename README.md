# Titanic Data Explorer

This repository provides a small Shiny app that predicts the survival probability for a hypothetical passenger on the Titanic. The model is trained on the `titanic_train` data from the CRAN package **titanic** and visualized with **ggplot2**.

## Installation

1. Install R (version 4 or newer).
2. Install the required packages:

```R
install.packages(c("shiny", "ggplot2", "dplyr", "tidyr", "titanic"))
```

## Usage

Start the application from R by running:

```R
shiny::runApp("app.R")
```

A browser window will open where you can fill out ticket information (class, sex, age, etc.). The app then displays your estimated chance of survival and how it compares with the historical data.
