function setTransferTaxFromState(app, sectionName)
    rate = rentalapp.germanTransferTaxRate(app.(sectionName).state.Value);
    app.(sectionName).transferTaxPct.Value = rate;

    if strcmp(sectionName, 'Forward')
        app.updateForward();
    else
        app.updateReverse();
    end
end
