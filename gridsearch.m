function [C,sigma] = gridsearch(trainData,trainLabel,testData,test,group,method)

%%  gridsearch for the value of box constraint and sigma in rbf
%   input: trainData - database for training
%          trainLabel - labeling of training data
%          testData - database for testing 
%          testLabel - labeling of testing data
%          group - Labels of training and testing data
%   output: C - critical value of constraint
%           sigma - sigma value in rbf kernel function
%%

%%
% intialization
temp=13;
tempC=10^(-5);
tempSigma=10^(-10);
calC = zeros(1,temp);
calSigma = zeros(1,temp);
classRateMatrix = zeros(temp,temp);
classRate=0;

% create a movie
% movie = VideoWriter('grid_search','mpeg-4');
% open(movie)

%% - Course grid search
cp = classperf(group);
for i=1:temp
    calC(i) = tempC*10^(i-1);
    for j=1:temp
        calSigma(j) = tempSigma*10^(j-1);
        svmStruct = svmtrain(trainData,trainLabel,'boxconstraint',calC(i),...
            'Kernel_Function','rbf','rbf_sigma',calSigma(i),...
        'Method',method);%,'showplot','true');
        classes = svmclassify(svmStruct,testData);%,'showplot',true);
        cp=classperf(cp,classes,test);
        classRateMatrix(i,j)=cp.CorrectRate;
        % make an avi
%         SVs1=svmStruct.SupportVectors(:,1);
%         SVs2=svmStruct.SupportVectors(:,2);
%         plot(SVs1,SVs2,'go',trainData(:,1),trainData(:,2),'rx');
%         frame=getframe(gca);
%         writeVideo(movie,frame);
    end
end
% close(movie);
[val idx]=max(classRateMatrix);
[newVal,newIdx]=max(val);
C_course=calC(newIdx)
sigma_course=calSigma(newIdx)

% plot of grid search
% figure;
% subplot(121);
% surf(log10(calC),log10(calSigma),classRateMatrix);
% xlabel('log(C)');
% ylabel('log(\sigma)');
% zlabel('Correct rate');



%%  fine search
cp = classperf(group);
for i =1:5
    newCalC(i) = C_course*(10^(-1+0.5*(i-1)));
    for j=i:5
        newCalSigma(j) = sigma_course*(10^(-1+0.5*(j-1)));
        svmStruct = svmtrain(trainData,trainLabel,'boxconstraint',newCalC(i),...
            'Kernel_Function','rbf','rbf_sigma',newCalSigma(j),...
                'Method',method);%,'showplot','true');
        classes = svmclassify(svmStruct,testData);%,'showplot',true);
        cp=classperf(cp,classes,test);
        newClassRateMatrix(i,j)=cp.CorrectRate;
    end
end
[val idx]=max(newClassRateMatrix);
[newVal,newIdx]=max(val);
C=newCalC(newIdx);
sigma=newCalSigma(newIdx);

% plot of grid search
% subplot(122);
% figure
% surf(log10(newCalC),log10(newCalSigma),newClassRateMatrix);
% xlabel('log(C)');
% ylabel('log(\sigma)');
% zlabel('Correct rate');
