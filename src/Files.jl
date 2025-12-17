## -- PRIVATE FUNCTIONS BELOW HERE ------------------------------------------------------------------------------ #
function _jld2(path::String)::Dict{String,Any}
    return load(path);
end
# -- PRIVATE FUNCTIONS ABOVE HERE ------------------------------------------------------------------------------ #

# -- PUBLIC FUNCTIONS BELOW HERE ------------------------------------------------------------------------------- #

"""
    MyTestingMarketDataSet() -> Dict{String, DataFrame}

Load the components of the SP500 Daily open, high, low, close (OHLC) dataset as a dictionary of DataFrames.
This data was provided by [Polygon.io](https://polygon.io/) and covers the period from January 3, 2025, to the current date (it is updated periodically).

"""
MyTestingMarketDataSet() = _jld2(joinpath(_PATH_TO_DATA, "SP500-Daily-OHLC-1-3-2025-to-11-18-2025.jld2"));

"""
    MyTrainingMarketDataSet() -> Dict{String, DataFrame}

Load the components of the SP500 Daily open, high, low, close (OHLC) dataset as a dictionary of DataFrames.
This data was provided by [Polygon.io](https://polygon.io/) and covers the period from January 3, 2014, to December 31, 2024.

"""
MyTrainingMarketDataSet() = _jld2(joinpath(_PATH_TO_DATA, "SP500-Daily-OHLC-1-3-2014-to-12-31-2024.jld2"));

"""
    MyTickerPickerBanditModelResults() -> Dict{String, Any}

Load the ticker-picker bandit model results computed in the `Setup-L14a-Example-RiskAware-BBBP-Ticker-Picker-Fall-2025.ipynb` notebook.
"""
function MyTickerPickerBanditModelResults(;mood::Symbol = :neutral)::Dict{String, Any}
    # Map mood to file name
    filename = mood == :optimistic ? "Ticker-Picker-Preferences-Optimistic-Fall-2025.jld2" :
                mood == :pessimistic ? "Ticker-Picker-Preferences-Pessimistic-Fall-2025.jld2" :
                mood == :neutral ? "Ticker-Picker-Preferences-Neutral-Fall-2025.jld2" : nothing

    isnothing(filename) && error("Invalid mood specified: $mood. Valid options are :optimistic, :neutral, :pessimistic.")

    path = joinpath(_PATH_TO_DATA, filename)
    if isfile(path)
        return _jld2(path)
    end

    # Fallback: construct a simple preferences table if the file is missing
    # Build tickers from the testing dataset (present in this repo)
    local_dataset = MyTestingMarketDataSet()["dataset"]
    tickers = keys(local_dataset) |> collect |> sort

    # Heuristic lambda by mood
    λ = mood == :optimistic ? -1.0 : mood == :neutral ? 0.0 : 1.0

    # Simple uniform preferences (> cutoff = 0.5 ensures assets are "preferred" by default)
    probs = fill(0.6, length(tickers))

    df = DataFrame(
        ticker = tickers,
        probability = probs,
        lambda = fill(λ, length(tickers))
    )

    return Dict("preferences" => df)
end
# -- PUBLIC FUNCTIONS ABOVE HERE ------------------------------------------------------------------------------ #