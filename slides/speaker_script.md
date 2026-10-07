# Speaker script (10 minutes)

Slides: `slides/slides.pdf`. Page numbers below are PDF pages; section divider pages are only clicked through.

| Speaker | Parts | Time |
| --- | --- | --- |
| **Zhiran Zhang** | Opening, problem, test period and label issue, validation and metric, results, impact, conclusions | ≈ 6 min 15 s |
| **Haolin Yang** | Data loading, preparation, EDA, models and hyper-parameter search, model drivers | ≈ 3 min 45 s |

---

## Zhiran Zhang: opening (0:00 – 1:15)

### p. 1 · Title (15 s)

> Hi everyone, we are Zhiran Zhang and Haolin Yang. Our project predicts whether a new user on Zindi will still be active in their second month.

### p. 2 · Roadmap (20 s)

> Our talk follows the six grading points: problem, data, preparation, EDA, validation and models, and results.
> The activity log of the last month stops on day 22. For this reason we trained and tested every model with two labels: label A covers the whole next month, label B only days 1 to 22. The reason is explained in part two.

### p. 3 → p. 4 · The problem and why it matters (40 s)

> First we are going to talk about the problem we are solving.
> Zindi is Africa's largest data-science competition platform. About 12 thousand people signed up in these seven months, but only 12 to 21 percent of a typical monthly cohort comes back in month two.
> The task: at the end of a user's first month, predict whether they will do anything on Zindi next month. That is binary classification with a small positive class.
> This matters because acquiring users is expensive and most users leave within the first month. A model allows Zindi to send retention offers only to the users who need them, which lowers cost. It also helps to select likely-engaged users for hackathons and shows which behaviours keep people on the platform.

## Haolin Yang: data (1:15 – 2:00)

### p. 5 → p. 6 · Loading the data and recovering the time axis (45 s)

> We loaded eight tables with pandas. The biggest is UserActivity, with 317 thousand page views and clicks.
> The months are masked, so we first had to recover their order. A user can only be active after signing up, so this sign-up-by-activity table must be upper-triangular. That only works for the order M11, M12, M1 up to M5.
> The M4 cohort has almost no M5 activity, because it is Zindi's hidden test set. We therefore built the labels ourselves for cohorts M11 to M3. In the end X has 9,026 users and 50 features, and y is the Active flag.

## Zhiran Zhang: test period and the label problem (2:00 – 4:00)

### p. 7 · Test on a period later than the training data (30 s)

> For time-ordered data, the test set has to come after the training data, otherwise we train on the future. Our latest labelled cohort is M3, so M3 is our hold-out test cohort, scored only once. M11 to M2 are used for training and cross-validation. Any other split would either train on the future or waste a month of data.

### p. 8 · Truncated labels in the hold-out cohort (45 s)

> M3's label is measured in month M4, and the M4 activity log stops on day 22. Competition enrolments and discussions go on to day 30, but page views and clicks, which are most of the events, stop at 22.
> An M3 user who comes back only after day 22 is therefore most likely labelled zero. The right chart shows this: in a normal cohort 8 to 11 percent of returners first appear after day 22. In M3 it is only 1.6 percent. Those returns are missing from the log, not missing in reality.

### p. 9 · Label-definition inconsistency and label B (45 s)

> With the whole-month label, y equals 1 means "active in the next 30 days" in training, but mostly "active in the first 22 days" in the test cohort. The features are aligned, the labels are not.
> This is called a label-definition inconsistency: the model learns one task and is graded on a slightly different one. It biases the F1 estimate. It applies a threshold tuned on cohorts with 17 to 21 percent returners to a cohort whose rate is pushed down by the cutoff. And M3's lower return rate looks like a trend when part of it is an artefact.
> Our solution is label B: active in days 1 to 22 of the next month, for every cohort, in training and in testing. We kept the original as label A and report both.

## Haolin Yang: preparation and EDA (4:00 – 5:50)

### p. 10 → p. 11 · Preparing the dataset (40 s)

> Each preparation step has a reason. We aggregate the event logs per user using only the sign-up month, so nothing from the future leaks in. We group more than 70 raw event titles into 18 behaviour families. Missing country becomes its own category plus a flag, because the missingness itself is informative. We keep the top 10 countries and one-hot encode them, and we parse the submission-count strings.
> We also built new features: recency, meaning days since the last activity, regularity, hackathon participation, and exposure features for users who signed up late in the month.

### p. 12 → p. 13 · EDA 1: retention by cohort (30 s)

> The M12 cohort retains 78 percent, against 12 to 21 for the others. Its activity is one spike of about 1,500 users on a single day, from one hackathon.
> This changed our setup in three ways: time-based validation, a test of dropping M12 from training, and a joined-hackathon feature.

### p. 14 · EDA 2: first-month engagement and behaviour (40 s)

> The return rate rises from 6 percent for users with no active day to 55 percent for users with five or more. Users seen in the last two days of the month return 39 percent of the time, against 7 percent for users who have been silent for 15 days.
> Active behaviour, such as submitting or downloading data, predicts retention much better than reading blogs.
> Country goes missing for most users from M2 on, which looks like a sign-up form change, so we also test dropping the country features. The counts are skewed and collinear, so we log-transform them and use a regularised logistic regression next to tree models.

## Zhiran Zhang: validation and metric (5:50 – 6:30)

### p. 15 → p. 16 · Cross-validation and metric (40 s)

> Our cross-validation is forward chaining by cohort: train on the past, validate on the next month, the same way the model will be used. Random K-fold reports PR-AUC 0.85, while forward validation gives 0.3 to 0.47, because random folds leak cohort information.
> The metric is F1 on the positive class, which is the competition metric. Accuracy is useless when only 12 percent are positive. We select models by PR-AUC and tune the decision threshold on out-of-fold predictions.

## Haolin Yang: models (6:30 – 7:05)

### p. 17 · Models and hyper-parameter search (35 s)

> We compare a rule of thumb, "active on at least k days", with logistic regression, random forest and gradient boosting. Each model is tuned with a grid search on our forward folds, crossed with two choices from the EDA: keep or drop M12, and keep or drop country. We ran the whole search once per label.
> Dropping M12 helps every model. Both labels pick gradient boosting, with CV PR-AUC 0.51 for label A and 0.50 for label B.

## Zhiran Zhang: results (7:05 – 7:50)

### p. 18 → p. 19 · Hold-out results on M3: label A vs. label B (45 s)

> On the hold-out cohort M3, the selected model reaches F1 0.47 with label A and 0.45 with label B, with ROC-AUC 0.83 in both cases. The best rule of thumb reaches 0.36 and 0.40.
> Label A's 0.47 mixes two label definitions. Label B's 0.45 is the consistent estimate, because training and test labels mean the same thing. The gap is only about 0.02, which is within the noise of 240 positives, so the conclusions do not change. We report label B as the main result.

## Haolin Yang: drivers (7:50 – 8:15)

### p. 20 · Feature importance (25 s)

> Permutation importance shows that recency is the strongest signal. Regularity and active behaviour, such as submissions and hackathons, come next. Demographics add almost nothing.
> At the chosen threshold the model finds 46 percent of returners with 44 percent precision, about 3.7 times the base rate.

## Zhiran Zhang: impact and conclusions (8:15 – 10:00)

### p. 21 · Real-world impact (50 s)

> A retention campaign has a fixed budget, so Zindi would contact the top-ranked users. The 20 percent of users the model ranks highest contain 62 percent of all returners, and the top decile is about four times more likely to return than average.
> For example, with 2,000 sign-ups and 5 dollars per intervention, contacting everyone costs 10,000 dollars. Targeting only the uncertain middle 40 percent costs 4,000, which is 60 percent cheaper. Measuring the causal effect would require an A/B test.

### p. 22 · Conclusions (45 s)

> In summary, we recovered the month order, tested on the latest cohort, and fixed a label-definition inconsistency caused by the day-22 cutoff.
> Recency and regularity are the main predictors of retention, and active behaviour matters more than browsing. Because the data is non-stationary, validation design mattered more than the choice of model.
> The model solves the ranking problem well and the exact classification problem partly: F1 is 0.45 against 0.40 for the rule of thumb, because many returns are triggered by future events we cannot see in month one. Next steps: competition-calendar features, more cohorts, and an A/B test.

### p. 23 · Thank you (10 s)

> And that's all for our presentation. Thank you.

---

Tips for recording: rehearse once with a timer. If you run long, shorten p. 14 and p. 21 first. Keep each section divider page on screen for under a second.
