function payment = mortgagePayment(principal, annualRatePct, termYears)
    n = max(1, round(termYears * 12));
    monthlyRate = annualRatePct / 100 / 12;
    if principal <= 0
        payment = 0;
    elseif abs(monthlyRate) < eps
        payment = principal / n;
    else
        payment = principal * monthlyRate * (1 + monthlyRate)^n / ((1 + monthlyRate)^n - 1);
    end
end
