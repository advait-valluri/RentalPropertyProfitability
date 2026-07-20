classdef RentalPropertyApp < handle
    properties
        Currency = '$'
        Figure
        Tabs
        ForwardTab
        ReverseTab
        Forward = struct()
        Reverse = struct()
    end

    methods
        function obj = RentalPropertyApp()
            obj.Figure = uifigure( ...
                'Name', 'Rental Property Profitability', ...
                'Position', [80 60 1360 860]);

            root = uigridlayout(obj.Figure, [1 1]);
            root.Padding = [12 12 12 12];

            obj.Tabs = uitabgroup(root);
            obj.ForwardTab = uitab(obj.Tabs, 'Title', 'Forward calculation');
            obj.ReverseTab = uitab(obj.Tabs, 'Title', 'Max price from rent');

            rentalapp.createForwardTab(obj);
            rentalapp.createReverseTab(obj);

            obj.updateForward();
            obj.updateReverse();
        end

        function updateForward(obj)
            try
                in = rentalapp.readForwardInputs(obj);
                result = rentalapp.calculateScenario(in);
                rentalapp.setForwardMetrics(obj, result);
                rentalapp.plotForward(obj, result);
                obj.Forward.status.Text = '';
            catch err
                obj.Forward.status.Text = ['Check inputs: ' err.message];
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
    end
end
