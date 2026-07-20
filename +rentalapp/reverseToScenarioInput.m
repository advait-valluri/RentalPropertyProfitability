function scenarioIn = reverseToScenarioInput(in, price)
    scenarioIn = in;
    scenarioIn.purchasePrice = price;
    scenarioIn.rentGrowthPct = 0;
    scenarioIn.expenseInflationPct = 0;
    scenarioIn.appreciationPct = 0;
    scenarioIn.horizonYears = 30;
end
