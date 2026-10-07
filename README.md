# Zindi New-User Engagement Prediction: final project

Zhiran Zhang, Haolin Yang · ML with Python

Predict whether a user who signed up in month *m* is still active on Zindi in month *m + 1*.
One notebook does all the analysis. The target is built in two ways and every model is trained and tested with both:

| | Label A (original) | Label B (aligned) |
| --- | --- | --- |
| `Active = 1` if the user has any record in … | the **whole** month after sign-up | **days 1–22** of the month after sign-up, for every cohort |
| Why | — | The M4 activity log stops on day 22, so the hold-out cohort M3 (whose label is measured in M4) cannot see returns after day 22. With label A, training and test labels mean different things (label-definition inconsistency). Label B measures every cohort the same way. |

## Folder structure

```text
ML with Python/
├── README.md
├── build.sh                         # rerun the notebook, then compile report + slides
├── data/                            # raw Zindi tables (input)
├── notebook/
│   └── zindi_engagement.ipynb       # full analysis: preprocessing, EDA, CV, models, label A and label B results
├── figures/                         # all figures, written by the notebook, used by report and slides
├── submissions/
│   ├── submission_label_A.csv       # predictions for the official M4 cohort, label A model
│   └── submission_label_B.csv       # predictions for the official M4 cohort, label B model
├── report/
│   ├── report.tex                   # final report (LaTeX source)
│   └── report.pdf                   # final report: submit this
├── slides/
│   ├── slides.tex                   # Beamer presentation (LaTeX source)
│   ├── slides.pdf                   # presentation used for the video: submit this
│   └── speaker_script.md            # 10-minute script, per slide, split between Zhiran and Haolin
└── archive/                         # earlier versions, kept for reference only
    ├── old_versions/                # previous original / refined notebooks, PDFs, slides
    ├── pre.zip
    └── report_tex.zip
```

## What to submit

| Deadline | File |
| --- | --- |
| Presentation (Oct 7) | `slides/slides.pdf` + video link |
| Final report (Oct 10) | `report/report.pdf` and `notebook/zindi_engagement.ipynb` (code) |

## Results on the hold-out cohort M3

| | Label A (whole month) | Label B (days 1–22) |
| --- | --- | --- |
| Positives in M3 | 243 of 2,000 | 239 of 2,000 |
| Selected model (by CV PR-AUC) | GradBoost (0.508) | GradBoost (0.495) |
| F1 / precision / recall | 0.472 / 0.451 / 0.494 | 0.450 / 0.440 / 0.460 |
| ROC-AUC | 0.830 | 0.829 |
| Best rule of thumb, F1 | 0.359 (active ≥ 2 days) | 0.396 (active ≥ 3 days) |
| Returners captured by the top 20 % of scores | 63 % | 62 % |
| Predicted active share in the submission | 10.9 % | 10.2 % |

Label B is the consistent estimate because training and test labels use the same definition.
The gap (about 0.02 F1) is within the noise of a ~240-positive test cohort.

## How to run

Requirements: Python 3 with pandas, numpy, scikit-learn, matplotlib, seaborn and Jupyter; a LaTeX distribution with `pdflatex` and the Beamer `metropolis` theme (both included in MacTeX / TeX Live).

```bash
bash build.sh            # rerun the notebook (about 5–10 min), then compile report and slides
RUN=0 bash build.sh      # only recompile report and slides
```

Figures use Times New Roman (installed by default on macOS); without it they fall back to a similar serif font.
