function interp_hc=hidden_component(reg_parameters,t_idx)
a=1;
t_ref=reg_parameters(end-1:end);
reg_parameters=reg_parameters(1:end-2)';

delta_t_ref=t_ref(2);
t_ref(2)=t_ref(1)+delta_t_ref;

t_idx=rem((t_idx-t_ref(1))/(a*delta_t_ref),1);
if t_idx<0
    t_idx=t_ref(1)+(1+t_idx)*a*delta_t_ref;
else
    t_idx=t_ref(1)+t_idx*a*delta_t_ref;
end

reg_time=linspace(t_ref(1),t_ref(2),length(reg_parameters)+2);
reg_time=[reg_time(1)-fliplr(reg_time(2:end)-reg_time(1)) reg_time reg_time(end)+reg_time(2:end)-reg_time(1)];
reg_values=[0 reg_parameters 0];
reg_values=[fliplr(reg_values(2:end)) reg_values fliplr(reg_values(1:end-1))];

interp_hc=interp1(reg_time,reg_values,t_idx,'spline')-mean(reg_values);



