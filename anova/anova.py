import numpy as np
import pandas as pd
from scipy.stats import f


def generate_dataset(a: int = 4,
                     n: int = 10,
                     slope: float = 2.0,
                     intercept: float = 5.0,
                     sigma: float = 1.0,
                     seed: int | None = 42) -> pd.DataFrame:
    """Generate a synthetic one-factor dataset with hidden linear trend.

    Parameters
    ----------
    a : int
        Number of levels for the factor.
    n : int
        Number of observations per level.
    slope : float
        The hidden linear slope relating level index to the mean of *y*.
    intercept : float
        Intercept for the hidden linear model.
    sigma : float
        Standard deviation of the Gaussian noise added to each observation.
    seed : int | None
        Random seed for reproducibility. If ``None``, the RNG is not seeded.

    Returns
    -------
    pd.DataFrame
        DataFrame containing two columns: ``level`` (categorical) and ``y``.
    """
    if seed is not None:
        rng = np.random.default_rng(seed)
    else:
        rng = np.random.default_rng()

    # levels = (np.arange(a) * 0) + 1
    levels = np.arange(a)
    means = intercept + 0.6 * levels  # hidden true means per level

    # Generate data: for each level, draw *n* observations from Normal(mean, sigma)
    data = {
        "level": np.repeat(levels, n),
        "y": rng.normal(loc=np.repeat(means, n), scale=sigma)
    }

    df = pd.DataFrame(data)
    df["level"] = df["level"].astype("category")
    return df


def anova_one_way(df: pd.DataFrame) -> dict:
    """Compute one-way ANOVA table manually.

    Parameters
    ----------
    df : pd.DataFrame
        DataFrame with columns ``level`` and ``y``.

    Returns
    -------
    dict
        Dictionary containing sums of squares (SS), degrees of freedom (df),
        mean squares (MS), F-statistic, and p-value.
    """
    y = df["y"].values
    groups = df.groupby("level")

    # Number of groups and total observations
    a = groups.ngroups
    n_i = groups.size().to_numpy()
    N = y.size

    # Grand mean
    grand_mean = y.mean()

    # Total Sum of Squares
    ss_total = ((y - grand_mean) ** 2).sum()

    # Treatment (between-groups) Sum of Squares
    group_means = groups.mean()["y"].to_numpy()
    ss_treat = (n_i * (group_means - grand_mean) ** 2).sum()

    # Error (within-groups) Sum of Squares
    ss_error = ss_total - ss_treat  # could also compute directly

    # Degrees of freedom
    df_treat = a - 1
    df_error = N - a
    df_total = N - 1

    # Mean Squares
    ms_treat = ss_treat / df_treat
    ms_error = ss_error / df_error

    # F-statistic and p-value
    F = ms_treat / ms_error
    p_value = f.sf(F, df_treat, df_error)

    return {
        "SStotal": ss_total,
        "SStreatments": ss_treat,
        "SSerror": ss_error,
        "df_treat": df_treat,
        "df_error": df_error,
        "df_total": df_total,
        "MS_treat": ms_treat,
        "MS_error": ms_error,
        "F": F,
        "p_value": p_value,
    }


if __name__ == "__main__":
    # Experiment parameters (feel free to tweak)
    a_levels = 5  # number of factor levels
    n_per_level = 8  # observations per level
    hidden_slope = 1.5
    hidden_intercept = 3.0
    noise_sigma = 1.2
    seed = 123

    # Generate data and run ANOVA
    data = generate_dataset(a=a_levels,
                            n=n_per_level,
                            slope=hidden_slope,
                            intercept=hidden_intercept,
                            sigma=noise_sigma,
                            seed=seed)

    print("Generated dataset (first 10 rows):")
    print(data, "\n")

    results = anova_one_way(data)

    print("One-way ANOVA results (manual calculation):")
    print(f"SStotal       = {results['SStotal']:.4f} (df = {results['df_total']})")
    print(f"SStreatments  = {results['SStreatments']:.4f} (df = {results['df_treat']})")
    print(f"SSerror       = {results['SSerror']:.4f} (df = {results['df_error']})")
    print(f"MS_treatments = {results['MS_treat']:.4f}")
    print(f"MS_error      = {results['MS_error']:.4f}")
    print(f"F-statistic   = {results['F']:.4f}")
    print(f"p-value       = {results['p_value']:.6f}")

    if results["p_value"] < 0.05:
        print("\nConclusion: Reject the null hypothesis – the factor levels influence y (p < 0.05).")
    else:
        print("\nConclusion: Fail to reject the null hypothesis – no significant effect of factor levels (p >= 0.05).")
