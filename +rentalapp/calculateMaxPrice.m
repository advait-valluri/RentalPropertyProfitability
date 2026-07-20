function result = calculateMaxPrice(in)
    result = struct();
    result.status = '';

    basePrice = max(100000, in.monthlyRent * 120);
    low = 0;
    high = basePrice;
    while reverseObjective(high, in) >= 0 && high < 100000000
        high = high * 2;
    end

    if reverseObjective(low, in) < 0
        result.maxPrice = NaN;
        result.scenario = [];
        result.status = 'Not feasible with the current fixed costs and target.';
        return;
    end

    if high >= 100000000 && reverseObjective(high, in) >= 0
        result.maxPrice = high;
        result.status = 'Result is above the search limit.';
    else
        for k = 1:80
            mid = (low + high) / 2;
            if reverseObjective(mid, in) >= 0
                low = mid;
            else
                high = mid;
            end
        end
        result.maxPrice = low;
    end

    scenarioIn = rentalapp.reverseToScenarioInput(in, result.maxPrice);
    result.scenario = rentalapp.calculateScenario(scenarioIn);
end

function value = reverseObjective(price, in)
    scenario = rentalapp.evaluateFirstMonth(price, in);
    if strcmp(in.mode, 'Break-even cash flow')
        value = scenario.cashFlow;
    else
        value = scenario.cashOnCash - in.targetReturnPct;
    end
end
