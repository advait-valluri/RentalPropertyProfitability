function createReverseTab(app)
    main = uigridlayout(app.ReverseTab, [1 2]);
    main.ColumnWidth = {430, '1x'};
    main.Padding = [8 8 8 8];
    main.ColumnSpacing = 12;

    left = uigridlayout(main, [3 1]);
    left.RowHeight = {470, 154, 24};
    left.RowSpacing = 8;

    inputPanel = uipanel(left, 'Title', 'Reverse inputs');
    inputPanel.Scrollable = 'on';
    inputGrid = uigridlayout(inputPanel, [17 2]);
    inputGrid.Scrollable = 'on';
    inputGrid.ColumnWidth = {'1x', 130};
    inputGrid.RowHeight = repmat({26}, 1, 17);
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
    app.Reverse.auxCostPct = rentalapp.addNumericField(inputGrid, 'Auxiliary costs (%)', 5, 0, Inf, @() app.updateReverse());

    uilabel(inputGrid, 'Text', 'Agent commission');
    app.Reverse.includeAgent = uicheckbox(inputGrid, ...
        'Text', '3.57%', ...
        'Value', true, ...
        'ValueChangedFcn', @(~, ~) app.updateReverse());

    app.Reverse.closingCosts = rentalapp.addNumericField(inputGrid, 'Fixed closing costs', 0, 0, Inf, @() app.updateReverse());
    app.Reverse.renovationCosts = rentalapp.addNumericField(inputGrid, 'Renovation/repairs', 10000, 0, Inf, @() app.updateReverse());
    app.Reverse.propertyTax = rentalapp.addNumericField(inputGrid, 'Property tax / month', 250, 0, Inf, @() app.updateReverse());
    app.Reverse.insurance = rentalapp.addNumericField(inputGrid, 'Insurance / month', 100, 0, Inf, @() app.updateReverse());
    app.Reverse.hoa = rentalapp.addNumericField(inputGrid, 'HOA / month', 0, 0, Inf, @() app.updateReverse());
    app.Reverse.utilities = rentalapp.addNumericField(inputGrid, 'Utilities/other / month', 100, 0, Inf, @() app.updateReverse());
    app.Reverse.vacancyPct = rentalapp.addNumericField(inputGrid, 'Vacancy (%)', 5, 0, 100, @() app.updateReverse());
    app.Reverse.maintenancePct = rentalapp.addNumericField(inputGrid, 'Maintenance (% rent)', 5, 0, Inf, @() app.updateReverse());
    app.Reverse.capexPct = rentalapp.addNumericField(inputGrid, 'CapEx reserve (% rent)', 5, 0, Inf, @() app.updateReverse());
    app.Reverse.managementPct = rentalapp.addNumericField(inputGrid, 'Management (% rent)', 8, 0, Inf, @() app.updateReverse());

    metricsPanel = uipanel(left, 'Title', 'Result');
    metricsGrid = uigridlayout(metricsPanel, [6 2]);
    metricsGrid.ColumnWidth = {'1x', 130};
    metricsGrid.RowHeight = repmat({20}, 1, 6);
    metricsGrid.Padding = [10 8 10 8];
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
