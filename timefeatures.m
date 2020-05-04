function features = timefeatures(timeData,idxTimeFeatures)

%%%%---Calculation of statistical features in frequency and time domain----------%%%%
%  Input:    timeData = data of sample in time domain
%            amplitudeData = amplitude of data in frequency domain
%            idxTimeFeatures = index of time features
%            idxFrequencyFeatures = index of frequency features  

%  Output: features = Matrix of features of time and frequency domain
%%

% ---Time features start here
T = strmatch('Mean',idxTimeFeatures,'exact');
if ~isempty(T)
    features(T,:)=mean(timeData);
end
T = strmatch('Max',idxTimeFeatures,'exact');
if ~isempty(T)
    features(T,:)=max(timeData);
end
T = strmatch('Min',idxTimeFeatures,'exact');
if ~isempty(T)
    features(T,:)=min(timeData);
end
T = strmatch('Range',idxTimeFeatures,'exact');
if ~isempty(T)
    features(T,:)=max(timeData)-min(timeData);
end
T = strmatch('Sum',idxTimeFeatures,'exact');
if ~isempty(T)
    features(T,:)=sum(timeData);
end
T = strmatch('Median',idxTimeFeatures,'exact');
if ~isempty(T)
    features(T,:)=median(timeData);
end
T = strmatch('RMS',idxTimeFeatures,'exact');
if ~isempty(T)
    features(T,:)=sqrt(mean(timeData.^2) );
end
T = strmatch('Variance',idxTimeFeatures,'exact');
if ~isempty(T)
    features(T,:)=var(timeData);
end
T = strmatch('Kurtosis',idxTimeFeatures,'exact');
if ~isempty(T)
    features(T,:)=kurtosis(timeData);
end
T = strmatch('Skewness',idxTimeFeatures,'exact');
if ~isempty(T)
    features(T,:)=skewness(timeData);
end
T = strmatch('Crest factor',idxTimeFeatures,'exact');
if ~isempty(T)
    features(T,:)=max(timeData)/sqrt(mean(timeData.^2) );
end
T = strmatch('Shape factor',idxTimeFeatures,'exact');
if ~isempty(T)
    features(T,:)=sqrt(mean(timeData.^2) )/mean(timeData);
end