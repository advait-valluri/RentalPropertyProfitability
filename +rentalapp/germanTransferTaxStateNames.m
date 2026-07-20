function names = germanTransferTaxStateNames()
    data = rentalapp.germanTransferTaxRates();
    names = data(:, 1)';
end
