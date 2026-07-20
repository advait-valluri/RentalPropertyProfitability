function yearly = annualizeByYear(monthlyCashFlow, initialCash)
    years = ceil(numel(monthlyCashFlow) / 12);
    yearly = NaN(years, 2);
    for y = 1:years
        lo = (y - 1) * 12 + 1;
        hi = min(y * 12, numel(monthlyCashFlow));
        yearly(y, 1) = y;
        yearly(y, 2) = rentalapp.safeDivide(sum(monthlyCashFlow(lo:hi)), initialCash) * 100;
    end
end
