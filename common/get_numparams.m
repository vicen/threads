function n = get_numparams(fname)

switch fname
    case 'FULL_MODEL_AUTHORS_0'
        n = 4;
    case 'FULL_MODEL_AUTHORS_1'
        n = 4;
    case 'NO_ALPHA_AUTHORS_0'
        n = 3;
    case 'NO_ALPHA_AUTHORS_1'
        n = 3;
    case 'NO_TAU_AUTHORS_0'
        n = 3;
    case 'NO_BIAS_AUTHORS_0'
        n = 3;       
    case 'FULL_MODEL_AUTHORS'
        n = 4;
    case 'FULL_MODEL_SUBLIN'
        n = 4;
    case 'FULL_MODEL'
        n = 3;
    case 'NO_ALPHA'
        n = 2;
    case 'NO_TAU'
        n = 2;
    case 'NO_BIAS'
        n = 2;
    case 'NO_TAU_cte'
        n = 2;
    case 'FULL_MODEL_switch'
        n =4;
    case 'FULL_MODEL_sigmoid'
        n =3;        
    case 'FULL_MODEL_sigmoid2'
        n =4;        
    case 'FULL_MODEL_2sigmoid'
        n =5;        
    case 'FULL_MODEL_sigmoid2_notau'
        n =3;        
    case 'biassum_tau_PAprod_2level'
        n = 4;
    case 'biassum_tau_noPA'
        n = 2;
    case 'biassum_tau_noPA_betaout'
        n = 2;
    case 'biasexp_tau_PAprod'
        n = 4;
    case 'biasexp_tau_PAprod2'
        n = 4;
    case 'biasexp_tau_PAexp'    
        n = 4;
    case 'biasprod_tau_PAprod'
        n = 3;
    case 'biasprod_tau_PAexp'
        n = 3;
    case 'biasexp_notau_PAexp'
        n = 3;
    case 'biasexp_tau_PAexp_betacmnt'
        n = 5;
    case 'biasexp_tau_PAexp_betacmnt_gamma'
        n = 6;
    case 'biasexp_notau_PAprod'
        n = 3;
    case 'biasprod_notau_PAprod'
        n = 2;
    case 'nobias_tau_PAexp'
        n = 2;   
    case 'nobias_tau_noPA'
        n = 1;
    case 'nobias_tau_PAprod'
        n = 2;
    case 'nobias_tau_PAprod_betaout'
        n = 2;
    case 'nobias_notau_PAprod'
        n = 1;   
    case 'nobias_notau_PAexp'
        n = 1;   
    case 'biasexp_tau_PAprod_gamma'
        n = 5;   
    case 'nobias_tau_PAprod_gamma'
        n = 3;   
    case 'switch_popularity_novelty'
        n = 4;   
    case 'biassum_tau_PAprod'
        n = 3;   
    case 'biassum_tau_PAprod_betaout'
        n = 3;   
    case 'biassum_tau_PAprod_sigmoid'
        n = 3;   
    case 'biassum_tausigmoid_PAprod'
        n = 3;
    case 'biassum_tausigmoidnopost_PAprod'
        n = 3;
    case 'biassum_tausigmoid2_PAprod'
        n = 4;   
    case 'biassum_tau_PAprod_sigmoid2'
        n = 4;           
    case 'biassum_notau_PAprod'
        n = 2;  
    case 'biassum_notau_PAprod_betaout'
        n = 2;          
    case 'biassum_tau_PAprod_sigmoid_nonorm'
        n = 3;  
    case 'biassum_tau_PAprod_sigmoid_nonorm2'
        n = 4;        
    case 'biassum_taulin_PAprod'
        n = 4;        
    case 'biassum_tau_PAprod_normdeg'
        n = 3;        
end