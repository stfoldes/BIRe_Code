% Stephen Foldes
% 01-20-10
% Builds a decoder (features x dimesions) using inverese (i.e. backslash operator)
% Checks to make sure there are more samples than features, if there are not enough samples, it does pseudo-inverse
%
% Input = (samples x features) decoder training data
% Output = (samples x dimension) decoder training targets or classes
% decoder = (features x dimesions) build decoder
%         Decoder is used: predicted_data = data * decoder
%
%Note: This function normalizes each column of inputs to zero mean and
%returns 'MeanInputNorm' (1xM) so that New Inputs can be
%similarly normalized before applying the transformation if needed
%
% FROM Help mldivide
% If A is an m-by-n matrix
% with m ~= n and B is a column vector
% with m components, or a matrix with several such columns,
% then X = A\B is the solution in the least squares sense
% to the under- or overdetermined system of equations AX = B.
% In other words, X minimizes norm(A*X - B),
% the length of the vector AX - B. The
% rank k of A is determined from the QR
% decomposition with column pivoting (see Algorithm for details). The computed solution X has
% at most k nonzero elements per column. If k <
% n, this is usually not the same solution as x = pinv(A)*B,
% which returns a least squares solution.
%
% "Warning: Rank deficient" means least-squares is used to determine best solution. This is expected

function [decoder, MeanInputNorm]=OLE_inv(Input, Output)

    MeanInputNorm=mean(Input);
    OLEInput=Input-(ones(size(Input(:,1)))*MeanInputNorm);

    % Check if more or equal number of samples than features
    if size(OLEInput,2)<=size(OLEInput,1)
        % Output = Input * decoder
        % decoder = Output / Input
        % decoder = Input \ Output
        % "X = A\B is the solution to the equation AX = B"
        decoder= OLEInput\Output;

    else % not enough samples
        disp(['ERROR in OLE_inv.m: Not enough samples for number of features, doing pseudoinverse (' num2str(size(Input,2)) ' features ' num2str(size(Input,1)) ' samples)'])
        keyboard
        % Pseudo-Inverse
        decoder=(pinv(OLEInput)*Output);
    end






