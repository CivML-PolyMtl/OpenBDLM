function [fct_TR,fct_inv_TR,grad_TR2OR,hessian_TR2OR]=parameter_transformation_fct(model,param_idx_loop)
a = 1;
sigmoid=@(p) 1./(1+exp(-a*p));
sigmoid_inv=@(p) -log((1./p)-1)/a;    

p_TR_0=@(p) p;
p_TR_1=@(p) log10(p);
p_TR_2=@(p,min_p,range_p) sigmoid_inv((p-min_p)/range_p);


p_inv_TR_0=@(p) p;
p_inv_TR_1=@(p) 10.^p;
p_inv_TR_2=@(p,min_p,range_p) sigmoid(p)*range_p+min_p;

if model.param_properties{param_idx_loop,5}(1)==-inf&&model.param_properties{param_idx_loop,5}(2)==inf
    fct_TR=@(p) p_TR_0(p);
    fct_inv_TR=@(p) p_inv_TR_0(p);
    grad_TR2OR=@(p) 1;
    hessian_TR2OR=@(p) 1;
elseif model.param_properties{param_idx_loop,5}(1)==0&&model.param_properties{param_idx_loop,5}(2)==inf
    fct_TR=@(p) p_TR_1(p);
    fct_inv_TR=@(p) p_inv_TR_1(p);
    grad_TR2OR=@(p) log(10)*10.^p;
    hessian_TR2OR=@(p) log(10)^2*10.^p;
elseif isfinite(model.param_properties{param_idx_loop,5}(1))&&isfinite(model.param_properties{param_idx_loop,5}(2))
    range_p=model.param_properties{param_idx_loop,5}(2)-model.param_properties{param_idx_loop,5}(1);
    min_p=model.param_properties{param_idx_loop,5}(1);
    fct_TR=@(p) p_TR_2(p,min_p,range_p);
    fct_inv_TR=@(p) p_inv_TR_2(p,min_p,range_p);
    grad_TR2OR=@(p) sigmoid(p)*(1-sigmoid(p))*range_p*a;
    hessian_TR2OR=@(p) sigmoid(p)*(1-sigmoid(p))*(1-2*sigmoid(p))*range_p^2*a^2;
else
    error('Parameter bounds are not properly defined in: model.param_properties{:,5}')
end
end