clearvars;

nPoints = [101	81	61	41	21	11	10	9	8	7	6	5];
hip_RMSE_mean = [5.01E-06	0.0023	0.027	0.0314	0.1432	0.5106	0.6144	0.7304	1.0004	1.4882	2.1217	3.5051];
hip_RMSE_std = [4.85E-06	0.0018	0.0218	0.0202	0.1087	0.3971	0.4795	0.5694	0.774	1.1602	1.6317	2.6566];
mhip_nPoint = 6;
mhip_RMSE_mean = 0.7798;
mhip_RMSE_std = 0.4757;
knee_RMSE_mean = [8.83E-06	0.0054	0.0397	0.0547	0.22	0.7453	0.8916	1.0453	1.4349	2.111	2.9827	4.9537];
knee_RMSE_std = [5.85E-06	0.0037	0.0291	0.025	0.1387	0.5122	0.6175	0.7376	0.9982	1.4889	2.0921	3.3142];
mknee_nPoint = 8;
mknee_RMSE_mean = 0.8586;
mknee_RMSE_std = 0.7793;
ankle_RMSE_mean = [6.02E-06	0.0075	0.0346	0.0509	0.1883	0.6206	0.75	0.9364	1.1957	1.8312	2.5511	4.4403];
ankle_RMSE_std = [6.34E-06	0.0057	0.033	0.0329	0.1624	0.5987	0.7164	0.8382	1.1715	1.7114	2.4249	3.8423];
mankle_nPoint = 7;
mankle_RMSE_mean = 1.4771;
mankle_RMSE_std = 0.9138;

figure;
hold on;
box on;
grid on;
plot(1:12,hip_RMSE_mean,'Color','red','Linewidth',2);
plot(12-mhip_nPoint+5,mhip_RMSE_mean,'Color','red','Marker','x','MarkerSize',10,'Linewidth',2);
plot(1:12,knee_RMSE_mean,'Color','green','Linewidth',2);
plot(12-mknee_nPoint+5,mknee_RMSE_mean,'Color','green','Marker','x','MarkerSize',10,'Linewidth',2);
plot(1:12,ankle_RMSE_mean,'Color','blue','Linewidth',2);
plot(12-mankle_nPoint+5,mankle_RMSE_mean,'Color','blue','Marker','x','MarkerSize',10,'Linewidth',2);
xlabel('Number of discrete points');
ylabel('Average RMSE (°deg)');
set(gca,'FontName','Times New Roman')
set(gca,'fontsize',14);
set(gca,'XTick',[1:12]);
set(gca,'XTick',[1:12]);
set(gca,'XTickLabel',{'101' '81' '61' '41' '21' '11' '10' '9' '8' '7' '6' '5'});
set(gca,'XLimits',[1:12]);