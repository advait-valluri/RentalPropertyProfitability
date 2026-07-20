function createForwardTab(app)
    main = uigridlayout(app.ForwardTab, [1 2]);
    main.ColumnWidth = {430, '1x'};
    main.Padding = [8 8 8 8];
    main.ColumnSpacing = 12;

    left = uigridlayout(main, [3 1]);
    left.RowHeight = {'1x', 190, 24};
    left.RowSpacing = 8;

    inputPanel = uipanel(left, 'Title', 'Inputs');
    inputPanel.Scrollable = 'on';
    inputGrid = uigridlayout(inputPanel, [22 2]);
    inputGrid.Scrollable = 'on';
    inputGrid.ColumnWidth = {'1x', 130};
    inputGrid.RowHeight = repmat({26}, 1, 22);
    inputGrid.Padding = [10 8 10 8];
    inputGrid.RowSpacing = 5;

    app.Forward.purchasePrice = rentalapp.addNumericField(inputGrid, 'Purchase price', 300000, 0, Inf, @() app.updateForward());
    app.Forward.monthlyRent = rentalapp.addNumericField(inputGrid, 'Monthly rent', 1800, 0, Inf, @() app.updateForward());
    app.Forward.otherIncome = rentalapp.addNumericField(inputGrid, 'Other monthly income', 0, 0, Inf, @() app.updateForward());
    app.Forward.downPaymentPct = rentalapp.addNumericField(inputGrid, 'Down payment (%)', 20, 0, 100, @() app.updateForward());
    app.Forward.interestRate = rentalapp.addNumericField(inputGrid, 'Interest rate (%)', 4.5, 0, Inf, @() app.updateForward());
    app.Forward.loanTermYears = rentalapp.addNumericField(inputGrid, 'Loan term (years)', 30, 1, Inf, @() app.updateForward());
    app.Forward.auxCostPct = rentalapp.addNumericField(inputGrid, 'Auxiliary costs (%)', 5, 0, Inf, @() app.updateForward());

    uilabel(inputGrid, 'Text', 'Agent commission');
    app.Forward.includeAgent = uicheckbox(inputGrid, ...
        'Text', '3.57%', ...
        'Value', true, ...
        'ValueChangedFcn', @(~, ~) app.updateForward());

    app.Forward.closingCosts = rentalapp.addNumericField(inputGrid, 'Fixed closing costs', 0, 0, Inf, @() app.updateForward());
    app.Forward.renovationCosts = rentalapp.addNumericField(inputGrid, 'Renovation/repairs', 10000, 0, Inf, @() app.updateForward());
    app.Forward.propertyTax = rentalapp.addNumericField(inputGrid, 'Property tax / month', 250, 0, Inf, @() app.updateForward());
    app.Forward.insurance = rentalapp.addNumericField(inputGrid, 'Insurance / month', 100, 0, Inf, @() app.updateForward());
    app.Forward.hoa = rentalapp.addNumericField(inputGrid, 'HOA / month', 0, 0, Inf, @() app.updateForward());
    app.Forward.utilities = rentalapp.addNumericField(inputGrid, 'Utilities/other / month', 100, 0, Inf, @() app.updateForward());
    app.Forward.vacancyPct = rentalapp.addNumericField(inputGrid, 'Vacancy (%)', 5, 0, 100, @() app.updateForward());
    app.Forward.maintenancePct = rentalapp.addNumericField(inputGrid, 'Maintenance (% rent)', 5, 0, Inf, @() app.updateForward());
    app.Forward.capexPct = rentalapp.addNumericField(inputGrid, 'CapEx reserve (% rent)', 5, 0, Inf, @() app.updateForward());
    app.Forward.managementPct = rentalapp.addNumericField(inputGrid, 'Management (% rent)', 8, 0, Inf, @() app.updateForward());
    app.Forward.rentGrowthPct = rentalapp.addNumericField(inputGrid, 'Rent growth (%/yr)', 2, -100, Inf, @() app.updateForward());
    app.Forward.expenseInflationPct = rentalapp.addNumericField(inputGrid, 'Expense inflation (%/yr)', 2, -100, Inf, @() app.updateForward());
    app.Forward.appreciationPct = rentalapp.addNumericField(inputGrid, 'Appreciation (%/yr)', 2, -100, Inf, @() app.updateForward());
    app.Forward.horizonYears = rentalapp.addNumericField(inputGrid, 'Analysis horizon (years)', 30, 1, 60, @() app.updateForward());

    metricsPanel = uipanel(left, 'Title', 'Summary');
    metricsGrid = uigridlayout(metricsPanel, [8 2]);
    metricsGrid.ColumnWidth = {'1x', 130};
    metricsGrid.RowHeight = repmat({20}, 1, 8);
    metricsGrid.Padding = [10 8 10 8];
    app.Forward.metricInitialCash = rentalapp.addMetricLabel(metricsGrid, 'Initial cash invested');
    app.Forward.metricMortgage = rentalapp.addMetricLabel(metricsGrid, 'Monthly mortgage');
    app.Forward.metricNOI = rentalapp.addMetricLabel(metricsGrid, 'NOI / month');
    app.Forward.metricCashFlow = rentalapp.addMetricLabel(metricsGrid, 'Cash flow / month');
    app.Forward.metricCapRate = rentalapp.addMetricLabel(metricsGrid, 'Cap rate');
    app.Forward.metricCashOnCash = rentalapp.addMetricLabel(metricsGrid, 'Cash-on-cash');
    app.Forward.metricDSCR = rentalapp.addMetricLabel(metricsGrid, 'DSCR');
    app.Forward.metricBreakEven = rentalapp.addMetricLabel(metricsGrid, 'Break even');

    app.Forward.status = uilabel(left, 'Text', '', 'FontColor', [0.55 0.08 0.08]);

    right = uigridlayout(main, [2 2]);
    right.RowHeight = {'1x', '1x'};
    right.ColumnWidth = {'1x', '1x'};
    right.RowSpacing = 12;
    right.ColumnSpacing = 12;

    app.Forward.cashAxis = uiaxes(right);
    title(app.Forward.cashAxis, 'Cumulative cash flow');
    xlabel(app.Forward.cashAxis, 'Year');
    ylabel(app.Forward.cashAxis, 'Cash flow');

    app.Forward.monthlyAxis = uiaxes(right);
    title(app.Forward.monthlyAxis, 'Monthly performance');
    xlabel(app.Forward.monthlyAxis, 'Year');
    ylabel(app.Forward.monthlyAxis, 'Amount / month');

    app.Forward.equityAxis = uiaxes(right);
    title(app.Forward.equityAxis, 'Equity and net position');
    xlabel(app.Forward.equityAxis, 'Year');
    ylabel(app.Forward.equityAxis, 'Amount');

    app.Forward.returnAxis = uiaxes(right);
    title(app.Forward.returnAxis, 'Annual cash-on-cash return');
    xlabel(app.Forward.returnAxis, 'Year');
    ylabel(app.Forward.returnAxis, 'Return (%)');
end
