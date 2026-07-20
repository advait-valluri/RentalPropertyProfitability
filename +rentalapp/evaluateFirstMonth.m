function result = evaluateFirstMonth(price, in)
    scenarioIn = rentalapp.reverseToScenarioInput(in, price);
    rentalapp.validateInputs(scenarioIn);

    downPayment = price * in.downPaymentPct / 100;
    loanAmount = max(0, price - downPayment);
    monthlyMortgage = rentalapp.mortgagePayment(loanAmount, in.interestRate, in.loanTermYears);

    auxCosts = price * in.auxCostPct / 100;
    agentCommission = price * 0.0357 * double(in.includeAgent);
    initialCash = downPayment + auxCosts + agentCommission + in.closingCosts + in.renovationCosts;

    effectiveRent = in.monthlyRent * (1 - in.vacancyPct / 100);
    variableExpenses = in.monthlyRent * ((in.maintenancePct + in.capexPct + in.managementPct) / 100);
    fixedExpenses = in.propertyTax + in.insurance + in.hoa + in.utilities;
    noi = effectiveRent - fixedExpenses - variableExpenses;
    cashFlow = noi - monthlyMortgage;

    result = struct();
    result.initialCash = initialCash;
    result.monthlyMortgage = monthlyMortgage;
    result.noi = noi;
    result.cashFlow = cashFlow;
    result.cashOnCash = rentalapp.safeDivide(cashFlow * 12, initialCash) * 100;
    result.dscr = rentalapp.safeDivide(noi, monthlyMortgage);
end
