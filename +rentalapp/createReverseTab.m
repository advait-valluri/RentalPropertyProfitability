function createReverseTab(app)
    main = uigridlayout(app.ReverseTab, [1 2]);
    main.ColumnWidth = {460, '1x'};
    main.Padding = [8 8 8 8];
    main.ColumnSpacing = 12;

    left = uigridlayout(main, [3 1]);
    left.RowHeight = {'1x', 205, 34};
    left.RowSpacing = 8;

    inputPanel = uipanel(left, 'Title', 'Reverse inputs');
    inputPanel.Scrollable = 'on';
    inputGrid = uigridlayout(inputPanel, [16 2]);
    inputGrid.Scrollable = 'on';
    inputGrid.ColumnWidth = {'1x', 155};
    inputGrid.RowHeight = repmat({30}, 1, 16);
    inputGrid.Padding = [10 8 10 8];
    inputGrid.RowSpacing = 5;

    uilabel(inputGrid, 'Text', 'Goal');
    app.Reverse.mode = uidropdown(inputGrid, ...
        'Items', {'Break-even cash flow', 'Target cash-on-cash'}, ...
        'Value', 'Break-even cash flow', ...
        'ValueChangedFcn', @(~, ~) app.updateReverse());

    app.Reverse.monthlyRent = rentalapp.addNumericField(inputGrid, 'Monthly rent', 1800, 0, Inf, @() app.updateReverse());
    app.Reverse.targetReturnPct = rentalapp.addNumericField(inputGrid, 'Target return (%/yr)', 8, 0, Inf, @() app.updateReverse());
    app.Reverse.downPaymentPct = rentalapp.addNumericField(inputGrid, 'Down payment (%)', 20, 0, 100, @() app.updateReverse());
    app.Reverse.interestRate = rentalapp.addNumericField(inputGrid, 'Interest rate (%)', 4.5, 0, Inf, @() app.updateReverse());
    app.Reverse.loanTermYears = rentalapp.addNumericField(inputGrid, 'Loan term (years)', 30, 1, Inf, @() app.updateReverse());

    uilabel(inputGrid, 'Text', 'German federal state');
    app.Reverse.state = uidropdown(inputGrid, ...
        'Items', rentalapp.germanTransferTaxStateNames(), ...
        'Value', 'North Rhine-Westphalia', ...
        'ValueChangedFcn', @(~, ~) rentalapp.setTransferTaxFromState(app, 'Reverse'));
    app.Reverse.transferTaxPct = rentalapp.addNumericField(inputGrid, 'Real estate transfer tax (%)', 6.5, 0, Inf, @() app.updateReverse());
    app.Reverse.notaryPct = rentalapp.addNumericField(inputGrid, 'Notary cost (%)', 1.5, 0, Inf, @() app.updateReverse());
    app.Reverse.landRegistryPct = rentalapp.addNumericField(inputGrid, 'Land registry cost (%)', 0.5, 0, Inf, @() app.updateReverse());

    uilabel(inputGrid, 'Text', 'Agent commission');
    app.Reverse.includeAgent = uicheckbox(inputGrid, ...
        'Text', '3.57%', ...
        'Value', true, ...
        'ValueChangedFcn', @(~, ~) app.updateReverse());

    app.Reverse.renovationCosts = rentalapp.addNumericField(inputGrid, 'Renovation costs (one time)', 10000, 0, Inf, @() app.updateReverse());
    app.Reverse.hoaContribution = rentalapp.addNumericField(inputGrid, 'HOA contribution / month', 350, 0, Inf, @() app.updateReverse());
    app.Reverse.hoaTransferablePct = rentalapp.addPercentSlider(inputGrid, 'HOA transferable to tenant (%)', 60, @() app.updateReverse());
    app.Reverse.vacancyPct = rentalapp.addNumericField(inputGrid, 'Vacancy (%)', 5, 0, 100, @() app.updateReverse());

    metricsPanel = uipanel(left, 'Title', 'Result');
    metricsPanel.Scrollable = 'on';
    metricsGrid = uigridlayout(metricsPanel, [6 2]);
    metricsGrid.Scrollable = 'on';
    metricsGrid.ColumnWidth = {'1x', 160};
    metricsGrid.RowHeight = repmat({26}, 1, 6);
    metricsGrid.Padding = [10 10 10 10];
    app.Reverse.metricMaxPrice = rentalapp.addMetricLabel(metricsGrid, 'Maximum price');
    app.Reverse.metricInitialCash = rentalapp.addMetricLabel(metricsGrid, 'Initial cash invested');
    app.Reverse.metricMortgage = rentalapp.addMetricLabel(metricsGrid, 'Monthly mortgage');
    app.Reverse.metricCashFlow = rentalapp.addMetricLabel(metricsGrid, 'Cash flow / month');
    app.Reverse.metricCashOnCash = rentalapp.addMetricLabel(metricsGrid, 'Cash-on-cash');
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
end
