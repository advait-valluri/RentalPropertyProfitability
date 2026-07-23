function validateInputs(in)
    if in.purchasePrice < 0
        error('purchase price must be non-negative.');
    end
    if in.downPaymentPct < 0 || in.downPaymentPct > 100
        error('down payment must be between 0 and 100 percent.');
    end
    if in.buildingSharePct < 0 || in.buildingSharePct > 100
        error('building share for AfA must be between 0 and 100 percent.');
    end
    if in.marginalTaxRatePct < 0 || in.marginalTaxRatePct > 100
        error('marginal tax rate must be between 0 and 100 percent.');
    end
    if in.vacancyPct < 0 || in.vacancyPct > 100
        error('vacancy must be between 0 and 100 percent.');
    end
    if in.hoaTransferablePct < 0 || in.hoaTransferablePct > 100
        error('HOA transferable share must be between 0 and 100 percent.');
    end
    if in.annualMaintenanceCosts < 0
        error('maintenance costs must be non-negative.');
    end
    if in.buildingCompletionYear < 1800 || in.buildingCompletionYear > 2100
        error('building completion year must be between 1800 and 2100.');
    end
    if in.loanTermYears <= 0
        error('loan term must be positive.');
    end
    if in.horizonYears <= 0
        error('analysis horizon must be positive.');
    end
end
