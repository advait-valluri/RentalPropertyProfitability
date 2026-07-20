function validateInputs(in)
    if in.purchasePrice < 0
        error('purchase price must be non-negative.');
    end
    if in.downPaymentPct < 0 || in.downPaymentPct > 100
        error('down payment must be between 0 and 100 percent.');
    end
    if in.vacancyPct < 0 || in.vacancyPct > 100
        error('vacancy must be between 0 and 100 percent.');
    end
    if in.loanTermYears <= 0
        error('loan term must be positive.');
    end
    if in.horizonYears <= 0
        error('analysis horizon must be positive.');
    end
end
