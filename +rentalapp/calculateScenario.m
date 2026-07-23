function result = calculateScenario(in)
    rentalapp.validateInputs(in);

    months = max(1, round(in.horizonYears * 12));
    monthIndex = (1:months)';
    years = monthIndex / 12;

    purchasePrice = in.purchasePrice;
    downPayment = purchasePrice * in.downPaymentPct / 100;
    loanAmount = max(0, purchasePrice - downPayment);
    financeMonths = max(months, 12);
    financing = rentalapp.financingProfile( ...
        loanAmount, in.interestRate, in.financingMode, in.loanTermYears, in.initialTilgungPct, financeMonths);
    monthlyMortgage = financing.scheduledPayment;
    loanBalance = financing.balanceSeries(1:months);

    closingCostPct = in.transferTaxPct + in.notaryPct + in.landRegistryPct;
    closingCosts = purchasePrice * closingCostPct / 100;
    agentCommission = purchasePrice * 0.0357 * double(in.includeAgent);
    initialCash = downPayment + closingCosts + agentCommission + in.renovationCosts;

    rent = rentalapp.monthlySeries(in.monthlyRent, in.rentGrowthPct, months);
    effectiveRent = rent .* (1 - in.vacancyPct / 100);

    fixedExpenseBase = in.hoaContribution * (1 - in.hoaTransferablePct / 100);
    fixedExpenses = rentalapp.monthlySeries(fixedExpenseBase, in.expenseInflationPct, months);
    maintenanceExpenses = rentalapp.monthlySeries(in.annualMaintenanceCosts / 12, in.expenseInflationPct, months);
    operatingExpenses = fixedExpenses + maintenanceExpenses;
    interestExpenses = financing.interestSeries(1:months);
    taxBenefits = rentalapp.taxWriteOffs(in, purchasePrice, interestExpenses, operatingExpenses);

    grossIncome = effectiveRent;
    noi = grossIncome - operatingExpenses;
    debtService = financing.paymentSeries(1:months);
    preTaxCashFlow = noi - debtService;
    cashFlow = preTaxCashFlow + taxBenefits.taxSavings;
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
    dscr = rentalapp.safeDivide(firstMonthNOI, debtService(1));
    annualCashOnCashSeries = rentalapp.annualizeByYear(cashFlow, initialCash);
    firstYearTaxDeductible = sum(taxBenefits.taxDeductibleAmount(1:min(12, months)));
    firstYearTilgungPct = financing.firstYearTilgungPct;
    meetsTilgungConstraint = ~financing.hasLoan || firstYearTilgungPct + 1e-9 >= in.minimumTilgungPct;

    result = struct();
    result.months = monthIndex;
    result.years = years;
    result.initialCash = initialCash;
    result.closingCosts = closingCosts;
    result.agentCommission = agentCommission;
    result.loanAmount = loanAmount;
    result.monthlyMortgage = monthlyMortgage;
    result.financingMode = in.financingMode;
    result.grossIncome = grossIncome;
    result.operatingExpenses = operatingExpenses;
    result.noi = noi;
    result.preTaxCashFlow = preTaxCashFlow;
    result.debtService = debtService;
    result.interestExpenses = interestExpenses;
    result.principalPayments = financing.principalSeries(1:months);
    result.taxDeductibleAmount = taxBenefits.taxDeductibleAmount;
    result.taxSavings = taxBenefits.taxSavings;
    result.afaRatePct = taxBenefits.afaRatePct;
    result.annualAfa = taxBenefits.annualAfa;
    result.buildingBasis = taxBenefits.buildingBasis;
    result.firstYearTaxDeductible = firstYearTaxDeductible;
    result.firstYearTilgungPct = firstYearTilgungPct;
    result.meetsTilgungConstraint = meetsTilgungConstraint;
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
