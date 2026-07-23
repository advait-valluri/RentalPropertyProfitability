function setForwardMetrics(app, result)
    app.Forward.metricInitialCash.Text = rentalapp.formatMoney(app, result.initialCash);
    app.Forward.metricMortgage.Text = rentalapp.formatMoney(app, result.monthlyMortgage);
    app.Forward.metricNOI.Text = rentalapp.formatMoney(app, result.noi(1));
    app.Forward.metricAfa.Text = rentalapp.formatMoney(app, result.annualAfa);
    app.Forward.metricDeductibleCosts.Text = rentalapp.formatMoney(app, result.firstYearTaxDeductible);
    app.Forward.metricTaxSaving.Text = rentalapp.formatMoney(app, result.taxSavings(1));
    app.Forward.metricCashFlow.Text = rentalapp.formatMoney(app, result.cashFlow(1));
    app.Forward.metricCapRate.Text = rentalapp.formatPercent(result.capRate);
    app.Forward.metricCashOnCash.Text = rentalapp.formatPercent(result.cashOnCash);
    app.Forward.metricDSCR.Text = rentalapp.formatRatio(result.dscr);
    app.Forward.metricBreakEven.Text = result.breakEvenText;
end
