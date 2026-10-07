# Zindi New-User Engagement Prediction: final project

Predict whether a user who signed up in month *m* is still active on Zindi in month *m + 1*.
The project comes in two versions that share the same data, features, models and validation.

```
final project/
├── README.md
├── export.sh                         # run a notebook and export its slides + PDF
├── data/                             # raw Zindi tables, shared by both versions
├── original_version/
│   ├── zindi_engagement.ipynb        # original analysis (figures redrawn)
│   ├── zindi_engagement.pdf          # PDF export of the notebook
│   ├── zindi_engagement.slides.html  # reveal.js slides of the notebook
│   ├── submission.csv                # predictions for the official test cohort (M4)
│   └── presentation_script.md
├── refined_version/
│   ├── zindi_engagement_refined.ipynb   # same analysis with an aligned label window
│   ├── zindi_engagement_refined.pdf
│   ├── zindi_engagement_refined.slides.html
│   └── submission.csv
└── archive/                          # untouched zip copies of the files before this reorganisation
```

## What differs between the versions

| | Original version | Refined version |
|---|---|---|
| Target `Active = 1` | any record in the **whole** month after sign-up | any record in **days 1–22** of the month after sign-up, for every cohort |
| Why | — | The M4 activity log stops on day 22, so the hold-out cohort's (M3) labels can only see 22 days of M4 page activity. Measuring every cohort over days 1–22 makes training and hold-out labels mean the same thing. |
| Extra cells | — | Section 1.3 adds a short explanation and a table showing, per cohort, how many returners first appear after day 22 (8–11 % normally, 1.6 % for M3) |

Everything else (features, EDA, forward-chaining validation, grid search, threshold choice) is identical.
Both versions use the same redrawn figures: higher resolution (retina, 150 dpi; 300 dpi when saved), Times New Roman,
larger labels, value annotations and 95 % confidence intervals where useful.

## Results on the hold-out cohort M3

| | Original | Refined |
|---|---|---|
| Positives in M3 | 243 of 2,000 | 239 of 2,000 |
| Selected model (by CV PR-AUC) | GradBoost (0.508) | GradBoost (0.495) |
| F1 / precision / recall | 0.472 / 0.451 / 0.494 | 0.450 / 0.440 / 0.460 |
| ROC-AUC | 0.830 | 0.829 |
| Best rule of thumb, F1 | 0.359 (active ≥ 2 days) | 0.396 (active ≥ 3 days) |
| Returners captured by the top 20 % of scores | 63 % | 62 % |
| Predicted active share in `submission.csv` | 10.9 % | 10.2 % |

The two versions differ by about 0.02 F1, which is within the noise of a ~240-positive test cohort.
The refined numbers are the consistent estimate because training and test labels use the same definition.

## How to run

Requirements: Python 3 with pandas, numpy, scikit-learn, matplotlib, seaborn and Jupyter; xelatex for the PDF.

```bash
bash export.sh original_version          # re-run the notebook, then export slides + PDF
bash export.sh refined_version
RUN=0 bash export.sh refined_version     # export only, without re-running
```

The grid search takes about 5–10 minutes per notebook.
Figures use Times New Roman (installed by default on macOS); on a machine without it they fall back to a similar serif font.
