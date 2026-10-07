# Video presentation script (~12 min)

Open `zindi_engagement.slides.html` in a browser (arrow keys to navigate, `F` for full screen) or scroll through `zindi_engagement.pdf`.
Four parts, one per rubric item; assign one speaker per part.

## Part 1 — Problem & data (≈2 min) · slides "Predicting…", "1. The problem", "1.1–1.3"

- Zindi: Africa's largest data-science competition platform. Most new users are one-month tourists: only 12–21 % come back in month 2.
- Task: at the end of a user's first month, predict whether they will do anything on Zindi next month. This is binary classification.
- Why it matters: targeted retention costs less than blanket campaigns. It also helps find future community members early and shows which behaviours drive retention.
- Data: 8 relational tables, with dates masked. We worked out the month order from the sign-up × activity heatmap. It is almost upper-triangular, so the order is M11 → M12 → M1 → … → M5.
- Zindi hid the M4 cohort's month-5 activity (that cohort is the test set). So we built our own labels from cohorts M11–M3, loaded everything with pandas and split the data into X (50 features) and y (`Active`).

## Part 2 — Data preparation & EDA (≈4 min) · sections 2 and 3

- The preparation table gives each transformation and the reason for it. We only use sign-up-month data (no leakage), group 70+ event titles into 18 behaviour families, and give missing country its own category plus a flag. Other steps: top-10 one-hot encoding for country, parsing the "count 10" strings, and exposure features (`days_observed`, `days_since_last`).
- EDA 3.1: the M12 cohort has 78 % retention because of one hackathon (a single-day spike of about 1 500 users on day 15). Two consequences: we use time-based validation, and we test leaving this cohort out of training.
- EDA 3.2: retention grows with the number of active days (6 % → 55 %). Recency is also strong: 39 % for users seen in the last 2 days vs 7 % for users gone 15+ days.
- EDA 3.3: *doing* things (submit, download data) beats *reading*. Country is missing for 65–70 % of users from M2 on, because the sign-up form changed, so country acts as a time proxy.
- The features are collinear, so we use a regularised logistic regression plus tree models.

## Part 3 — Validation, models, tuning (≈3 min) · sections 4 and 5

- Cross-validation uses forward chaining by cohort. M3 is a hold-out cohort that we score only once. Random 5-fold gives PR-AUC 0.85, but the honest temporal estimate is 0.30–0.47.
- Metric: F1 on the positive class (the competition's metric; positives are 12 %). We select models on PR-AUC and tune the decision threshold on out-of-fold predictions.
- Models: a rule-of-thumb baseline, logistic regression, random forest and gradient boosting, all tuned with a grid search over our forward folds.
- Leaving M12 out of training improves every model (for example gradient boosting goes from 0.43 to 0.51 CV PR-AUC).
- Gradient boosting (chosen on CV) scores F1 = 0.47 on the hold-out cohort. The rule of thumb scores 0.36 and "everyone active" scores 0.22. All three ML models land within 0.02 of each other.

## Part 4 — Results, impact, conclusions (≈3 min) · 5.2, 6 and 7

- The most important feature is recency, well ahead of the others. Regularity and submission signals come next, and demographics add almost nothing.
- Impact: the top 20 % of users by score contain 63 % of the users who come back, and the top decile is 4× the average. The business example shows targeting can cut campaign cost by about 60 %; an A/B test is needed to measure the causal effect.
- Submission for the M4 cohort: the predicted active share is 10.9 %, which is plausible given the 12 % base rate.
- Conclusions: the model ranks new users well enough to support targeted retention, and F1 is moderate. The biggest lessons came from validation design and the non-stationary data, more than from the choice of model. Next steps: add competition-calendar features, collect more cohorts, and run an A/B test.
