function result = evaluateFirstMonth(price, in)
    scenarioIn = rentalapp.reverseToScenarioInput(in, price);
    rentalapp.validateInputs(scenarioIn);

    downPayment = price * in.downPaymentPct / 100;
    loanAmount = max(0, price - downPayment);
    monthlyMortgage = rentalapp.mortgagePayment(loanAmount, in.interestRate, in.loanTermYears);

    closingCostPct = in.transferTaxPct + in.notaryPct + in.landRegistryPct;
    closingCosts = price * closingCostPct / 100;
    agentCommission = price * 0.0357 * double(in.includeAgent);
    initialCash = downPayment + closingCosts + agentCommission + in.renovationCosts;

    effectiveRent = in.monthlyRent * (1 - in.vacancyPct / 100);
    ownerHoaExpense = in.hoaContribution * (1 - in.hoaTransferablePct / 100);
    maintenanceExpense = in.annualMaintenanceCosts / 12;
    operatingExpenses = ownerHoaExpense + maintenanceExpense;
    noi = effectiveRent - operatingExpenses;
    preTaxCashFlow = noi - monthlyMortgage;
    interestExpense = rentalapp.amortizationInterest(loanAmount, in.interestRate, in.loanTermYears, 1);
    taxBenefits = rentalapp.taxWriteOffs(in, price, interestExpense, operatingExpenses);
    cashFlow = preTaxCashFlow + taxBenefits.taxSavings;

    result = struct();
    result.initialCash = initialCash;
    result.monthlyMortgage = monthlyMortgage;
    result.noi = noi;
    result.taxDeductibleAmount = taxBenefits.taxDeductibleAmount;
    result.taxSavings = taxBenefits.taxSavings;
    result.cashFlow = cashFlow;
    result.cashOnCash = rentalapp.safeDivide(cashFlow * 12, initialCash) * 100;
    result.dscr = rentalapp.safeDivide(noi, monthlyMortgage);
end
