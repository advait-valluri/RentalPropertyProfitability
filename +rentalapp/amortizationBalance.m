function balance = amortizationBalance(principal, annualRatePct, termYears, months)
    n = max(1, round(termYears * 12));
    m = (1:months)';
    monthlyRate = annualRatePct / 100 / 12;
    payment = rentalapp.mortgagePayment(principal, annualRatePct, termYears);

    if principal <= 0
        balance = zeros(months, 1);
    elseif abs(monthlyRate) < eps
        balance = max(0, principal - payment * m);
    else
        balance = principal * (1 + monthlyRate).^m - payment * (((1 + monthlyRate).^m - 1) / monthlyRate);
        balance(m >= n) = 0;
        balance = max(0, balance);
    end
end
