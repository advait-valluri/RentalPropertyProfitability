classdef RentalPropertyApp < handle
    properties
        Currency = char(8364)
        Figure
        WindowToggle
        CompactFigurePosition
        Tabs
        ForwardTab
        ReverseTab
        SensitivityTab
        PaymentScheduleTab
        CalculationTab
        Forward = struct()
        Reverse = struct()
        Sensitivity = struct()
        PaymentSchedule = struct()
        Calculations = struct()
    end

    methods
        function obj = RentalPropertyApp()
            obj.Figure = uifigure( ...
                'Name', 'Rental Property Profitability', ...
                'Position', [80 60 1360 860], ...
                'Visible', 'off');

            obj.createFileMenu();

            root = uigridlayout(obj.Figure, [2 1]);
            root.RowHeight = {24, '1x'};
            root.Padding = [12 12 12 12];
            root.RowSpacing = 4;

            header = uigridlayout(root, [1 2]);
            header.ColumnWidth = {24, '1x'};
            header.Padding = [0 0 0 0];
            header.ColumnSpacing = 0;

            obj.Tabs = uitabgroup(root);
            obj.ForwardTab = uitab(obj.Tabs, 'Title', 'Forward calculation');
            obj.ReverseTab = uitab(obj.Tabs, 'Title', 'Max price from rent');
            obj.SensitivityTab = uitab(obj.Tabs, 'Title', 'Tilgung sensitivity');
            obj.PaymentScheduleTab = uitab(obj.Tabs, 'Title', 'Payment schedule');
            obj.CalculationTab = uitab(obj.Tabs, 'Title', 'Calculations');

            rentalapp.createForwardTab(obj);
            rentalapp.createReverseTab(obj);
            rentalapp.createSensitivityTab(obj);
            rentalapp.createPaymentScheduleTab(obj);
            rentalapp.createCalculationsTab(obj);

            obj.createWindowToggleButton(header);
            obj.refreshAll();
            obj.applyCompactWindowState();
            obj.syncWindowToggleState();
            obj.Figure.Visible = 'on';
        end

        function updateForward(obj)
            try
                in = rentalapp.readForwardInputs(obj);
                result = rentalapp.calculateScenario(in);
                rentalapp.setForwardMetrics(obj, result);
                rentalapp.plotForward(obj, result);
                rentalapp.setPaymentScheduleTable(obj, result);
                rentalapp.setCalculationTables(obj, in, result);
                obj.PaymentSchedule.status.Text = 'Monthly rows with yearly roll-ups';
                if result.meetsTilgungConstraint
                    obj.Forward.status.Text = '';
                else
                    obj.Forward.status.Text = sprintf('Minimum Tilgung not met: %.2f%% < %.2f%%.', ...
                        result.firstYearTilgungPct, in.minimumTilgungPct);
                end
            catch err
                obj.Forward.status.Text = ['Check inputs: ' err.message];
                obj.PaymentSchedule.table.Data = cell(0, 8);
                obj.PaymentSchedule.status.Text = ['Check inputs: ' err.message];
                if isfield(obj.Calculations, 'status')
                    obj.Calculations.status.Text = ['Check inputs: ' err.message];
                    obj.Calculations.acquisitionTable.Data = cell(0, 4);
                    obj.Calculations.operatingTable.Data = cell(0, 4);
                    obj.Calculations.taxTable.Data = cell(0, 4);
                    obj.Calculations.returnTable.Data = cell(0, 4);
                end
            end

            if ~isempty(obj.SensitivityTab)
                obj.updateSensitivity();
            end
        end

        function updateReverse(obj)
            try
                in = rentalapp.readReverseInputs(obj);
                result = rentalapp.calculateMaxPrice(in);
                rentalapp.setReverseMetrics(obj, result);
                rentalapp.plotReverse(obj, in, result);
                obj.Reverse.status.Text = result.status;
            catch err
                obj.Reverse.status.Text = ['Check inputs: ' err.message];
            end
        end

        function updateSensitivity(obj)
            try
                baseIn = rentalapp.readForwardInputs(obj);
                sensitivityIn = rentalapp.readSensitivityInputs(obj);
                result = rentalapp.calculateTilgungSensitivity(baseIn, sensitivityIn);
                rentalapp.setSensitivityMetrics(obj, result);
                rentalapp.plotSensitivity(obj, result);
                obj.Sensitivity.status.Text = '';
            catch err
                obj.Sensitivity.metricPaymentMin.Text = '-';
                obj.Sensitivity.metricPaymentMax.Text = '-';
                obj.Sensitivity.metricCashFlowMin.Text = '-';
                obj.Sensitivity.metricCashFlowMax.Text = '-';
                cla(obj.Sensitivity.axis);
                title(obj.Sensitivity.axis, 'Payment and cash flow versus Tilgung');
                obj.Sensitivity.status.Text = ['Check inputs: ' err.message];
            end
        end

        function refreshAll(obj)
            obj.updateForward();
            obj.updateReverse();
        end

        function createFileMenu(obj)
            fileMenu = uimenu(obj.Figure, 'Text', 'File');
            uimenu(fileMenu, 'Text', 'Load parameters...', 'MenuSelectedFcn', @(~, ~) obj.loadSession());
            uimenu(fileMenu, 'Text', 'Save parameters...', 'MenuSelectedFcn', @(~, ~) obj.saveSession());
            uimenu(fileMenu, 'Text', 'Exit', 'MenuSelectedFcn', @(~, ~) delete(obj.Figure));
        end

        function createWindowToggleButton(obj, parent)
            obj.WindowToggle = uibutton(parent, ...
                'Text', '', ...
                'Icon', obj.createResizeIcon(), ...
                'Tooltip', 'Maximize window', ...
                'ButtonPushedFcn', @(~, ~) obj.toggleWindowSize());
            obj.WindowToggle.Layout.Row = 1;
            obj.WindowToggle.Layout.Column = 1;
        end

        function toggleWindowSize(obj)
            if isempty(obj.Figure) || ~isvalid(obj.Figure)
                return;
            end

            if strcmp(obj.Figure.WindowState, 'maximized')
                obj.applyCompactWindowState();
                obj.setWindowButtonTooltip('Maximize window');
            else
                obj.Figure.WindowState = 'maximized';
                drawnow;
                obj.setWindowButtonTooltip('Restore compact window');
            end
        end

        function applyCompactWindowState(obj)
            monitorBounds = obj.getActiveMonitorBounds();
            compactPosition = obj.getCompactFigurePosition(monitorBounds);

            obj.Figure.WindowState = 'normal';
            drawnow;
            obj.Figure.Position = compactPosition;
            drawnow;
            obj.CompactFigurePosition = compactPosition;
        end

        function syncWindowToggleState(obj)
            if isempty(obj.WindowToggle) || ~isvalid(obj.WindowToggle)
                return;
            end

            if strcmp(obj.Figure.WindowState, 'maximized')
                obj.setWindowButtonTooltip('Restore compact window');
            else
                obj.setWindowButtonTooltip('Maximize window');
            end
        end

        function setWindowButtonTooltip(obj, tooltipText)
            obj.WindowToggle.Tooltip = tooltipText;
        end

        function monitorBounds = getActiveMonitorBounds(obj)
            monitors = get(groot, 'MonitorPositions');
            if isempty(monitors)
                monitorBounds = get(groot, 'ScreenSize');
                return;
            end

            referencePosition = obj.Figure.Position;
            centerX = referencePosition(1) + referencePosition(3) / 2;
            centerY = referencePosition(2) + referencePosition(4) / 2;

            containsCenter = centerX >= monitors(:, 1) & ...
                centerX <= monitors(:, 1) + monitors(:, 3) & ...
                centerY >= monitors(:, 2) & ...
                centerY <= monitors(:, 2) + monitors(:, 4);

            if any(containsCenter)
                monitorBounds = monitors(find(containsCenter, 1, 'first'), :);
                return;
            end

            monitorCenters = [monitors(:, 1) + monitors(:, 3) / 2, monitors(:, 2) + monitors(:, 4) / 2];
            [~, nearestIdx] = min(sum((monitorCenters - [centerX centerY]) .^ 2, 2));
            monitorBounds = monitors(nearestIdx, :);
        end

        function compactPosition = getCompactFigurePosition(~, monitorBounds)
            margin = 40;
            compactWidth = min(round(0.78 * monitorBounds(3)), 1360);
            compactHeight = min(round(0.82 * monitorBounds(4)), 860);

            maxWidth = max(700, monitorBounds(3) - margin);
            maxHeight = max(520, monitorBounds(4) - margin);
            compactWidth = min(compactWidth, maxWidth);
            compactHeight = min(compactHeight, maxHeight);

            compactX = monitorBounds(1) + (monitorBounds(3) - compactWidth) / 2;
            compactY = monitorBounds(2) + (monitorBounds(4) - compactHeight) / 2;
            compactPosition = round([compactX compactY compactWidth compactHeight]);
        end

        function icon = createResizeIcon(~)
            icon = nan(16, 16, 3);
            light = reshape([0.95 0.95 0.95], 1, 1, 3);
            dark = reshape([0.18 0.22 0.29], 1, 1, 3);
            accent = reshape([0.11 0.47 0.74], 1, 1, 3);

            icon(3:12, 3:12, :) = repmat(light, 10, 10);
            icon(5:14, 5:14, :) = repmat(light, 10, 10);

            icon(3, 3:12, :) = repmat(dark, 1, 10);
            icon(12, 3:12, :) = repmat(dark, 1, 10);
            icon(3:12, 3, :) = repmat(dark, 10, 1);
            icon(3:12, 12, :) = repmat(dark, 10, 1);

            icon(5, 5:14, :) = repmat(accent, 1, 10);
            icon(14, 5:14, :) = repmat(accent, 1, 10);
            icon(5:14, 5, :) = repmat(accent, 10, 1);
            icon(5:14, 14, :) = repmat(accent, 10, 1);
        end

        function saveSession(obj)
            defaultFileName = rentalapp.defaultFileName(obj.getPropertyAddress(), 'mat', 'session');
            [fileName, pathName] = uiputfile('*.mat', 'Save parameter set', defaultFileName);
            if isequal(fileName, 0)
                return;
            end

            session = obj.collectSession();
            save(fullfile(pathName, fileName), 'session');
        end

        function loadSession(obj)
            [fileName, pathName] = uigetfile('*.mat', 'Load parameter set');
            if isequal(fileName, 0)
                return;
            end

            try
                data = load(fullfile(pathName, fileName));
                if isfield(data, 'session')
                    session = data.session;
                else
                    names = fieldnames(data);
                    if isempty(names)
                        error('No session data found in the selected file.');
                    end
                    session = data.(names{1});
                end

                if ~isstruct(session)
                    error('The selected file does not contain a saved parameter struct.');
                end

                obj.applySession(session);
                obj.refreshAll();
            catch err
                uialert(obj.Figure, err.message, 'Load failed');
            end
        end

        function session = collectSession(obj)
            session = struct();
            session.version = 3;
            session.propertyAddress = obj.getPropertyAddress();
            session.selectedTab = obj.Tabs.SelectedTab.Title;
            session.forward = struct( ...
                'purchasePrice', obj.Forward.purchasePrice.Value, ...
                'monthlyRent', obj.Forward.monthlyRent.Value, ...
                'downPaymentPct', obj.Forward.downPaymentPct.Value, ...
                'interestRate', obj.Forward.interestRate.Value, ...
                'financingMode', obj.Forward.financingMode.Value, ...
                'loanTermYears', obj.Forward.loanTermYears.Value, ...
                'initialTilgungPct', obj.Forward.initialTilgungPct.Value, ...
                'minimumTilgungPct', obj.Forward.minimumTilgungPct.Value, ...
                'state', obj.Forward.state.Value, ...
                'transferTaxPct', obj.Forward.transferTaxPct.Value, ...
                'notaryPct', obj.Forward.notaryPct.Value, ...
                'landRegistryPct', obj.Forward.landRegistryPct.Value, ...
                'includeAgent', obj.Forward.includeAgent.Value, ...
                'renovationCosts', obj.Forward.renovationCosts.Value, ...
                'hoaContribution', obj.Forward.hoaContribution.Value, ...
                'hoaTransferablePct', obj.Forward.hoaTransferablePct.Field.Value, ...
                'annualMaintenanceCosts', obj.Forward.annualMaintenanceCosts.Value, ...
                'buildingSharePct', obj.Forward.buildingSharePct.Value, ...
                'buildingCompletionYear', obj.Forward.buildingCompletionYear.Value, ...
                'marginalTaxRatePct', obj.Forward.marginalTaxRatePct.Value, ...
                'vacancyPct', obj.Forward.vacancyPct.Value, ...
                'rentGrowthPct', obj.Forward.rentGrowthPct.Value, ...
                'expenseInflationPct', obj.Forward.expenseInflationPct.Value, ...
                'appreciationPct', obj.Forward.appreciationPct.Value, ...
                'horizonYears', obj.Forward.horizonYears.Value);
            session.reverse = struct( ...
                'mode', obj.Reverse.mode.Value, ...
                'monthlyRent', obj.Reverse.monthlyRent.Value, ...
                'targetReturnPct', obj.Reverse.targetReturnPct.Value, ...
                'downPaymentPct', obj.Reverse.downPaymentPct.Value, ...
                'interestRate', obj.Reverse.interestRate.Value, ...
                'financingMode', obj.Reverse.financingMode.Value, ...
                'loanTermYears', obj.Reverse.loanTermYears.Value, ...
                'initialTilgungPct', obj.Reverse.initialTilgungPct.Value, ...
                'minimumTilgungPct', obj.Reverse.minimumTilgungPct.Value, ...
                'state', obj.Reverse.state.Value, ...
                'transferTaxPct', obj.Reverse.transferTaxPct.Value, ...
                'notaryPct', obj.Reverse.notaryPct.Value, ...
                'landRegistryPct', obj.Reverse.landRegistryPct.Value, ...
                'includeAgent', obj.Reverse.includeAgent.Value, ...
                'renovationCosts', obj.Reverse.renovationCosts.Value, ...
                'hoaContribution', obj.Reverse.hoaContribution.Value, ...
                'hoaTransferablePct', obj.Reverse.hoaTransferablePct.Field.Value, ...
                'annualMaintenanceCosts', obj.Reverse.annualMaintenanceCosts.Value, ...
                'buildingSharePct', obj.Reverse.buildingSharePct.Value, ...
                'buildingCompletionYear', obj.Reverse.buildingCompletionYear.Value, ...
                'marginalTaxRatePct', obj.Reverse.marginalTaxRatePct.Value, ...
                'vacancyPct', obj.Reverse.vacancyPct.Value);
            session.sensitivity = struct( ...
                'minTilgungPct', obj.Sensitivity.minTilgungPct.Value, ...
                'maxTilgungPct', obj.Sensitivity.maxTilgungPct.Value, ...
                'stepTilgungPct', obj.Sensitivity.stepTilgungPct.Value);
            session.forwardDerived = struct();
            try
                forwardResult = rentalapp.calculateScenario(rentalapp.readForwardInputs(obj));
                session.forwardDerived.firstYearInterestPaid = forwardResult.firstYearInterestPaid;
                session.forwardDerived.totalInterestPaid = forwardResult.totalInterestPaid;
                session.forwardDerived.paymentScheduleRows = rentalapp.buildPaymentScheduleRows(forwardResult);
            catch
            end
        end

        function applySession(obj, session)
            if isfield(obj.Forward, 'propertyAddress')
                if isfield(session, 'propertyAddress')
                    obj.Forward.propertyAddress.Value = session.propertyAddress;
                else
                    obj.Forward.propertyAddress.Value = '';
                end
            end

            if isfield(session, 'forward')
                forward = session.forward;
                obj.setIfPresent(obj.Forward.purchasePrice, forward, 'purchasePrice');
                obj.setIfPresent(obj.Forward.monthlyRent, forward, 'monthlyRent');
                obj.setIfPresent(obj.Forward.downPaymentPct, forward, 'downPaymentPct');
                obj.setIfPresent(obj.Forward.interestRate, forward, 'interestRate');
                obj.setIfPresent(obj.Forward.financingMode, forward, 'financingMode');
                obj.setIfPresent(obj.Forward.loanTermYears, forward, 'loanTermYears');
                obj.setIfPresent(obj.Forward.initialTilgungPct, forward, 'initialTilgungPct');
                obj.setIfPresent(obj.Forward.minimumTilgungPct, forward, 'minimumTilgungPct');
                obj.setIfPresent(obj.Forward.state, forward, 'state');
                obj.setIfPresent(obj.Forward.transferTaxPct, forward, 'transferTaxPct');
                obj.setIfPresent(obj.Forward.notaryPct, forward, 'notaryPct');
                obj.setIfPresent(obj.Forward.landRegistryPct, forward, 'landRegistryPct');
                obj.setIfPresent(obj.Forward.includeAgent, forward, 'includeAgent');
                obj.setIfPresent(obj.Forward.renovationCosts, forward, 'renovationCosts');
                obj.setIfPresent(obj.Forward.hoaContribution, forward, 'hoaContribution');
                if isfield(forward, 'hoaTransferablePct')
                    rentalapp.setPercentControlValue(obj.Forward.hoaTransferablePct, forward.hoaTransferablePct);
                end
                obj.setIfPresent(obj.Forward.annualMaintenanceCosts, forward, 'annualMaintenanceCosts');
                obj.setIfPresent(obj.Forward.buildingSharePct, forward, 'buildingSharePct');
                obj.setIfPresent(obj.Forward.buildingCompletionYear, forward, 'buildingCompletionYear');
                obj.setIfPresent(obj.Forward.marginalTaxRatePct, forward, 'marginalTaxRatePct');
                obj.setIfPresent(obj.Forward.vacancyPct, forward, 'vacancyPct');
                obj.setIfPresent(obj.Forward.rentGrowthPct, forward, 'rentGrowthPct');
                obj.setIfPresent(obj.Forward.expenseInflationPct, forward, 'expenseInflationPct');
                obj.setIfPresent(obj.Forward.appreciationPct, forward, 'appreciationPct');
                obj.setIfPresent(obj.Forward.horizonYears, forward, 'horizonYears');
                rentalapp.setFinancingMode(obj, 'Forward', false);
            end

            if isfield(session, 'reverse')
                reverse = session.reverse;
                obj.setIfPresent(obj.Reverse.mode, reverse, 'mode');
                obj.setIfPresent(obj.Reverse.monthlyRent, reverse, 'monthlyRent');
                obj.setIfPresent(obj.Reverse.targetReturnPct, reverse, 'targetReturnPct');
                obj.setIfPresent(obj.Reverse.downPaymentPct, reverse, 'downPaymentPct');
                obj.setIfPresent(obj.Reverse.interestRate, reverse, 'interestRate');
                obj.setIfPresent(obj.Reverse.financingMode, reverse, 'financingMode');
                obj.setIfPresent(obj.Reverse.loanTermYears, reverse, 'loanTermYears');
                obj.setIfPresent(obj.Reverse.initialTilgungPct, reverse, 'initialTilgungPct');
                obj.setIfPresent(obj.Reverse.minimumTilgungPct, reverse, 'minimumTilgungPct');
                obj.setIfPresent(obj.Reverse.state, reverse, 'state');
                obj.setIfPresent(obj.Reverse.transferTaxPct, reverse, 'transferTaxPct');
                obj.setIfPresent(obj.Reverse.notaryPct, reverse, 'notaryPct');
                obj.setIfPresent(obj.Reverse.landRegistryPct, reverse, 'landRegistryPct');
                obj.setIfPresent(obj.Reverse.includeAgent, reverse, 'includeAgent');
                obj.setIfPresent(obj.Reverse.renovationCosts, reverse, 'renovationCosts');
                obj.setIfPresent(obj.Reverse.hoaContribution, reverse, 'hoaContribution');
                if isfield(reverse, 'hoaTransferablePct')
                    rentalapp.setPercentControlValue(obj.Reverse.hoaTransferablePct, reverse.hoaTransferablePct);
                end
                obj.setIfPresent(obj.Reverse.annualMaintenanceCosts, reverse, 'annualMaintenanceCosts');
                obj.setIfPresent(obj.Reverse.buildingSharePct, reverse, 'buildingSharePct');
                obj.setIfPresent(obj.Reverse.buildingCompletionYear, reverse, 'buildingCompletionYear');
                obj.setIfPresent(obj.Reverse.marginalTaxRatePct, reverse, 'marginalTaxRatePct');
                obj.setIfPresent(obj.Reverse.vacancyPct, reverse, 'vacancyPct');
                rentalapp.setFinancingMode(obj, 'Reverse', false);
            end

            if isfield(session, 'sensitivity')
                sensitivity = session.sensitivity;
                obj.setIfPresent(obj.Sensitivity.minTilgungPct, sensitivity, 'minTilgungPct');
                obj.setIfPresent(obj.Sensitivity.maxTilgungPct, sensitivity, 'maxTilgungPct');
                obj.setIfPresent(obj.Sensitivity.stepTilgungPct, sensitivity, 'stepTilgungPct');
            end

            if isfield(session, 'selectedTab')
                switch session.selectedTab
                    case obj.ForwardTab.Title
                        obj.Tabs.SelectedTab = obj.ForwardTab;
                    case obj.ReverseTab.Title
                        obj.Tabs.SelectedTab = obj.ReverseTab;
                    case obj.SensitivityTab.Title
                        obj.Tabs.SelectedTab = obj.SensitivityTab;
                    case obj.PaymentScheduleTab.Title
                        obj.Tabs.SelectedTab = obj.PaymentScheduleTab;
                    case obj.CalculationTab.Title
                        obj.Tabs.SelectedTab = obj.CalculationTab;
                end
            end
        end

        function setIfPresent(~, control, values, fieldName)
            if isfield(values, fieldName)
                control.Value = values.(fieldName);
            end
        end

        function address = getPropertyAddress(obj)
            address = '';
            if isfield(obj.Forward, 'propertyAddress')
                address = strtrim(obj.Forward.propertyAddress.Value);
            end
        end
    end
end
