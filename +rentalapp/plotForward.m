function plotForward(app, result)
    ax = app.Forward.cashAxis;
    cla(ax);
    plot(ax, result.years, result.cumulativeCashFlow, 'LineWidth', 1.8);
    hold(ax, 'on');
    yline(ax, 0, '--');
    if ~isempty(result.breakEvenIdx)
        plot(ax, result.breakEvenYear, 0, 'o', 'MarkerSize', 8, 'LineWidth', 1.8);
    end
    hold(ax, 'off');
    grid(ax, 'on');
    title(ax, 'Cumulative cash flow');
    xlabel(ax, 'Year');
    ylabel(ax, ['Cumulative ' app.Currency]);

    ax = app.Forward.monthlyAxis;
    cla(ax);
    plot(ax, result.years, [result.grossIncome result.operatingExpenses result.debtService result.cashFlow], 'LineWidth', 1.3);
    grid(ax, 'on');
    title(ax, 'Monthly performance');
    xlabel(ax, 'Year');
    ylabel(ax, [app.Currency ' / month']);
    legend(ax, {'Income', 'Operating expenses', 'Debt service', 'Cash flow'}, 'Location', 'best');

    ax = app.Forward.equityAxis;
    cla(ax);
    plot(ax, result.years, [result.equity result.netPosition], 'LineWidth', 1.5);
    grid(ax, 'on');
    title(ax, 'Equity and net position');
    xlabel(ax, 'Year');
    ylabel(ax, app.Currency);
    legend(ax, {'Equity', 'Equity + cash flow - initial cash'}, 'Location', 'best');

    ax = app.Forward.returnAxis;
    cla(ax);
    plot(ax, result.annualCashOnCashSeries(:, 1), result.annualCashOnCashSeries(:, 2), 'LineWidth', 1.6);
    yline(ax, 0, '--');
    grid(ax, 'on');
    title(ax, 'Annual cash-on-cash return');
    xlabel(ax, 'Year');
    ylabel(ax, 'Return (%)');
end
