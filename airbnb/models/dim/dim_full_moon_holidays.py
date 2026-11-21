import holidays


def is_holiday(date_value):
    german_holidays = holidays.Germany()
    return date_value in german_holidays


def model(dbt, session):
    dbt.config(
        materialized="table",
        packages=["holidays", "snowflake-connector-python[pandas]"],
        enabled=False
    )

    df = dbt.ref("seed_full_moon_dates").to_pandas()

    df["IS_HOLIDAY"] = df["FULL_MOON_DATE"].apply(is_holiday)

    return df