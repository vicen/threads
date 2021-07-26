function tp = get_type_params(fname)

% possible types of params

% 1: any number
% 2: only positive, and can be >> 1
% 3: only positive, preferably close to one, but can be >1
% 4: between 0 and 1

switch fname
    case 'FULL_MODEL_AUTHORS_0' % beta, alpha, tau, kappa
        tp = [1, 3, 4, 1];
    case 'FULL_MODEL_AUTHORS_1' % beta, alpha, tau, kappa
        tp = [1, 3, 4, 1];
    case 'NO_ALPHA_AUTHORS_0' % beta, tau, kappa
        tp = [1, 4, 1];
     case 'NO_ALPHA_AUTHORS_1' % beta, tau, kappa
        tp = [1, 4, 1];
   case 'NO_TAU_AUTHORS_0' % beta, alpha, kappa
        tp = [1, 3, 1];
    case 'NO_BIAS_AUTHORS_0' % alpha, tau, kappa
        tp = [3, 4, 1];
    case 'FULL_MODEL_AUTHORS' % beta, alpha, tau, pa_aut, kappa
        tp = [1, 3, 4, 1];
    case 'FULL_MODEL_SUBLIN' % beta, alpha, tau
        tp = [1, 3, 4, 3];
    case 'FULL_MODEL' % beta, alpha, tau
        tp = [1, 3, 4];
    case 'NO_ALPHA' % beta, tau
        tp = [1, 4];
    case 'NO_TAU' % beta, tau
        tp = [1, 3];
    case 'NO_BIAS' % beta, tau
        tp = [3, 4];
    case 'NO_TAU_cte' % beta, tau
        tp = [1, 3];
    case 'FULL_MODEL_switch' % beta, alpha, tau
        tp = [1, 3, 4, 4];
    case 'FULL_MODEL_sigmoid' % beta, alpha, tau
        tp = [1, 3, 4];
    case 'FULL_MODEL_sigmoid2' % beta, alpha, tau
        tp = [1, 3, 4,1];
    case 'FULL_MODEL_2sigmoid' % beta, alpha, tau
        tp = [1, 3, 1,1,1];
    case 'FULL_MODEL_sigmoid2_notau' % beta, alpha, tau
        tp = [1, 3, 1];
    case 'biassum_tau_PAprod' % beta, alpha, tau
        tp = [1, 3, 4];
    case 'biassum_tau_PAprod_betaout'
        tp = [1, 3, 4];
    case 'biassum_notau_PAprod' % beta, alpha
        tp = [1, 3];
    case 'biassum_notau_PAprod_betaout' % beta, alpha
        tp = [1, 3];
    case 'nobias_tau_PAprod' % alpha, tau
        tp = [3, 4];
    case 'nobias_tau_PAprod_betaout' % alpha, tau
        tp = [3, 4];
    case 'biassum_tau_noPA' % beta, tau
        tp = [1, 4];
    case 'biassum_tau_noPA_betaout' % beta, tau
        tp = [1, 4];
    case 'biassum_tau_PAprod_2level'
        tp = [2, 3, 4, 2];
    case 'biasexp_notau_PAexp'
        tp = [1, 1, 1];
    case 'biasexp_notau_PAprod'
        tp = [1, 2, 1];        
    case 'biasexp_tau_PAprod'
        tp = [1, 2, 4, 1];        
    case 'biasexp_tau_PAexp'
        tp = [3, 3, 4, 1];        
    case 'biasexp_tau_PAexp_betacmnt'
        tp = [3, 3, 4, 1, 1];        
    case 'biasexp_tau_PAexp_betacmnt_gamma'
        tp = [3, 3, 4, 1, 1, 3];        
    case 'biasexp_tau_PAprod_gamma'
        tp = [1, 2, 4, 1, 2];            
    case 'biasprod_notau_PAprod'
        tp = [2, 2];     
    case 'biasprod_tau_PAexp'
        tp = [1, 2, 4];    
    case 'biassum_tau_PAprod_normdeg'
        tp = [3, 3, 4];    
    case 'biassum_tau_PAprod_sigmoid'
        tp = [4, 4, 3];    
    case 'biassum_tau_PAprod_sigmoid2'
        tp = [4, 4, 3, 1];    
    case 'biassum_tau_PAprod_sigmoid_nonorm'
        tp = [4, 4, 3];    
    case 'biassum_tau_PAprod_sigmoid_nonorm2'
        tp = [4, 4, 3, 1];    
    case 'biassum_taulin_PAprod'
        tp = [3, 3, 3, 1];
    case 'biassum_tausigmoid2_PAprod'
        tp = [4, 4, 3, 1];
    case 'ML_biassum_tausigmoid_PAprod'
        tp = [3, 4, 3];
    case 'biassum_tausigmoidnopost_PAprod'
        tp = [3, 4, 3];
    case 'nobias_notau_PAexp'
        tp = [3];
    case 'nobias_notau_PAprod'
        tp = [3];
    case 'nobias_tau_noPA'
        tp = [4];
    case 'nobias_tau_PAexp'
        tp = [1, 4];
    case 'nobias_tau_PAprod_gamma'
        tp = [3, 4, 3];
    case 'switch_popularity_novelty'
       tp = [3, 4, 3];

    otherwise
        disp('--------------------------------------------------------');
        disp('Add the corresponding entry in get_type_params.m please!');
        disp('--------------------------------------------------------');
        tp = [];
end