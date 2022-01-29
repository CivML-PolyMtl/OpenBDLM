 
% LL of test set
end_time   = 522;
start_time = 522-1*52;
sigmaY_test = sqrt(squeeze(estim.Vy(2,2,start_time+1:end_time))); %471 %677
muY_test = estim.y(2,start_time+1:end_time)';
P = normpdf(data.valuesRef(start_time+1:end_time,2),muY_test, sigmaY_test);
LL = sum(log(P))

CB2_KR_2010_2013.sigmaY_test = sigmaY_test;
CB2_KR_2010_2013.muY_test = muY_test;
save('CB2_KR_2010_2013.mat',  '-struct', 'CB2_KR_2010_2013');


hold on; plot(735234*ones(2,1),[-14, 7.8],'k','LineWidth',2);plot(735241*ones(2,1),[-29, 15],'k','LineWidth',2)  %733785


%% scatter plots
subplot(1,4,1)
scatter(estim.x(2,:), estim.x(51,:)) %KR
subplot(1,4,2)
scatter(estim.x(23,:), estim.x(49,:)+estim.x(48,:)) % AR
subplot(1,4,3)
scatter(estim.x(2,:) + estim.x(23,:), estim.x(49,:) + estim.x(51,:)) % total pattern
subplot(1,4,4)
scatter(estim.x(2,:) + estim.x(23,:), estim.x(49,:) + estim.x(51,:)+estim.x(48,:))
% RMSE
rmse = sqrt(mean((data.obs(220:end,2) - muY_test).^2))