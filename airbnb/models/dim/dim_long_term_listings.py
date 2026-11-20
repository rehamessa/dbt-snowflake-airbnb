def model(dbt, session):
    listings = dbt.ref("dim_listings_cleansed")

    long_term_listings = listings.filter(listings["minimum_nights"] >= 30)

    return long_term_listings.select("listing_id", "listing_name", "price")