# Speaker script (10 minutes)

Slides: `slides/slides.pdf`. Page numbers below are PDF pages; section divider pages are only clicked through.

| Speaker | Parts | Time |
| --- | --- | --- |
| **Zhiran Zhang** | Opening, problem, test period and label issue, validation and metric, results, impact, conclusions | ≈ 5 min 25 s |
| **Haolin Yang** | Data loading, preparation, EDA, models and hyper-parameter search, model drivers | ≈ 3 min 20 s |

---

## Zhiran Zhang: opening (0:00 – 1:05)

### p. 1 · Title (15 s)

> Hi everyone, we are Zhiran Zhang and Haolin Yang. Our project predicts whether a new user on Zindi will still be active in their second month.

### p. 2 · Roadmap (15 s)

> Our talk follows the six grading points: problem, data, preparation, EDA, validation and models, and results.
> The last month's activity log stops on day 22, so we trained and tested every model with two labels: label A covers the whole next month, label B only days 1 to 22.

### p. 3 → p. 4 · The problem and why it matters (35 s)

> Zindi is Africa's largest data-science competition platform. About 12 thousand people signed up in these seven months, but only 12 to 21 percent of a typical monthly cohort comes back in month two.
> The task: at the end of a user's first month, predict whether they will do anything on Zindi next month. That is binary classification with a small positive class.
> This matters because acquiring users is expensive and most leave within the first month. A model lets Zindi send retention offers only to users who need them, which lowers cost. It also shows which behaviours keep people on the platform.

## Haolin Yang: data (1:05 – 1:50)

### p. 5 → p. 6 · Loading the data and recovering the time axis (45 s)

> We loaded eight tables with pandas. The biggest is UserActivity, with 317 thousand page views and clicks.
> The months are masked, so we first had to recover their order. A user can only be active after signing up, so this sign-up-by-activity table must be upper-triangular, which only the order M11, M12, M1 up to M5 satisfies.
> The M4 cohort has almost no M5 activity, because it is Zindi's hidden test set. We therefore built the labels ourselves for cohorts M11 to M3. In the end X has 9,026 users and 50 features, and y is the Active flag.

## Zhiran Zhang: test period and the label problem (1:50 – 3:30)

### p. 7 · Test on a period later than the training data (25 s)

> For time-ordered data, the test set has to come after the training data, otherwise we train on the future. Our latest labelled cohort is M3, so M3 is our hold-out test cohort, scored only once. M11 to M2 are used for training and cross-validation.

### p. 8 · Truncated labels in the hold-out cohort (40 s)

> M3's label is measured in month M4, and the M4 activity log stops on day 22. Enrolments and discussions continue to day 30, but page views and clicks, most of the events, stop at 22.
> An M3 user who comes back only after day 22 is therefore most likely labelled zero. The right chart shows this: in a normal cohort 8 to 11 percent of returners first appear after day 22. In M3 it is only 1.6 percent. Those returns are missing from the log, not missing in reality.

### p. 9 · Label-definition inconsistency and label B (35 s)

> With the whole-month label, y equals 1 means "active in the next 30 days" in training, but mostly "active in the first 22 days" in the test cohort. The features are aligned, the labels are not.
> This is a label-definition inconsistency: the model learns one task and is graded on another. It biases the F1 estimate, and it applies a threshold tuned on cohorts with 17 to 21 percent returners to a cohort whose rate is pushed down by the cutoff.
> Our solution is label B: active in days 1 to 22 of the next month, for every cohort, in training and in testing. We kept the original as label A and report both.

## Haolin Yang: preparation and EDA (3:30 – 5:10)

### p. 10 → p. 11 · Preparing the dataset (35 s)

> We aggregate the event logs per user using only the sign-up month, so nothing from the future leaks in. We group more than 70 raw event titles into 18 behaviour families. Missing country becomes its own category plus a flag, because the missingness itself is informative. We keep the top 10 countries and one-hot encode them, and we parse the submission-count strings.
> We also built new features: recency, meaning days since the last activity, regularity, hackathon participation, and exposure features for users who signed up late in the month.

### p. 12 → p. 13 · EDA 1: retention by cohort (25 s)

> The M12 cohort retains 78 percent, against 12 to 21 for the others. Its activity is a one-day spike of about 1,500 users from a single hackathon.
> This led to three choices: time-based validation, a test of dropping M12 from training, and a joined-hackathon feature.

### p. 14 · EDA 2: first-month engagement and behaviour (35 s)

> The return rate rises from 6 percent for users with no active day to 55 percent for users with five or more. Users seen in the last two days of the month return 39 percent of the time, against 7 percent for users who have been silent for 15 days.
> Active behaviour, such as submitting or downloading data, predicts retention much better than reading blogs.
> Country is missing for most users from M2 on, likely a sign-up form change, so we also test dropping it. The counts are skewed and collinear, so we log-transform them and use a regularised logistic regression next to tree models.

## Zhiran Zhang: validation and metric (5:10 – 5:50)

### p. 15 → p. 16 · Cross-validation and metric (40 s)

> Our cross-validation is forward chaining by cohort: train on the past, validate on the next month, as in deployment. Random K-fold reports PR-AUC 0.85, while forward validation gives 0.3 to 0.47, because random folds leak cohort information.
> The metric is F1 on the positive class, which is the competition metric. Accuracy is useless when only 12 percent are positive. We select models by PR-AUC and tune the decision threshold on out-of-fold predictions.

## Haolin Yang: models (5:50 – 6:20)

### p. 17 · Models and hyper-parameter search (30 s)

> We compare a rule of thumb, "active on at least k days", with logistic regression, random forest and gradient boosting. Each model is grid-searched on our forward folds, together with two EDA choices: keep or drop M12, and keep or drop country. We ran the whole search once per label.
> Dropping M12 helps every model. Both labels pick gradient boosting, with CV PR-AUC 0.51 for label A and 0.50 for label B.

## Zhiran Zhang: results (6:20 – 6:55)

### p. 18 → p. 19 · Hold-out results on M3: label A vs. label B (35 s)

> On the hold-out cohort M3, the selected model reaches F1 0.47 with label A and 0.45 with label B, with ROC-AUC 0.83 in both cases. The best rule of thumb reaches 0.36 and 0.40.
> Label B's 0.45 is the consistent estimate, since training and test labels mean the same thing. The gap of 0.02 is within the noise of 240 positives, so the conclusions hold. We report label B as the main result.

## Haolin Yang: drivers (6:55 – 7:20)

### p. 20 · Feature importance (25 s)

> Permutation importance shows that recency is the strongest signal. Regularity and active behaviour, such as submissions and hackathons, come next. Demographics add almost nothing.
> At the chosen threshold the model finds 46 percent of returners with 44 percent precision, about 3.7 times the base rate.

## Zhiran Zhang: impact and conclusions (7:20 – 8:50)

### p. 21 · Real-world impact (45 s)

> A retention campaign has a fixed budget, so Zindi would contact the top-ranked users. The 20 percent of users the model ranks highest contain 62 percent of all returners, and the top decile is about four times more likely to return than average.
> For example, with 2,000 sign-ups and 5 dollars per intervention, contacting everyone costs 10,000 dollars; targeting only the uncertain middle 40 percent costs 4,000, 60 percent less.

### p. 22 · Conclusions (30 s)

> In summary, we recovered the month order, tested on the latest cohort, and fixed the day-22 label inconsistency.
> Recency and regularity drive retention, and active behaviour matters more than browsing. With non-stationary data, validation design mattered more than the model.
> The model ranks users well and classifies them partly: F1 0.45 against 0.40 for the rule of thumb, since many returns depend on future events invisible in month one.

### p. 23 · Thank you (5 s)

> Thank you.

---

Tips for recording: rehearse once with a timer. If you run long, shorten p. 14 and p. 21 first. Keep each section divider page on screen for under a second.
