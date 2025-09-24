# 📈 What Differentiates a Hit Song from a Super-Hit?

## Project Overview
This data science project investigates the measurable characteristics that distinguish a hugely successful "Super-Hit" song from a regular charting hit on the Billboard Top 100.

By leveraging audio feature data from Spotify (e.g., Danceability, Energy, Valence), this analysis moves beyond subjective music taste to establish a data-driven formula for pop music success.

##  Key Findings & Results

1.  **The "Upbeat Formula" Works:** We found that **Danceability, Energy, and Valence (positivity)** are overwhelmingly the strongest predictors of a song achieving "Super-Hit" status.
The model confirmed that increasing any of these features significantly increases a song's odds of classification as a Super-Hit.

2.  **High Predictive Accuracy:** A Logistic Regression model, built on these core audio features, achieved an impressive **~99% accuracy** 
on unseen test data, successfully classifying which songs would be Super-Hits.

3.  **Pop Music is Changing:** Trend analysis revealed a clear, continuous upward trajectory in the average **Danceability** and **Energy** of top songs over the last several decades
suggesting modern pop music is evolving toward tracks designed for high-energy consumption and dance/social media trends (like TikTok).

##  Methodology

The project followed a standard data science workflow:

* **Data Sourcing:** Combined Billboard Top 100 chart data with comprehensive Spotify audio feature data.
* **Target Definition:** Created a binary target variable (`hit_class`) to define a "Super-Hit" (a song with a combined high score in Danceability, Energy, and Valence).
* **Exploratory Analysis (EDA):** Used density plots and t-tests to confirm statistically significant differences in audio feature distributions between the two classes.
* **Modeling:** Built a **Logistic Regression** classifier, evaluated coefficients via **Odds Ratios** for interpretability, and tested performance using a **Confusion Matrix**.

## Repository Contents

| File/Folder | Description |
| :--- | :--- |
| `data/billboard_top_100_final.csv` | The raw dataset used for the analysis. |
| `code/songs_research.R` | The clean R script that performs the full analysis and generates the report. |
| `results/songs-research.html` | **The final, self-contained R Markdown report.** View this for the full narrative, plots and statistical results. |
| `LICENSE` | MIT License for open-source sharing. |

## License
This project is shared under the [MIT License](LICENSE).# 📈 What Differentiates a Hit Song from a Super-Hit?
