function [DOA, tau] = doapca(pulseList,scale)
%DOAPCA developes a bearing estimate for a series of received radio pulses
%based on the principle component analysis method.
%   This function conducts a principle component analysis type bearing
%   estimate on signal pulses in the pulseList vector. Each pulse signal
%   corresponds to a given heading (pulse_yaw). The program uses the SNR in
%   dB for the pulses in the list and does the PCA on those pulses using a
%   the original log scaling or a linear scaling depending on the 'scale'
%   input
%
%
%INPUTS
%   pulseList           a (px1) vector of ReceivedPulse objects
%
%   scale               a char array of 'log' or 'linear' to indicate if
%                       the scaling used in the PCA method should be log or
%                       linear
%
%OUTPUTS
%   DOA                 a (1x1) double containing the bearing estimate
%                       from the PCA method from 0-359 degrees with 0 being
%                       the same as the yaw origin (typically N). 
%   tau                 a (1x1) double containing the tau value for
%                       each bearing estimate.
%
%--------------------------------------------------------------------------
% Author: Michael Shafer
% Date: 2023-06-12
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

numPulses = numel(pulseList(:));

curr_pulses_snrdB  = reshape([pulseList(:).snrdB],numPulses,1);
curr_pulses_snrLin = 10.^(curr_pulses_snrdB/10);

curr_pulses_noisePSD = reshape([pulseList(:).noisePSD],numPulses,1);

curr_eulers = reshape([pulseList(:).euler],numPulses,1);
curr_yaws   = reshape([curr_eulers(:).yaw_deg],numPulses,1);

%Clear out placeholds for bad data points;
curr_pulses_noisePSD(curr_pulses_noisePSD == -9999) = NaN;
curr_pulses_snrdB(curr_pulses_snrdB == -9999) = NaN;

curr_pulses_sigPSD = curr_pulses_noisePSD .* 10.^(curr_pulses_snrdB./10);

%Define for Coder so DOA is defined for all execution paths
DOA_calc = NaN;
DOA = 180/pi*DOA_calc;
tau = NaN;

if any(curr_pulses_snrLin < 0) | any(abs(curr_pulses_snrLin) == Inf)
    fprintf('UAV-RT: Strength of all input pulses must be finite and positive.')
    return
end

%P_all_ang_unscaled = (curr_pulses_snrLin./min(curr_pulses_snrLin));
P_all_ang_unscaled = (curr_pulses_sigPSD./min(curr_pulses_sigPSD));


if strcmp(scale,'linear')
    P_all_ang = P_all_ang_unscaled;
elseif strcmp(scale,'log')
    P_all_ang = log10(P_all_ang_unscaled);
else
    fprintf('UAV-RT: Scale type must be linear or log.')
    return
end


angs = curr_yaws*pi/180;

sortedAngsDeg = sort(wrapTo360(curr_yaws));

diffAngsDeg = diff(sortedAngsDeg);
totalSweptAngle = sum(diffAngsDeg);



if length(curr_pulses_sigPSD)<4 | totalSweptAngle < 270
    numPulses = length(curr_pulses_sigPSD);
    fprintf('Only %f pulse(s) detected over swept angle %f degrees. Insufficient to perform PCA Method which requires at least 270 degrees of sweep and 4 pulses received. Returning DOA based on maximum signal strength.', numPulses, totalSweptAngle)
    %wp(2) = NaN; wp(1) = NaN;tau = NaN; line_scale = 0;

    [~,maxPulseInd] = max(P_all_ang);
    maxPulseAng = angs(maxPulseInd);
    DOA_calc = maxPulseAng;
    tau = NaN;

else
    Pe_star_dB = [P_all_ang.*cos(angs),P_all_ang.*sin(angs)];
    n = length(Pe_star_dB);
    Pe_dB = (eye(n)-1/n*ones(n))*Pe_star_dB;
    Pavg = 1/n*Pe_star_dB'*ones(n,1);
    [~, SdB, VdB] = svd(Pe_dB);
    w1 = VdB(:,1);
    %w2 = VdB(:,2);
    wp = Pavg'*w1/(norm(Pavg)*norm(w1))*w1;
    %beta = norm(Pavg)^2/SdB(1,1)^2;
    tau = 1-SdB(2,2)^2/SdB(1,1)^2;
    %line_scale = max(P_all_ang)/norm(wp);%the wp size changes if w1
    
    DOA_calc = atan2(wp(2),wp(1));
end

DOA = 180/pi*DOA_calc;

% %% Now fit the kappa value for the vonMises Distribution
% kappaVec = 0:0.001:20;
% mu = DOA_calc;
% %curr_yaws;
% %curr_pulses
% %Fit to vonMises by making pulse stength like counts for histogram/PDF
% scalingExponent = 4 - round(log10(max(P_all_ang)));
% if strcmp(scale,'linear')
%     counts = P_all_ang * 1*10^(scalingExponent);
% elseif strcmp(scale,'log')
%     counts = (P_all_ang + -min(P_all_ang))/-min(P_all_ang) * 1*10^(scalingExponent);
% end
% 
% counts = round(counts);
% fakeData = zeros(sum(counts),1);
% currInd = 1;
% tic
% for i = 1:numPulses
%     endInd = currInd + counts(i);
%     fakeData(currInd : endInd) = curr_yaws(i);
%     currInd = endInd+1;
% end
% 
% [probs, binEdges] = histcounts(fakeData,16,'Normalization','probability');
% binwidths = diff(binEdges);
% binCenters = binEdges(1:(end-1)) + binwidths(1:end)/2;
% 
% sumErrorSquare = zeros(numel(kappaVec),1);
% %Sweep kappa values to find that with the least error^2. 
% for i = 1:numel(kappaVec)
%     kappa = kappaVec(i);
%     vonMisesDist = exp(kappa*cos(binCenters-mu))/(2*pi*besseli(0,kappa));
%     sumErrorSquare(i) = sum((vonMisesDist - probs).^2);
% end
% 
% [~, indMinError] = min(sumErrorSquare);
% 
% kappaBest = kappaVec(indMinError);
% 
% kappa = kappaBest;

end
