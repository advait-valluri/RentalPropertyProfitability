function createForwardTab(app)
    main = uigridlayout(app.ForwardTab, [1 2]);
    main.ColumnWidth = {460, '1x'};
    main.Padding = [8 8 8 8];
    main.ColumnSpacing = 12;

    left = uigridlayout(main, [3 1]);
    left.RowHeight = {'1x', 410, 34};
    left.RowSpacing = 8;

    inputPanel = uipanel(left, 'Title', 'Inputs');
    inputPanel.Scrollable = 'on';
    inputGrid = uigridlayout(inputPanel, [25 2]);
    inputGrid.Scrollable = 'on';
    inputGrid.ColumnWidth = {'1x', 155};
    inputGrid.RowHeight = repmat({30}, 1, 25);
    inputGrid.Padding = [10 8 10 8];
    inputGrid.RowSpacing = 5;

    app.Forward.purchasePrice = rentalapp.addNumericField(inputGrid, 'Purchase price', 300000, 0, Inf, @() app.updateForward());
    app.Forward.monthlyRent = rentalapp.addNumericField(inputGrid, 'Monthly rent', 1800, 0, Inf, @() app.updateForward());
    app.Forward.downPaymentPct = rentalapp.addNumericField(inputGrid, 'Down payment (%)', 0, 0, 100, @() app.updateForward());
    app.Forward.interestRate = rentalapp.addNumericField(inputGrid, 'Interest rate (%)', 4.5, 0, Inf, @() app.updateForward());

    uilabel(inputGrid, 'Text', 'Financing mode');
    app.Forward.financingMode = uidropdown(inputGrid, ...
        'Items', {'Loan term', 'Interest + Tilgung'}, ...
        'Value', 'Loan term', ...
        'ValueChangedFcn', @(~, ~) rentalapp.setFinancingMode(app, 'Forward'));
    app.Forward.loanTermYears = rentalapp.addNumericField(inputGrid, 'Loan term (years)', 30, 1, Inf, @() app.updateForward());
    app.Forward.initialTilgungPct = rentalapp.addNumericField(inputGrid, 'Initial Tilgung (%/yr)', 2, 0, 100, @() app.updateForward());
    app.Forward.minimumTilgungPct = rentalapp.addNumericField(inputGrid, 'Minimum Tilgung (%/yr)', 1, 0, 100, @() app.updateForward());

    uilabel(inputGrid, 'Text', 'German federal state');
    app.Forward.state = uidropdown(inputGrid, ...
        'Items', rentalapp.germanTransferTaxStateNames(), ...
        'Value', 'Bavaria', ...
        'ValueChangedFcn', @(~, ~) rentalapp.setTransferTaxFromState(app, 'Forward'));
    app.Forward.transferTaxPct = rentalapp.addNumericField(inputGrid, 'Real estate transfer tax (%) [closing only]', 3.5, 0, Inf, @() app.updateForward());
    app.Forward.notaryPct = rentalapp.addNumericField(inputGrid, 'Notary cost (%)', 1.5, 0, Inf, @() app.updateForward());
    app.Forward.landRegistryPct = rentalapp.addNumericField(inputGrid, 'Land registry cost (%)', 0.5, 0, Inf, @() app.updateForward());

    uilabel(inputGrid, 'Text', 'Agent commission');
    app.Forward.includeAgent = uicheckbox(inputGrid, ...
        'Text', '3.57%', ...
        'Value', false, ...
        'ValueChangedFcn', @(~, ~) app.updateForward());

    app.Forward.renovationCosts = rentalapp.addNumericField(inputGrid, 'Renovation costs (one time)', 10000, 0, Inf, @() app.updateForward());
    app.Forward.hoaContribution = rentalapp.addNumericField(inputGrid, 'HOA contribution / month', 350, 0, Inf, @() app.updateForward());
    app.Forward.hoaTransferablePct = rentalapp.addPercentSlider(inputGrid, 'HOA transferable to tenant (%)', 80, @() app.updateForward());
    app.Forward.annualMaintenanceCosts = rentalapp.addNumericField(inputGrid, 'Maintenance costs / year', 3000, 0, Inf, @() app.updateForward());
    app.Forward.buildingSharePct = rentalapp.addNumericField(inputGrid, 'Building share for AfA (%)', 80, 0, 100, @() app.updateForward());
    app.Forward.buildingCompletionYear = rentalapp.addNumericField(inputGrid, 'Building completion year', 1995, 1800, 2100, @() app.updateForward());
    app.Forward.marginalTaxRatePct = rentalapp.addNumericField(inputGrid, 'Marginal tax rate (%) [tax saving only]', 42, 0, 100, @() app.updateForward());
    app.Forward.vacancyPct = rentalapp.addNumericField(inputGrid, 'Vacancy (%)', 5, 0, 100, @() app.updateForward());
    app.Forward.rentGrowthPct = rentalapp.addNumericField(inputGrid, 'Rent growth (%/yr)', 2, -100, Inf, @() app.updateForward());
    app.Forward.expenseInflationPct = rentalapp.addNumericField(inputGrid, 'Expense inflation (%/yr)', 2, -100, Inf, @() app.updateForward());
    app.Forward.appreciationPct = rentalapp.addNumericField(inputGrid, 'Appreciation (%/yr)', 2, -100, Inf, @() app.updateForward());
    app.Forward.horizonYears = rentalapp.addNumericField(inputGrid, 'Analysis horizon (years)', 30, 1, 60, @() app.updateForward());

    metricsPanel = uipanel(left, 'Title', 'Summary');
    metricsPanel.Scrollable = 'on';
    metricsGrid = uigridlayout(metricsPanel, [14 2]);
    metricsGrid.Scrollable = 'on';
    metricsGrid.ColumnWidth = {'1x', 160};
    metricsGrid.RowHeight = repmat({26}, 1, 14);
    metricsGrid.Padding = [10 10 10 10];
    app.Forward.metricInitialCash = rentalapp.addMetricLabel(metricsGrid, 'Initial cash invested');
    app.Forward.metricMortgage = rentalapp.addMetricLabel(metricsGrid, 'Monthly mortgage');
    app.Forward.metricNOI = rentalapp.addMetricLabel(metricsGrid, 'NOI / month');
    app.Forward.metricTilgung = rentalapp.addMetricLabel(metricsGrid, 'First-year Tilgung');
    app.Forward.metricYear1Interest = rentalapp.addMetricLabel(metricsGrid, 'Interest paid / year 1');
    app.Forward.metricTotalInterest = rentalapp.addMetricLabel(metricsGrid, 'Total interest paid');
    app.Forward.metricAfa = rentalapp.addMetricLabel(metricsGrid, 'AfA / year');
    app.Forward.metricDeductibleCosts = rentalapp.addMetricLabel(metricsGrid, 'Deductible costs / year 1');
    app.Forward.metricTaxSaving = rentalapp.addMetricLabel(metricsGrid, 'Tax saving / month');
    app.Forward.metricCashFlow = rentalapp.addMetricLabel(metricsGrid, 'After-tax cash flow / month');
    app.Forward.metricCapRate = rentalapp.addMetricLabel(metricsGrid, 'Cap rate');
    app.Forward.metricCashOnCash = rentalapp.addMetricLabel(metricsGrid, 'After-tax cash-on-cash');
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

    rentalapp.setFinancingMode(app, 'Forward', false);
end
