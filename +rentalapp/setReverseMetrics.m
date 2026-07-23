function setReverseMetrics(app, result)
    if isempty(result.scenario)
        app.Reverse.metricMaxPrice.Text = '-';
        app.Reverse.metricInitialCash.Text = '-';
        app.Reverse.metricMortgage.Text = '-';
        app.Reverse.metricDeductibleCosts.Text = '-';
        app.Reverse.metricTaxSaving.Text = '-';
        app.Reverse.metricCashFlow.Text = '-';
        app.Reverse.metricCashOnCash.Text = '-';
        app.Reverse.metricDSCR.Text = '-';
        return;
    end

    scenario = result.scenario;
    app.Reverse.metricMaxPrice.Text = rentalapp.formatMoney(app, result.maxPrice);
    app.Reverse.metricInitialCash.Text = rentalapp.formatMoney(app, scenario.initialCash);
    app.Reverse.metricMortgage.Text = rentalapp.formatMoney(app, scenario.monthlyMortgage);
    app.Reverse.metricDeductibleCosts.Text = rentalapp.formatMoney(app, scenario.firstYearTaxDeductible);
    app.Reverse.metricTaxSaving.Text = rentalapp.formatMoney(app, scenario.taxSavings(1));
    app.Reverse.metricCashFlow.Text = rentalapp.formatMoney(app, scenario.cashFlow(1));
    app.Reverse.metricCashOnCash.Text = rentalapp.formatPercent(scenario.cashOnCash);
    app.Reverse.metricDSCR.Text = rentalapp.formatRatio(scenario.dscr);
end
