function series = monthlySeries(startValue, annualGrowthPct, months)
    m = (0:months-1)';
    series = startValue * (1 + annualGrowthPct / 100) .^ (m / 12);
end
