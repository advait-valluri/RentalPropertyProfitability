function result = calculateScenario(in)
    rentalapp.validateInputs(in);

    months = max(1, round(in.horizonYears * 12));
    monthIndex = (1:months)';
    years = monthIndex / 12;

    purchasePrice = in.purchasePrice;
    downPayment = purchasePrice * in.downPaymentPct / 100;
    loanAmount = max(0, purchasePrice - downPayment);
    monthlyMortgage = rentalapp.mortgagePayment(loanAmount, in.interestRate, in.loanTermYears);
    loanBalance = rentalapp.amortizationBalance(loanAmount, in.interestRate, in.loanTermYears, months);

    closingCostPct = in.transferTaxPct + in.notaryPct + in.landRegistryPct;
    closingCosts = purchasePrice * closingCostPct / 100;
    agentCommission = purchasePrice * 0.0357 * double(in.includeAgent);
    initialCash = downPayment + closingCosts + agentCommission + in.renovationCosts;

    rent = rentalapp.monthlySeries(in.monthlyRent, in.rentGrowthPct, months);
    effectiveRent = rent .* (1 - in.vacancyPct / 100);

    fixedExpenseBase = in.hoaContribution * (1 - in.hoaTransferablePct / 100);
    fixedExpenses = rentalapp.monthlySeries(fixedExpenseBase, in.expenseInflationPct, months);
    operatingExpenses = fixedExpenses;

    grossIncome = effectiveRent;
    noi = grossIncome - operatingExpenses;
    debtService = repmat(monthlyMortgage, months, 1);
    cashFlow = noi - debtService;
    cumulativeCashFlow = cumsum(cashFlow) - initialCash;

    propertyValue = purchasePrice * (1 + in.appreciationPct / 100) .^ years;
    equity = propertyValue - loanBalance;
    netPosition = equity + cumsum(cashFlow) - initialCash;

    breakEvenIdx = find(cumulativeCashFlow >= 0, 1, 'first');
    if isempty(breakEvenIdx)
        breakEvenText = 'Not reached';
        breakEvenYear = NaN;
    else
        breakEvenYear = breakEvenIdx / 12;
        breakEvenText = sprintf('%.1f years', breakEvenYear);
    end

    firstMonthNOI = noi(1);
    firstMonthCashFlow = cashFlow(1);
    annualCashOnCash = rentalapp.safeDivide(firstMonthCashFlow * 12, initialCash) * 100;
    capRate = rentalapp.safeDivide(firstMonthNOI * 12, purchasePrice) * 100;
    dscr = rentalapp.safeDivide(firstMonthNOI, monthlyMortgage);
    annualCashOnCashSeries = rentalapp.annualizeByYear(cashFlow, initialCash);

    result = struct();
    result.months = monthIndex;
    result.years = years;
    result.initialCash = initialCash;
    result.closingCosts = closingCosts;
    result.agentCommission = agentCommission;
    result.loanAmount = loanAmount;
    result.monthlyMortgage = monthlyMortgage;
    result.grossIncome = grossIncome;
    result.operatingExpenses = operatingExpenses;
    result.noi = noi;
    result.debtService = debtService;
    result.cashFlow = cashFlow;
    result.cumulativeCashFlow = cumulativeCashFlow;
    result.equity = equity;
    result.netPosition = netPosition;
    result.breakEvenIdx = breakEvenIdx;
    result.breakEvenYear = breakEvenYear;
    result.breakEvenText = breakEvenText;
    result.cashOnCash = annualCashOnCash;
    result.capRate = capRate;
    result.dscr = dscr;
    result.annualCashOnCashSeries = annualCashOnCashSeries;
end
