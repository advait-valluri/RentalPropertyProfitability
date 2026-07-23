function createReverseTab(app)
    main = uigridlayout(app.ReverseTab, [1 2]);
    main.ColumnWidth = {460, '1x'};
    main.Padding = [8 8 8 8];
    main.ColumnSpacing = 12;

    left = uigridlayout(main, [3 1]);
    left.RowHeight = {'1x', 285, 34};
    left.RowSpacing = 8;

    inputPanel = uipanel(left, 'Title', 'Reverse inputs');
    inputPanel.Scrollable = 'on';
    inputGrid = uigridlayout(inputPanel, [23 2]);
    inputGrid.Scrollable = 'on';
    inputGrid.ColumnWidth = {'1x', 155};
    inputGrid.RowHeight = repmat({30}, 1, 23);
    inputGrid.Padding = [10 8 10 8];
    inputGrid.RowSpacing = 5;

    uilabel(inputGrid, 'Text', 'Goal');
    app.Reverse.mode = uidropdown(inputGrid, ...
        'Items', {'Break-even cash flow', 'Target cash-on-cash'}, ...
        'Value', 'Break-even cash flow', ...
        'ValueChangedFcn', @(~, ~) app.updateReverse());

    app.Reverse.monthlyRent = rentalapp.addNumericField(inputGrid, 'Monthly rent', 1800, 0, Inf, @() app.updateReverse());
    app.Reverse.targetReturnPct = rentalapp.addNumericField(inputGrid, 'Target return (%/yr)', 8, 0, Inf, @() app.updateReverse());
    app.Reverse.downPaymentPct = rentalapp.addNumericField(inputGrid, 'Down payment (%)', 0, 0, 100, @() app.updateReverse());
    app.Reverse.interestRate = rentalapp.addNumericField(inputGrid, 'Interest rate (%)', 4.5, 0, Inf, @() app.updateReverse());

    uilabel(inputGrid, 'Text', 'Financing mode');
    app.Reverse.financingMode = uidropdown(inputGrid, ...
        'Items', {'Loan term', 'Interest + Tilgung'}, ...
        'Value', 'Loan term', ...
        'ValueChangedFcn', @(~, ~) rentalapp.setFinancingMode(app, 'Reverse'));
    app.Reverse.loanTermYears = rentalapp.addNumericField(inputGrid, 'Loan term (years)', 30, 1, Inf, @() app.updateReverse());
    app.Reverse.initialTilgungPct = rentalapp.addNumericField(inputGrid, 'Initial Tilgung (%/yr)', 2, 0, 100, @() app.updateReverse());
    app.Reverse.minimumTilgungPct = rentalapp.addNumericField(inputGrid, 'Minimum Tilgung (%/yr)', 1, 0, 100, @() app.updateReverse());

    uilabel(inputGrid, 'Text', 'German federal state');
    app.Reverse.state = uidropdown(inputGrid, ...
        'Items', rentalapp.germanTransferTaxStateNames(), ...
        'Value', 'Bavaria', ...
        'ValueChangedFcn', @(~, ~) rentalapp.setTransferTaxFromState(app, 'Reverse'));
    app.Reverse.transferTaxPct = rentalapp.addNumericField(inputGrid, 'Real estate transfer tax (%) [closing only]', 3.5, 0, Inf, @() app.updateReverse());
    app.Reverse.notaryPct = rentalapp.addNumericField(inputGrid, 'Notary cost (%)', 1.5, 0, Inf, @() app.updateReverse());
    app.Reverse.landRegistryPct = rentalapp.addNumericField(inputGrid, 'Land registry cost (%)', 0.5, 0, Inf, @() app.updateReverse());

    uilabel(inputGrid, 'Text', 'Agent commission');
    app.Reverse.includeAgent = uicheckbox(inputGrid, ...
        'Text', '3.57%', ...
        'Value', false, ...
        'ValueChangedFcn', @(~, ~) app.updateReverse());

    app.Reverse.renovationCosts = rentalapp.addNumericField(inputGrid, 'Renovation costs (one time)', 10000, 0, Inf, @() app.updateReverse());
    app.Reverse.hoaContribution = rentalapp.addNumericField(inputGrid, 'HOA contribution / month', 350, 0, Inf, @() app.updateReverse());
    app.Reverse.hoaTransferablePct = rentalapp.addPercentSlider(inputGrid, 'HOA transferable to tenant (%)', 80, @() app.updateReverse());
    app.Reverse.annualMaintenanceCosts = rentalapp.addNumericField(inputGrid, 'Maintenance costs / year', 3000, 0, Inf, @() app.updateReverse());
    app.Reverse.buildingSharePct = rentalapp.addNumericField(inputGrid, 'Building share for AfA (%)', 80, 0, 100, @() app.updateReverse());
    app.Reverse.buildingCompletionYear = rentalapp.addNumericField(inputGrid, 'Building completion year', 1995, 1800, 2100, @() app.updateReverse());
    app.Reverse.marginalTaxRatePct = rentalapp.addNumericField(inputGrid, 'Marginal tax rate (%) [tax saving only]', 42, 0, 100, @() app.updateReverse());
    app.Reverse.vacancyPct = rentalapp.addNumericField(inputGrid, 'Vacancy (%)', 5, 0, 100, @() app.updateReverse());

    metricsPanel = uipanel(left, 'Title', 'Result');
    metricsPanel.Scrollable = 'on';
    metricsGrid = uigridlayout(metricsPanel, [9 2]);
    metricsGrid.Scrollable = 'on';
    metricsGrid.ColumnWidth = {'1x', 160};
    metricsGrid.RowHeight = repmat({26}, 1, 9);
    metricsGrid.Padding = [10 10 10 10];
    app.Reverse.metricMaxPrice = rentalapp.addMetricLabel(metricsGrid, 'Maximum price');
    app.Reverse.metricInitialCash = rentalapp.addMetricLabel(metricsGrid, 'Initial cash invested');
    app.Reverse.metricMortgage = rentalapp.addMetricLabel(metricsGrid, 'Monthly mortgage');
    app.Reverse.metricTilgung = rentalapp.addMetricLabel(metricsGrid, 'First-year Tilgung');
    app.Reverse.metricDeductibleCosts = rentalapp.addMetricLabel(metricsGrid, 'Deductible costs / year 1');
    app.Reverse.metricTaxSaving = rentalapp.addMetricLabel(metricsGrid, 'Tax saving / month');
    app.Reverse.metricCashFlow = rentalapp.addMetricLabel(metricsGrid, 'After-tax cash flow / month');
    app.Reverse.metricCashOnCash = rentalapp.addMetricLabel(metricsGrid, 'After-tax cash-on-cash');
    app.Reverse.metricDSCR = rentalapp.addMetricLabel(metricsGrid, 'DSCR');

    app.Reverse.status = uilabel(left, 'Text', '', 'FontColor', [0.55 0.08 0.08]);

    right = uigridlayout(main, [2 1]);
    right.RowHeight = {'1x', '1x'};
    right.RowSpacing = 12;

    app.Reverse.priceRentAxis = uiaxes(right);
    title(app.Reverse.priceRentAxis, 'Maximum price versus rent');
    xlabel(app.Reverse.priceRentAxis, 'Monthly rent');
    ylabel(app.Reverse.priceRentAxis, 'Maximum purchase price');

    app.Reverse.sensitivityAxis = uiaxes(right);
    title(app.Reverse.sensitivityAxis, 'Sensitivity around maximum price');
    xlabel(app.Reverse.sensitivityAxis, 'Purchase price');
    ylabel(app.Reverse.sensitivityAxis, 'Metric');

    rentalapp.setFinancingMode(app, 'Reverse', false);
end
