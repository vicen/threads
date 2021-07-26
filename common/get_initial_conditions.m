function init0 = get_initial_conditions(vtype, nexp)

% if nexp==10
%     init0(1, 1:10) = 0.015943;
%     init0(2, 1:10) =0.59347;
% else
    np = numel(vtype);
    init0 = zeros(np, nexp);
    for p = 1:np
        switch vtype(p)
            case 1 
                init = -1 + 2*rand(1,nexp); % real number in (-1,1)
            case 2
                init = 5*rand(1,nexp); % real number in (0,10)
            case 3
                init = 1 + .25*randn(1,nexp); % normally distrib around one
            case 4
                init = 1 - abs(.25*randn(1,nexp));
        end
        init0(p,:) = init;
    end
% end
