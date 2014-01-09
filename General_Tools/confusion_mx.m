    
% Evaluates algorithm against test data to return confusion matrix
% information
% Created: 2-20-06


function [acc,truepos_rate,falsepos_rate,trueneg_rate,falseneg_rate]=confusion_mx(actual,predited,cost);

        
    truepos = sum( (actual & (predited>cost)  ) ); %d  guess pos, is pos
    trueneg = sum( (~actual & ~(predited>cost)) ); %a  guess neg, is neg
    falsepos= sum( (~actual & (predited>cost) ) ); %b  guess pos, is neg
    falseneg= sum( (actual & ~(predited>cost) ) ); %c  guess neg, is pos (miss)
    
    acc=(trueneg+truepos)/(trueneg+falsepos+falseneg+truepos); %(a+d)/(a+b+c+d)
    truepos_rate =truepos/(falseneg+truepos); %d/(c+d)
    falsepos_rate=falsepos/(falsepos+trueneg);%b/(a+b)
    
    %Not very useful
    trueneg_rate =trueneg/(falsepos+trueneg); 
    falseneg_rate=falseneg/(falseneg+truepos);

    