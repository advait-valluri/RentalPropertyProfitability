function plotReverse(app, in, result)
    ax = app.Reverse.priceRentAxis;
    cla(ax);
    rentValues = linspace(max(0, in.monthlyRent * 0.5), max(1, in.monthlyRent * 1.5), 25);
    priceValues = NaN(size(rentValues));
    temp = in;
    for idx = 1:numel(rentValues)
        temp.monthlyRent = rentValues(idx);
        tempResult = rentalapp.calculateMaxPrice(temp);
        priceValues(idx) = tempResult.maxPrice;
    end
    plot(ax, rentValues, priceValues, 'LineWidth', 1.7);
    hold(ax, 'on');
    if ~isempty(result.scenario)
        plot(ax, in.monthlyRent, result.maxPrice, 'o', 'MarkerSize', 8, 'LineWidth', 1.8);
    end
    hold(ax, 'off');
    grid(ax, 'on');
    title(ax, 'Maximum price versus rent');
    xlabel(ax, ['Monthly rent (' app.Currency ')']);
    ylabel(ax, ['Maximum price (' app.Currency ')']);

    ax = app.Reverse.sensitivityAxis;
    cla(ax);
    if isempty(result.scenario)
        title(ax, 'Sensitivity around maximum price');
        return;
    end

    priceRange = linspace(max(0, result.maxPrice * 0.75), max(1, result.maxPrice * 1.25), 50);
    cashFlowValues = NaN(size(priceRange));
    returnValues = NaN(size(priceRange));
    for idx = 1:numel(priceRange)
        scenario = rentalapp.evaluateFirstMonth(priceRange(idx), in);
        cashFlowValues(idx) = scenario.cashFlow;
        returnValues(idx) = scenario.cashOnCash;
    end

    yyaxis(ax, 'left');
    plot(ax, priceRange, cashFlowValues, 'LineWidth', 1.5);
    ylabel(ax, ['After-tax cash flow / month (' app.Currency ')']);
    yline(ax, 0, '--');

    yyaxis(ax, 'right');
    plot(ax, priceRange, returnValues, 'LineWidth', 1.5);
    ylabel(ax, 'After-tax cash-on-cash (%)');
    if strcmp(in.mode, 'Target cash-on-cash')
        yline(ax, in.targetReturnPct, '--');
    end

    grid(ax, 'on');
    title(ax, 'Sensitivity around maximum price');
    xlabel(ax, ['Purchase price (' app.Currency ')']);
end
