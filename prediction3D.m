function [ypred, meanpred] = prediction3D(Xmean,Ymean,beta,Xnew)
% [ypred,rmse] = prediction(X,Y,beta,Xnew,Ynew)
% ypred = (Xnew - mean(X)) * beta + mean(Y)

p = size(Xnew,3);
ypred = bsxfun(@plus,sum(bsxfun(@times,bsxfun(@minus,Xnew,reshape(Xmean,[1,1,p])),reshape(beta,[1,1,p])),3),Ymean);
meanpred  = nanmean(ypred(:));
