# Titanic Data Explorer

This repository contains a simple Shiny application that predicts the chance of surviving the Titanic disaster. The app is based on the Kaggle Titanic training dataset.

## Running the app

1. Ensure you have R with the packages `shiny`, `ggplot2`, `dplyr`, and `readr` installed. On Debian/Ubuntu you can install them with:
   ```bash
   sudo apt-get install -y r-cran-shiny r-cran-ggplot2 r-cran-dplyr r-cran-readr
   ```

2. Run the app from the repository directory with:
   ```bash
   R -e "shiny::runApp('app.R', port=3838, host='0.0.0.0')"
   ```

3. Open your browser at `http://localhost:3838` to interact with the application.

The dataset `titanic_train.csv` was downloaded from the public Kaggle Titanic repository on GitHub.
