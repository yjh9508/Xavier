%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Development Economics: Homework 2
% Question 1. Praying for Rain: The Welfare Cost of Seasons.
% Junhui Yang
% Friday 8 February 2019
% Note (just for myself): The code may be improved by finding some way to
% avoid the loops when computing the welfare gains.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear all; close all;
rng(20190208)

global beta_all eta

% Set the parameters
beta = .99^(1/12); % "The discount factor ... its annual value is 0.99."
N = 1000; % number of households
T = 12*40; % each month is a time period
sig2_u = .2; sig2_eps = .2;

%% Part 1

% Deterministic seasonal component, g(m)
gm_low = [-.073 -.185 .071 .066 .045 .029 .018 .018 .018 .001 -.017 -.041];
gm_mid = [-.147 -.37 .141 .131 .09 .058 .036 .036 .036 .002 -.033 -.082];
gm_hig = [-.293 -.739 .282 .262 .18 .116 .072 .072 .072 .004 -.066 -.164];

beta_all = beta.^(12:T+11); % a sequence, beta^12, bata^13 ... beta^(T+11)

z_all = repmat(exp(-sig2_u/2+sqrt(sig2_u).*randn(N,1)),1,T);
% permanent consumption level of all households across all periods

gm_low_all = exp(repmat(gm_low,N,T/12));
gm_mid_all = exp(repmat(gm_mid,N,T/12));
gm_hig_all = exp(repmat(gm_hig,N,T/12));
% deterministic seasonal component of all households across all periods

idio_all = kron(exp(-sig2_eps/2+sqrt(sig2_eps).*randn(N,T/12)),ones(1,12));
% idiosyncratic nonseasonal component of all households across all periods

con_low_all = z_all.*gm_low_all.*idio_all;
con_mid_all = z_all.*gm_mid_all.*idio_all;
con_hig_all = z_all.*gm_hig_all.*idio_all;
% consumption level of all households across all periods

con_noseas_all = z_all.*idio_all;
% consumption level of all households across all periods, after removing
% the seasonal component

con_low_norisk_all = z_all.*gm_low_all;
con_mid_norisk_all = z_all.*gm_mid_all;
con_hig_norisk_all = z_all.*gm_hig_all;
% consumption level of all households across all periods, after removing
% the nonseasonal consumption risk

Eta = []; Low = []; Mid = []; High = [];

for eta = [1,2,4]
    for i = 1:N
        gl1(i) = welfaregain(con_low_all,con_noseas_all,i);
        gm1(i) = welfaregain(con_mid_all,con_noseas_all,i);
        gh1(i) = welfaregain(con_hig_all,con_noseas_all,i);
        
        gl2(i) = welfaregain(con_low_all,con_low_norisk_all,i);
        gm2(i) = welfaregain(con_mid_all,con_mid_norisk_all,i);
        gh2(i) = welfaregain(con_hig_all,con_hig_norisk_all,i);
        
        % welfaregain() is a function to compute welfare gains; its inputs
        % are the indicator of a household, the consumption stream of the
        % household, and the consumption steam of the household after
        % removing what we want to remove; the function is at the end of
        % the code
    end
    
    Eta = [Eta;eta;eta];
    Low = [Low;mean(gl1);mean(gl2)];
    Mid = [Mid;mean(gm1);mean(gm2)];
    High = [High;mean(gh1);mean(gh2)];
end

disp('Part 1. Welfare Gains for Each Degree of Seasonality')
Remove = {'Seasonal';'NonSeasonal';'Seasonal';...
    'NonSeasonal';'Seasonal';'NonSeasonal'};
Part1_Result = table(Eta,Remove,Low,Mid,High)
% present the result in the form of a table

%% Part 2

% Stochastic seasonal component, sig2_m
sig2_m_low = [.043 .034 .145 .142 .137 .137 .119 .102 .094 .094 .085 .068];
sig2_m_mid = [.085 .068 .29 .283 .273 .273 .239 .205 .188 .188 .171 .137];
sig2_m_hig = [.171 .137 .58 .567 .546 .546 .478 .41 .376 .376 .341 .273];

ssc_low_all = exp(repmat(-sig2_m_low/2,N,T/12)+...
    repmat(sqrt(sig2_m_low),N,T/12).*randn(N,T));
ssc_mid_all = exp(repmat(-sig2_m_mid/2,N,T/12)+...
    repmat(sqrt(sig2_m_mid),N,T/12).*randn(N,T));
ssc_hig_all = exp(repmat(-sig2_m_hig/2,N,T/12)+...
    repmat(sqrt(sig2_m_hig),N,T/12).*randn(N,T));
% stochastic seasonal component of all households across all periods

% Add the stochastic seasonal compoent to the consumption in Part 1
con = {};
con{1} = con_low_all;
con{2} = con_mid_all;
con{3} = con_hig_all;

con_norisk = {};
con_norisk{1} = con_low_norisk_all;
con_norisk{2} = con_mid_norisk_all;
con_norisk{3} = con_hig_norisk_all;

ssc = {};
ssc{1} = ssc_low_all;
ssc{2} = ssc_mid_all;
ssc{3} = ssc_hig_all;

con_ssc = {};
con_norisk_ssc = {};

for i = 1:3
    for j = 1:3
        con_ssc{i,j} = con{i}.*ssc{j};
        con_norisk_ssc{i,j} = con_norisk{i}.*ssc{j};
    end
end

Eta = [];Low_Low = [];Low_Mid = [];Low_High = [];Mid_Low = [];Mid_Mid = [];
Mid_High = [];High_Low = [];High_Mid = [];High_High = [];

for eta = [1,2,4]
    for i = 1:N
        gll1(i) = welfaregain(con_ssc{1,1},con_noseas_all,i);
        glm1(i) = welfaregain(con_ssc{1,2},con_noseas_all,i);
        glh1(i) = welfaregain(con_ssc{1,3},con_noseas_all,i);
        gml1(i) = welfaregain(con_ssc{2,1},con_noseas_all,i);
        gmm1(i) = welfaregain(con_ssc{2,2},con_noseas_all,i);
        gmh1(i) = welfaregain(con_ssc{2,3},con_noseas_all,i);
        ghl1(i) = welfaregain(con_ssc{3,1},con_noseas_all,i);
        ghm1(i) = welfaregain(con_ssc{3,2},con_noseas_all,i);
        ghh1(i) = welfaregain(con_ssc{3,3},con_noseas_all,i);
        
        gll2(i) = welfaregain(con_ssc{1,1},con_norisk_ssc{1,1},i);
        glm2(i) = welfaregain(con_ssc{1,2},con_norisk_ssc{1,2},i);
        glh2(i) = welfaregain(con_ssc{1,3},con_norisk_ssc{1,3},i);
        gml2(i) = welfaregain(con_ssc{2,1},con_norisk_ssc{2,1},i);
        gmm2(i) = welfaregain(con_ssc{2,2},con_norisk_ssc{2,2},i);
        gmh2(i) = welfaregain(con_ssc{2,3},con_norisk_ssc{2,3},i);
        ghl2(i) = welfaregain(con_ssc{3,1},con_norisk_ssc{3,1},i);
        ghm2(i) = welfaregain(con_ssc{3,2},con_norisk_ssc{3,2},i);
        ghh2(i) = welfaregain(con_ssc{3,3},con_norisk_ssc{3,3},i);
    end
    
    Eta = [Eta;eta;eta];
    Low_Low = [Low_Low;mean(gll1);mean(gll2)];
    Low_Mid = [Low_Mid;mean(glm1);mean(glm2)];
    Low_High = [Low_High;mean(glh1);mean(glh2)];
    Mid_Low = [Mid_Low;mean(gml1);mean(gml2)];
    Mid_Mid = [Mid_Mid;mean(gmm1);mean(gmm2)];
    Mid_High = [Mid_High;mean(gmh1);mean(gmh2)];
    High_Low = [High_Low;mean(ghl1);mean(ghl2)];
    High_Mid = [High_Mid;mean(ghm1);mean(ghm2)];
    High_High = [High_High;mean(ghh1);mean(ghh2)];
end

disp('Part 2. Welfare Gains for Each Degree of Seasonality')
Part2_Result = table(Eta,Remove,Low_Low,Low_Mid,Low_High,Mid_Low,...
    Mid_Mid,Mid_High,High_Low,High_Mid,High_High)

%% The function to compute welfare gains
function g = welfaregain(x,y,z)
global beta_all eta
if eta == 1
    tmp = @(g) abs(sum(beta_all.*log(x(z,:)*(1+g))-...
        beta_all.*log(y(z,:))));
else
    tmp = @(g) abs(sum(beta_all.*((x(z,:)*(1+g)).^(1-eta)/(1-eta))-...
        beta_all.*(y(z,:).^(1-eta)/(1-eta))));
end
g = fminbnd(tmp,0,2);
end